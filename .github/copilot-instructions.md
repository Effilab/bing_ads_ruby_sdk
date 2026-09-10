# Bing Ads Ruby SDK Project Guidelines

This repository is a Ruby gem that wraps the Microsoft Advertising API v13. Read [docs/architecture.md](../docs/architecture.md) for the system map and request flows, and [docs/development.md](../docs/development.md) for the change and test workflow.

## Working Rules

- Preserve the public API and existing snake_case Ruby interface unless the task explicitly changes it.
- Use Ruby 3+ syntax and follow Standard Ruby. Run `bundle exec standardrb` and the narrowest relevant RSpec command after changes.
- Treat SOAP and JSON paths as separate transports. Do not reuse a SOAP service implementation for JSON or vice versa without checking both contracts.
- SOAP operation names are exposed in snake_case and converted by `Services::Base#call`; WSDL operation names and XML fields are CamelCase and order-sensitive.
- JSON payloads are camelized before serialization. JSON responses use symbolized keys and API error arrays become `Services::Json::ApiError`.
- OAuth stores must implement `read` and `write(data)`. Never commit tokens, client secrets, developer tokens, customer IDs, or live request logs.
- API credentials for local test-account calls belong in the ignored `.env` file. Use `.env.example` as the reference for the required variable names and values; never invent or commit credential files.
- Required live-call variables are `BING_CLIENT_ID`, `BING_CLIENT_SECRET`, `BING_DEVELOPER_TOKEN`, `BING_SANDBOX_CUSTOMER_ID`, `BING_SANDBOX_ACCOUNT_ID`, and `BING_STORE_FILENAME`. The repository's JSON integration specs expect `BING_STORE_FILENAME=sandbox_token.json` at the repository root.
- OAuth authorization and token-store generation must be performed by the developer, not the AI agent. The developer should run `bundle exec rake 'bing_token:get[sandbox_token.json]'` interactively from the repository root, complete browser authorization, and leave the ignored `sandbox_token.json` available. The agent may verify that the file exists, but must never read, print, or commit its contents.
- The `.env` variable names contain `SANDBOX` for historical reasons; the current approved live validation uses `environment: :production` with the configured production test-account IDs. Use `environment: :sandbox` only with sandbox-issued credentials, account IDs, and token context.
- Before attempting any live API call, load `.env` into the current shell session with `set -a; . ./.env; set +a`, then run the Ruby command from that same shell. Do not print the variables or their values.
- When live validation creates resources, use disposable paused test resources, verify the new behavior end to end, clean them up with the corresponding delete operation, and confirm cleanup with a read-only account-level query before moving to the next task.
- Prefer unit specs with fixtures and doubles. Integration specs under `spec/examples/` make real Microsoft Advertising changes and require explicit credentials.
- Keep service helpers thin; use the generic `call`/`post`/`delete` escape hatches when an endpoint has no convenience method.
- When updating API versions, inspect Microsoft’s migration guide, WSDL assets, `version.rb`, fixtures, and tests together.
- Do not modify generated or vendored WSDL content casually. Explain any WSDL change and cover the affected operation with a fixture-backed test.

## Validation

- Setup: `bin/setup`
- Unit suite: `bundle exec rspec`
- Style: `bundle exec standardrb`
- Default Rake task: `bundle exec rake`
- OAuth store: developer-generated `sandbox_token.json`; the agent must not run the interactive authorization task or inspect the token contents.
- Do not run `spec/examples/` unless the user explicitly provides safe test credentials and accepts live account changes.
