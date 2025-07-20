# Decentralized Diplomatic Immunity Management System

A blockchain-based system for managing diplomatic immunity status, privileges, and incident reporting using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a transparent, immutable, and decentralized approach to managing diplomatic immunity across multiple jurisdictions. It ensures proper verification of diplomatic status, tracks immunity privileges, records incidents, facilitates host country coordination, and manages personnel rotations.

## System Architecture

### Core Contracts

1. **Diplomatic Status Verification Contract** (`diplomatic-status.clar`)
    - Validates embassy personnel credentials
    - Manages diplomatic rank classifications
    - Handles status updates and revocations

2. **Immunity Privilege Contract** (`immunity-privilege.clar`)
    - Defines scope and limitations of legal protections
    - Manages privilege levels based on diplomatic rank
    - Tracks privilege usage and restrictions

3. **Incident Reporting Contract** (`incident-reporting.clar`)
    - Records diplomatic immunity invocation cases
    - Maintains incident history and outcomes
    - Provides transparency for immunity claims

4. **Host Country Coordination Contract** (`host-coordination.clar`)
    - Facilitates communication with local authorities
    - Manages bilateral agreements and protocols
    - Handles dispute resolution processes

5. **Personnel Rotation Contract** (`personnel-rotation.clar`)
    - Tracks diplomatic staff assignments and transfers
    - Manages rotation schedules and approvals
    - Maintains personnel history and credentials

## Key Features

- **Immutable Records**: All diplomatic actions are permanently recorded on the blockchain
- **Multi-jurisdictional Support**: Handles diplomatic relations across different countries
- **Transparent Processes**: Public verification of diplomatic status and incident reporting
- **Automated Compliance**: Smart contract enforcement of diplomatic protocols
- **Secure Credential Management**: Cryptographic verification of diplomatic credentials

## Diplomatic Ranks

The system recognizes the following diplomatic ranks with corresponding privilege levels:

- **Ambassador** (Level 5): Full diplomatic immunity
- **Minister** (Level 4): High-level immunity with minor restrictions
- **Counselor** (Level 3): Standard diplomatic immunity
- **Secretary** (Level 2): Limited immunity for official duties
- **Attaché** (Level 1): Basic immunity for specific functions

## Usage

### Deploying Contracts

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet deploy` to deploy all contracts

### Verifying Diplomatic Status

\`\`\`clarity
(contract-call? .diplomatic-status verify-diplomat diplomat-id embassy-id rank)
\`\`\`

### Reporting Incidents

\`\`\`clarity
(contract-call? .incident-reporting report-incident diplomat-id incident-type description)
\`\`\`

### Managing Personnel Rotation

\`\`\`clarity
(contract-call? .personnel-rotation initiate-rotation diplomat-id new-assignment-country)
\`\`\`

## Testing

Run the test suite using:

\`\`\`bash
npm test
\`\`\`

## Security Considerations

- All diplomatic credentials are verified through cryptographic signatures
- Multi-signature requirements for high-level diplomatic actions
- Time-locked operations for sensitive privilege modifications
- Audit trails for all system interactions

## Compliance

This system is designed to comply with:
- Vienna Convention on Diplomatic Relations (1961)
- Vienna Convention on Consular Relations (1963)
- International diplomatic protocols and customs

## Contributing

Please read the PR-DETAILS.md file for contribution guidelines and development processes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
