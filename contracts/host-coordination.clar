;; Host Country Coordination Contract
;; Facilitates communication with local authorities and manages bilateral agreements

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-AGREEMENT-NOT-FOUND (err u401))
(define-constant ERR-INVALID-STATUS (err u402))
(define-constant ERR-COUNTRY-NOT-REGISTERED (err u403))
(define-constant ERR-COMMUNICATION-NOT-FOUND (err u404))

;; Agreement Types
(define-constant BILATERAL-AGREEMENT u1)
(define-constant PROTOCOL-AGREEMENT u2)
(define-constant SPECIAL-ARRANGEMENT u3)
(define-constant TEMPORARY-AGREEMENT u4)

;; Communication Types
(define-constant OFFICIAL-NOTE u1)
(define-constant DIPLOMATIC-PROTEST u2)
(define-constant INFORMATION-REQUEST u3)
(define-constant COORDINATION-REQUEST u4)
(define-constant INCIDENT-NOTIFICATION u5)

;; Status Types
(define-constant STATUS-DRAFT u1)
(define-constant STATUS-PENDING u2)
(define-constant STATUS-ACTIVE u3)
(define-constant STATUS-SUSPENDED u4)
(define-constant STATUS-TERMINATED u5)

;; Data Variables
(define-data-var next-agreement-id uint u1)
(define-data-var next-communication-id uint u1)

;; Data Maps
(define-map host-countries
  { country-code: (string-ascii 3) }
  {
    country-name: (string-ascii 100),
    contact-authority: (string-ascii 100),
    is-active: bool,
    registered-at: uint
  }
)

(define-map bilateral-agreements
  { agreement-id: uint }
  {
    host-country: (string-ascii 3),
    sending-country: (string-ascii 3),
    agreement-type: uint,
    title: (string-ascii 200),
    description: (string-ascii 500),
    status: uint,
    signed-at: uint,
    expires-at: uint,
    created-by: principal
  }
)

(define-map diplomatic-communications
  { communication-id: uint }
  {
    from-country: (string-ascii 3),
    to-country: (string-ascii 3),
    communication-type: uint,
    subject: (string-ascii 200),
    content: (string-ascii 1000),
    incident-id: (optional uint),
    sent-at: uint,
    sent-by: principal,
    is-urgent: bool
  }
)

(define-map communication-responses
  { communication-id: uint }
  {
    response-content: (string-ascii 1000),
    responded-by: principal,
    responded-at: uint,
    is-acknowledged: bool
  }
)

(define-map country-authorities
  { country-code: (string-ascii 3), authority: principal }
  { is-authorized: bool }
)

;; Public Functions

;; Register host country
(define-public (register-host-country
  (country-code (string-ascii 3))
  (country-name (string-ascii 100))
  (contact-authority (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set host-countries
      { country-code: country-code }
      {
        country-name: country-name,
        contact-authority: contact-authority,
        is-active: true,
        registered-at: block-height
      }
    )
    (ok true)
  )
)

;; Add country authority
(define-public (add-country-authority (country-code (string-ascii 3)) (authority principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? host-countries { country-code: country-code })) ERR-COUNTRY-NOT-REGISTERED)
    (map-set country-authorities
      { country-code: country-code, authority: authority }
      { is-authorized: true }
    )
    (ok true)
  )
)

;; Create bilateral agreement
(define-public (create-bilateral-agreement
  (host-country (string-ascii 3))
  (sending-country (string-ascii 3))
  (agreement-type uint)
  (title (string-ascii 200))
  (description (string-ascii 500))
  (validity-period uint))
  (let ((agreement-id (var-get next-agreement-id)))
    (asserts! (is-country-authority host-country tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= agreement-type u1) (<= agreement-type u4)) ERR-INVALID-STATUS)

    (map-set bilateral-agreements
      { agreement-id: agreement-id }
      {
        host-country: host-country,
        sending-country: sending-country,
        agreement-type: agreement-type,
        title: title,
        description: description,
        status: STATUS-DRAFT,
        signed-at: u0,
        expires-at: (+ block-height validity-period),
        created-by: tx-sender
      }
    )
    (var-set next-agreement-id (+ agreement-id u1))
    (ok agreement-id)
  )
)

;; Sign bilateral agreement
(define-public (sign-agreement (agreement-id uint))
  (let ((agreement-data (unwrap! (map-get? bilateral-agreements { agreement-id: agreement-id }) ERR-AGREEMENT-NOT-FOUND)))
    (asserts! (is-country-authority (get sending-country agreement-data) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status agreement-data) STATUS-DRAFT) ERR-INVALID-STATUS)

    (map-set bilateral-agreements
      { agreement-id: agreement-id }
      (merge agreement-data {
        status: STATUS-ACTIVE,
        signed-at: block-height
      })
    )
    (ok true)
  )
)

;; Send diplomatic communication
(define-public (send-diplomatic-communication
  (to-country (string-ascii 3))
  (communication-type uint)
  (subject (string-ascii 200))
  (content (string-ascii 1000))
  (incident-id (optional uint))
  (is-urgent bool))
  (let ((communication-id (var-get next-communication-id))
        (from-country (get-sender-country tx-sender)))
    (asserts! (is-some from-country) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= communication-type u1) (<= communication-type u5)) ERR-INVALID-STATUS)
    (asserts! (is-some (map-get? host-countries { country-code: to-country })) ERR-COUNTRY-NOT-REGISTERED)

    (map-set diplomatic-communications
      { communication-id: communication-id }
      {
        from-country: (unwrap-panic from-country),
        to-country: to-country,
        communication-type: communication-type,
        subject: subject,
        content: content,
        incident-id: incident-id,
        sent-at: block-height,
        sent-by: tx-sender,
        is-urgent: is-urgent
      }
    )
    (var-set next-communication-id (+ communication-id u1))
    (ok communication-id)
  )
)

;; Respond to diplomatic communication
(define-public (respond-to-communication
  (communication-id uint)
  (response-content (string-ascii 1000)))
  (let ((comm-data (unwrap! (map-get? diplomatic-communications { communication-id: communication-id }) ERR-COMMUNICATION-NOT-FOUND)))
    (asserts! (is-country-authority (get to-country comm-data) tx-sender) ERR-NOT-AUTHORIZED)

    (map-set communication-responses
      { communication-id: communication-id }
      {
        response-content: response-content,
        responded-by: tx-sender,
        responded-at: block-height,
        is-acknowledged: true
      }
    )
    (ok true)
  )
)

;; Suspend agreement
(define-public (suspend-agreement (agreement-id uint) (reason (string-ascii 300)))
  (let ((agreement-data (unwrap! (map-get? bilateral-agreements { agreement-id: agreement-id }) ERR-AGREEMENT-NOT-FOUND)))
    (asserts! (or
      (is-country-authority (get host-country agreement-data) tx-sender)
      (is-country-authority (get sending-country agreement-data) tx-sender)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status agreement-data) STATUS-ACTIVE) ERR-INVALID-STATUS)

    (map-set bilateral-agreements
      { agreement-id: agreement-id }
      (merge agreement-data {
        status: STATUS-SUSPENDED
      })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Check if user is country authority
(define-read-only (is-country-authority (country-code (string-ascii 3)) (user principal))
  (default-to false (get is-authorized (map-get? country-authorities { country-code: country-code, authority: user })))
)

;; Get sender country for user
(define-read-only (get-sender-country (user principal))
  ;; This would need to be implemented based on embassy associations
  ;; For now, returns a placeholder
  (some "USA")
)

;; Get host country information
(define-read-only (get-host-country (country-code (string-ascii 3)))
  (map-get? host-countries { country-code: country-code })
)

;; Get bilateral agreement
(define-read-only (get-bilateral-agreement (agreement-id uint))
  (map-get? bilateral-agreements { agreement-id: agreement-id })
)

;; Get diplomatic communication
(define-read-only (get-diplomatic-communication (communication-id uint))
  (map-get? diplomatic-communications { communication-id: communication-id })
)

;; Get communication response
(define-read-only (get-communication-response (communication-id uint))
  (map-get? communication-responses { communication-id: communication-id })
)

;; Check if agreement is active
(define-read-only (is-agreement-active (agreement-id uint))
  (match (map-get? bilateral-agreements { agreement-id: agreement-id })
    agreement-data (and
      (is-eq (get status agreement-data) STATUS-ACTIVE)
      (< block-height (get expires-at agreement-data))
    )
    false
  )
)

;; Get active agreements for countries
(define-read-only (get-country-agreements (host-country (string-ascii 3)) (sending-country (string-ascii 3)))
  ;; This would require additional indexing in a full implementation
  ;; Returns placeholder data
  {
    total-agreements: u0,
    active-agreements: u0,
    suspended-agreements: u0
  }
)
