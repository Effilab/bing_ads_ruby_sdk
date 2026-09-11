# Architecture

## Purpose

`bing_ads_ruby_sdk` is a Ruby gem for calling Microsoft Advertising (formerly Bing Ads) APIs. It provides a shared OAuth 2.0 flow, a SOAP client for the v13 WSDL services, and a smaller REST/JSON client currently focused on Campaign Management.

The gem is an adapter rather than a complete generated SDK. It translates idiomatic Ruby hashes and snake_case operation names into the wire formats expected by Microsoft, then normalizes responses back into Ruby-friendly hashes.

## Public entry points

- `BingAdsRubySdk.configure` configures logging, XML formatting, sensitive-field filters, and optional Excon instrumentation.
- `BingAdsRubySdk::Api` creates SOAP service objects and stores the active customer/account context.
- `BingAdsRubySdk::JsonApi` creates JSON service objects and stores the active customer/account context.
- `BingAdsRubySdk::OAuth2::FsStore` is the default filesystem token store; applications may provide any store implementing `read` and `write(data)`.
- The `bing_token:get` Rake task obtains an OAuth token through an interactive flow.

The default API version is defined in `lib/bing_ads_ruby_sdk/version.rb`.

## SOAP request flow

```text
Application
  -> Api
  -> Services::<Service>#call(operation_name, message)
  -> Camelize: snake_case keys to CamelCase
  -> WsdlOperationWrapper / Order: arrange fields using WSDL metadata
  -> SoapClient: construct XML with LolSoap and add Header content
  -> HttpClient.post: persistent Excon connection, timeouts and retries
  -> LolSoap response parser
  -> Snakize + CastLongArrays
  -> Errors::ErrorHandler
  -> Application hash
```

`Api` builds a service with the selected version, environment, shared `Header`, and service-specific WSDL. SOAP services include `ad_insight`, `bulk`, `campaign_management`, `customer_billing`, `customer_management`, and `reporting`.

`Services::Base#call` is the common SOAP boundary. Callers use snake_case operation names, while `StringUtils.camelize` maps them to WSDL operation names. Input hashes are recursively camelized and ordered against the operation wrapper. Output hashes are recursively snakeized; long-array values are normalized by `CastLongArrays`. `call_wrapper` supports convenience methods that extract and normalize nested response arrays.

`SoapClient` loads WSDL XML from `lib/bing_ads_ruby_sdk/wsdl/<version>/<environment>/`, caches parsed WSDL data by service name, injects SOAP headers, and handles abstract/concrete type attributes through `xsi:type`. Missing WSDL operations fail at the wrapper lookup, which is useful feedback when adding a new convenience method.

## JSON request flow

```text
Application
  -> JsonApi
  -> Services::Json::<Service>#post, #put, or #delete
  -> Preprocessors::Camelize
  -> HttpClient.post/put/delete with Bearer token
  -> JSON.parse(symbolize_names: true)
  -> Services::Json::Base error categories
  -> Application hash
```

`JsonApi` validates versions in `vN` format, creates the JSON headers and OAuth handler, and currently exposes `campaign_management`, `customer_management`, and `bulk`. The JSON Campaign Management service contains selected helpers such as shared-entity, campaign, UET, conversion-goal, and list-item operations. The JSON Customer Management service provides account lookup, account/customer discovery, account update, and customer signup helpers. The JSON Bulk service provides bulk upload URL/status and campaign download/status helpers. `Services::Json::Base#post`, `#put`, and `#delete` remain the generic escape hatches for supported URL paths.

JSON responses are symbolized but retain Microsoft’s response key casing. `Base` raises `Services::Json::ApiError` when `BatchErrors`, `OperationErrors`, or `PartialErrors` contains entries. This differs from SOAP, whose normalized response is checked by `Errors::ErrorHandler`.

## Authentication and context

`Header` and `JsonApi` both delegate token acquisition to `OAuth2::AuthorizationHandler`. The handler reads a token hash from the configured store, refreshes it when necessary, and writes newly fetched token data back. The OAuth scope is `https://ads.microsoft.com/msads.manage`.

`set_customer(account_id:, customer_id:)` adds `CustomerAccountId` and `CustomerId` to subsequent SOAP or JSON requests. The context is held by the API client, so applications should use separate client instances when they need independent customer/account contexts.

## Transport and observability

`HttpClient` owns Excon connections keyed by host. It uses persistent connections to avoid the time-consuming process of connection negotiation which can become significant for high-volume applications. It uses TLS 1.2, 10-second connect timeout, 20-second read timeout, and two retries for timeout conditions. `close_http_connections` clears cached connections and is useful for process shutdown or test isolation.

When logging is enabled, SOAP request XML is passed through `LogMessage`, which pretty-prints and filters configured sensitive fields. Keep logging disabled or filtered in production and never commit generated log files or token stores.

### Add an OAuth store

Implement:

```ruby
class MyTokenStore
  def read
    # Return a token Hash or nil.
  end

  def write(data)
    # Persist the token Hash and return the store's normal result.
  end
end
```

Keep persistence secure and ensure token files are excluded from version control.

## Error boundaries

- OAuth failures originate in Signet or the store and should be handled as authentication/configuration failures.
- SOAP API faults and partial errors are mapped by `Errors::ErrorHandler` to typed error classes under `lib/bing_ads_ruby_sdk/errors/`.
- JSON batch, operation, and partial errors raise `Services::Json::ApiError`.
- Network failures originate in Excon through `HttpClient`; timeout retry behavior is configured centrally.

## Repository map

- `lib/bing_ads_ruby_sdk.rb`: gem loading, configuration, root path, constants.
- `lib/bing_ads_ruby_sdk/api.rb`: SOAP client facade.
- `lib/bing_ads_ruby_sdk/json_api.rb`: JSON client facade.
- `lib/bing_ads_ruby_sdk/services/`: SOAP service objects.
- `lib/bing_ads_ruby_sdk/services/json/`: JSON service objects.
- `lib/bing_ads_ruby_sdk/preprocessors/`: request normalization and WSDL ordering.
- `lib/bing_ads_ruby_sdk/postprocessors/`: response normalization.
- `lib/bing_ads_ruby_sdk/oauth2/`: OAuth authorization and stores.
- `lib/bing_ads_ruby_sdk/wsdl/`: version/environment-specific WSDL assets.
- `lib/bing_ads_ruby_sdk/errors/`: SOAP error classes and mapping.
- `spec/`: unit specs, fixtures, support helpers, and live examples.
- `bin/`, `Rakefile`, and `lib/bing_ads_ruby_sdk/tasks/`: setup, console, release, and token-task entry points.
