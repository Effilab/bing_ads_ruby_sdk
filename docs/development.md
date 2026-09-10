# Development Guide

## Setup

The gem requires Ruby 3 or newer. Install dependencies with:

```shell
bin/setup
mkdir -p log
```

Use `bin/console` for an interactive session. The project uses Bundler, Rake, RSpec, SimpleCov, and Standard Ruby.

## API credentials for local calls

Use `.env.example` as the reference for the required variable names:

```text
.env.example
```

Put local credentials and test-account identifiers in `.env`. The file is ignored by Git and must never be committed. Before making any live SOAP or JSON API call, export the values into the current shell session and run the API command from that same session:

```shell
set -a
. ./.env
set +a
bundle exec ruby -Ilib your_api_script.rb
```

Do not print the environment variables, include their values in source code, or pass credentials through committed scripts. Unit tests using fixtures and doubles do not require API credentials.

## Routine validation

Run the focused spec while developing, then the full unit suite and formatter:

```shell
mkdir -p log
bundle exec rspec spec/bing_ads_ruby_sdk/path/to/spec.rb
bundle exec rspec
bundle exec standardrb
bundle exec rake
```

`bundle exec rake` uses the RSpec task as the default task. SimpleCov writes coverage output under `coverage/`.

## AI agent live-call setup

Agents must use the ignored `.env` file for live validation. Start from `.env.example` and provide these variables without committing their values:

```dotenv
BING_CLIENT_ID="..."
BING_CLIENT_SECRET="..."
BING_DEVELOPER_TOKEN="..."
BING_SANDBOX_CUSTOMER_ID="..."
BING_SANDBOX_ACCOUNT_ID="..."
BING_STORE_FILENAME="sandbox_token.json"
```

The `SANDBOX` names are historical in this repository. The approved test workflow uses the production API with the configured production test account, so the OAuth token, customer ID, and account ID must belong to the same environment. Do not combine sandbox credentials with `environment: :production`, or production credentials with `environment: :sandbox`.

### Controlled production test account

The production MCC/customer `163251198` has a controlled testing account with account ID `187302033`. This account was created during SDK validation and is intended for disposable paused-resource integration tests. Microsoft does not expose a customer or account deletion operation, so the account itself must be retained; tests should clean up campaigns, ad groups, ads, keywords, and other child resources they create.

The developer must generate the OAuth token store before asking an AI agent to run live calls. From the repository root, the developer should run:

```shell
set -a
. ./.env
set +a
bundle exec rake 'bing_token:get[sandbox_token.json]'
```

The task prints a Microsoft authorization URL. Open it in a browser, approve access, copy the complete redirected URL, and paste it into the rake prompt. The task writes `sandbox_token.json` in the repository root. AI agents must not run this interactive authorization task, handle the redirected URL, or inspect the token contents. Agents may only confirm that the developer-generated file exists:

```shell
test -f "$BING_STORE_FILENAME" && echo "OAuth store ready"
```

Agents must never print, inspect into logs, or commit `.env` or `sandbox_token.json`. Before every live call, load `.env` in the same shell. Normal unit and VCR replay tests do not require live credentials.

Unit specs should use local fixtures and test doubles. The support files under `spec/support/` provide shared helpers for HTTP and API behavior. Follow nearby specs for fixture naming and setup rather than inventing a new test harness.

### JSON API HTTP cassettes

JSON API integration specs live under `spec/integration/json_api/`, grouped by API section, and use VCR with WebMock. The suite covers the supported read, create, update, delete, upload, and asynchronous workflows with real response bodies. Normal runs replay the checked-in cassettes without network access:

```shell
bundle exec rspec spec/integration/json_api_spec.rb
```

To record or refresh cassettes, load the ignored `.env` file in the same shell and opt into recording:

```shell
set -a
. ./.env
set +a
VCR_RECORD=once bundle exec rspec spec/integration/json_api_spec.rb
```

VCR replaces API credentials, account identifiers, and OAuth authorization headers before writing cassettes. Do not commit tokens, secrets, or live request logs. Keep integration examples read-only or use a cleanup path for any resource they create.

The raw file-transfer helpers (`Bulk#upload_file`, `Bulk#download_file`, and `Reporting#download_file`) use short-lived URLs and are covered by focused unit specs. Their live URLs should not be persisted in long-lived cassettes; validate those workflows during an approved recording session when needed. `BulkFileReader#to_csv` removes Microsoft Reporting metadata rows when present, so report consumers receive the actual column headers and data rows directly.

Campaign Management read scenarios use disposable paused fixtures. Campaign-only scenarios create a campaign with `add_campaigns`; hierarchy scenarios use Bulk upload to create a campaign, ad group, and keyword, then query those resources through JSON and remove the parent campaign. A live account query confirms cleanup. JSON ad creation is available through `add_responsive_search_ads`, which builds the typed `ResponsiveSearch` payload returned by the REST contract. Existing ad reads use plain string values in `ad_types` (for example, `ad_types: ["ResponsiveSearch"]`), whereas the SOAP wrapper represents those enum values as hashes. The configured account has existing responsive search ads; live creation validation should use a paused disposable hierarchy and clean up child resources before parents.

The cassette set intentionally excludes operations that cannot be recorded meaningfully with the configured account: insertion-order mutations, shared-list mutations without an owned disposable list, and report/file downloads without usable data or a durable URL. These operations remain covered by unit specs and should be recorded only after their required permissions and cleanup paths are available. Budget CRUD uses a disposable shared budget; UET tag creation uses a uniquely named controlled test-account resource because Microsoft does not expose a UET tag delete operation. Existing UET tags and conversion goals are used for update coverage. Customer Management read and update flows use the configured customer and its current `TimeStamp`. Signup has one recorded live success in `customer_signup_creates_one_customer_and_account.yml`; Microsoft exposes no customer or account delete operation, so the resulting controlled customer/account must be retained.

## Choosing a test boundary

- Preprocessors/postprocessors: test transformation inputs and outputs directly.
- `HttpClient`: test request URL, headers, body, connection behavior, and retry-related configuration without external calls.
- OAuth: test store reads/writes, refresh behavior, code extraction, and invalid store data.
- SOAP services: test the public helper or `call` with a fixture-backed SOAP response; verify operation names and normalized results.
- JSON services: stub `HttpClient`, assert the generated path/headers/body, and cover `BatchErrors`, `OperationErrors`, and `PartialErrors`.
- Live integration: use only `spec/examples/`, in its documented order, with explicit approval and disposable or controlled Microsoft Advertising accounts.

The examples can create real accounts and advertising entities. They are not a normal CI suite. Never put their credentials in source control.

## Adding or changing a SOAP operation

SOAP operation names in application code are snake_case. Request keys are also snake_case and are transformed recursively. Arrays are expected to contain hashes because the SOAP insertion logic creates repeated nodes from hash values.

A typical service helper is intentionally small:

```ruby
def get_campaigns_by_account_id(account_id:)
  call_wrapper(
    :get_campaigns_by_account_id,
    { account_id: account_id },
    :campaigns,
    :campaign
  )
end
```

Before adding a helper, check whether the generic service `call` already provides the needed endpoint. If a helper extracts or reshapes data, test that behavior explicitly.

## Adding or changing a JSON operation

JSON service helpers pass a REST path and payload to the JSON base class:

```ruby
def get_shared_entities(payload)
  post("SharedEntities/Query", payload)
end

def add_campaigns(payload)
  post("Campaigns", payload)
end

def update_campaigns(payload)
  put("Campaigns", payload)
end

def delete_campaigns(payload)
  delete("Campaigns", payload)
end
```

The base class camelizes the payload, adds the Bearer token and JSON headers, parses a symbolized response, and raises on Microsoft error arrays. `add_campaigns` uses `POST /Campaigns`; `update_campaigns` uses `PUT /Campaigns`; and `delete_campaigns` uses `DELETE /Campaigns`. Microsoft accepts up to 100 campaign objects per request. Use `delete_campaigns` to clean up campaigns created by live tests. Do not duplicate transport or error responsibilities in individual service methods.

## Building and uploading a Bulk file

Use `BingAdsRubySdk::BulkFileBuilder` for CSV/TSV content. It adds the required `Format Version` record and keeps columns consistent across records:

```ruby
builder = BingAdsRubySdk::BulkFileBuilder.new
builder.add_campaign(name: "SDK Bulk Test", client_id: "sdk-bulk-test")

upload = api.bulk.get_bulk_upload_url(
  account_id: account_id,
  response_mode: "ErrorsAndResults"
)

api.bulk.upload_file(
  upload_url: upload.fetch(:UploadUrl),
  content: builder.to_s,
  filename: "campaign.csv"
)
```

Poll `get_bulk_upload_status(request_id: upload.fetch(:RequestId))` until `Completed`, `CompletedWithErrors`, or `Failed`. Download the result with `api.bulk.download_file(url: status.fetch(:ResultFileUrl))`, then parse plain CSV, GZIP, or ZIP content with `BingAdsRubySdk::BulkFileReader.new(result_content).to_csv`. For large files, stream both download and processing to avoid building a table in memory:

```ruby
chunks = api.bulk.download_file(url: status.fetch(:ResultFileUrl), stream: true)
instrumentation = lambda do |metrics|
  remote_metrics_client.record("bulk_file.parse", metrics)
end

BingAdsRubySdk::BulkFileReader.new(chunks, instrumentation: instrumentation).each_row do |row|
  process_row(row)
end
```

The instrumentation callback receives the operation name, success status, wall-clock seconds, process CPU seconds, and process maximum RSS before, after, and during the operation. Instrumentation errors are ignored so telemetry failures do not interrupt parsing.
The instrumentation callback receives the operation name, success status, wall-clock seconds, process CPU seconds, and process maximum RSS before, after, and during the operation. Decode lifecycle events are emitted as `:decode_start`, `:decode_finish`, `:unzip_finish`, and `:gunzip_finish`, with compression type, input/output bytes, duration in milliseconds, success status, and an error class when decoding fails. Instrumentation errors are ignored so telemetry failures do not interrupt parsing.

For live tests, extract created IDs from the result file or an account-level query and clean them up with the relevant REST delete helper.

For a new JSON service, update both `JsonApi::SERVICE_CLASSES` and the corresponding accessor, then add a focused service spec.

Customer Management `update_account` is a full overwrite and requires the current opaque `time_stamp` from `get_account`. REST responses use CamelCase keys, while request payloads must use snake_case; do not pass a REST response hash directly back into `update_account` without converting its keys first.

## API versions and WSDL assets

Microsoft Advertising regularly changes API versions and retires old ones. A version update normally requires these steps:

1. Read Microsoft’s migration guide and identify renamed, removed, or changed operations.
2. Update the default in `lib/bing_ads_ruby_sdk/version.rb` only when compatibility is intentional.
3. Add or update WSDL assets under `lib/bing_ads_ruby_sdk/wsdl/` for each supported environment.
4. Review service methods, request ordering, abstract type handling, and response normalization.
5. Update fixture-backed specs and README examples that depend on changed fields.
6. Record user-visible compatibility changes in `changelog.md`.

Do not infer WSDL structure from a response example alone; the operation wrapper uses WSDL metadata to order fields.

## Logging and secrets

Configuration can enable SOAP request logging:

```ruby
BingAdsRubySdk.configure do |config|
  config.log = true
  config.filters = ["AuthenticationToken", "DeveloperToken", "CustomerId", "CustomerAccountId"]
end
```

Use filtering whenever logging is enabled. Token stores, `.env` files, generated logs, and captured authenticated payloads must remain local and ignored by Git. Review `git diff` and `git status` before sharing a patch.

## Release workflow

Update `VERSION` in `lib/bing_ads_ruby_sdk/version.rb`, update `changelog.md`, run the unit suite and Standard Ruby, then use:

```shell
bundle exec rake release
```

The release task creates and pushes commits/tags and publishes the gem, so confirm the branch, remote, version, and changelog before running it.

## Documentation expectations

When public behavior changes, update the README example or the relevant document in `docs/`. Keep examples free of real identifiers and secrets. State clearly when an endpoint is a convenience helper, when callers must use the generic escape hatch, and when behavior requires a live Microsoft account.
