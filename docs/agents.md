# AI Agent Guide

This repository includes shared Copilot guidance in `.github/copilot-instructions.md` and three role-specific agents in `.github/agents/`:

- `sdk-api.agent.md`: SOAP/JSON API implementation, OAuth, transport, WSDL, errors, and version upgrades.
- `sdk-testing.agent.md`: deterministic RSpec coverage, fixtures, doubles, and safe handling of live examples.
- `sdk-docs.agent.md`: README, architecture, development, release, migration, and maintenance documentation.

Start with the role that owns the requested change. For cross-cutting work, use the API agent for implementation and the testing agent for coverage, then ask the docs agent to update user-facing guidance.

All agents should consult:

- [Architecture](architecture.md) for the runtime request flows and extension points.
- [Development Guide](development.md) for commands, test boundaries, release work, and security cautions.

The agents intentionally keep live integration tests out of normal automation. Any action involving Microsoft Advertising accounts requires explicit confirmation and controlled credentials.
