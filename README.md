The instrumentation callback receives the operation, success status, wall-clock time, process CPU time, and process maximum RSS before and after parsing. Decode lifecycle events are also emitted as `:decode_start`, `:decode_finish`, `:unzip_finish`, and `:gunzip_finish`, with compression type, input/output bytes, duration in milliseconds, success status, and an error class when decoding fails. Instrumentation failures are ignored so telemetry cannot interrupt parsing.
# BingAdsRubySdk

## Installation

Add the following to your application's Gemfile:

```ruby
gem 'bing_ads_ruby_sdk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bing_ads_ruby_sdk

## Usage
### Getting Started

In order to use Microsoft's advertising API you need to 
[get your API credentials from MS](https://learn.microsoft.com/en-us/advertising/guides/get-started?view=bingads-13).

From there gem handles OAuth token generation.
By default, there is only one store in the gem to store the oauth token. It's a file system based store. You can create one yourself to store credentials in a database or wherever you desire. The store class must implement `read` and `write(data)` instance methods.

To get your token, run the `bing_token:get` rake task, then follow the prompts. Here's an example:

```shell
bin/rake bing_token:get['credentials.json',YOUR_DEVELOPER_TOKEN,YOUR_CLIENT_ID,YOUR_CLIENT_SECRET]

# For example:
bin/rake bing_token:get['credentials.json',ABC1234,3431b6d0-a2ac-48e1-a1c5-1d0b82f3187f,SECRETVALUEHERE]
```

Then to use the api:
```ruby
store = ::BingAdsRubySdk::OAuth2::FsStore.new('my_token.json')
soap_api = BingAdsRubySdk::Api.new(
  oauth_store: store,
  developer_token: "your_dev_token",
  client_id: "your_bing_client_id",
  client_secret: "your_client_secret"
)

# Or if you wish to use the REST JSON API:
rest_api = BingAdsRubySdk::JsonApi.new(
  oauth_store: store,
  developer_token: "your_dev_token",
  client_id: "your_bing_client_id",
  client_secret: "your_client_secret"
)

# For the available REST API methods, see these classes:
# * BingAdsRubySdk::Services::Json::CampaignManagement
# * BingAdsRubySdk::Services::Json::Base
```

## JSON API Guide

`BingAdsRubySdk::JsonApi` is the REST/JSON client for Microsoft Advertising API v13. It uses the same OAuth token store as the SOAP client, but sends JSON to the Campaign Management, Customer Management, Bulk, Reporting, and Customer Billing services.

### Create a JSON client

Keep credentials in environment variables or a secrets manager. The examples below deliberately use placeholders and do not require credentials in source control.

```ruby
require "bing_ads_ruby_sdk"
require "json"

api = BingAdsRubySdk::JsonApi.new(
  developer_token: ENV.fetch("BING_DEVELOPER_TOKEN"),
  client_id: ENV.fetch("BING_CLIENT_ID"),
  client_secret: ENV.fetch("BING_CLIENT_SECRET"),
  oauth_store: BingAdsRubySdk::OAuth2::FsStore.new(ENV.fetch("BING_STORE_FILENAME")),
  version: :v13,
  environment: :production
)

api.set_customer(
  customer_id: ENV.fetch("BING_CUSTOMER_ID"),
  account_id: ENV.fetch("BING_ACCOUNT_ID")
)
```

Use `environment: :sandbox` only when the OAuth token, customer, account, and developer credentials are sandbox credentials. The `environment: :production` default uses the production API host.

### Request and response conventions

JSON service methods accept snake_case Ruby hashes. The SDK recursively camelizes request keys before serialization. Responses are parsed as hashes with Microsoft's original CamelCase keys:

```ruby
response = api.campaign_management.get_campaigns_by_account_id(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  fields: ["Id", "Name", "Status"]
)

campaign = response.fetch(:Campaigns).first
puts campaign[:Id]
puts campaign[:Name]
```

For example, `account_id` becomes `AccountId`, `final_urls` becomes `FinalUrls`, and `responsive_search` becomes `ResponsiveSearch`. JSON error arrays such as `OperationErrors`, `BatchErrors`, and `PartialErrors` raise `BingAdsRubySdk::Services::Json::ApiError` when they contain errors.

### Customer Management

Customer Management provides account discovery, customer reads, account/customer updates, and signup. Updates are full overwrites; fetch the current object and timestamp before changing it.

```ruby
customer = api.customer_management.get_customer(
  customer_id: ENV.fetch("BING_CUSTOMER_ID")
).fetch(:Customer)

account = api.customer_management.get_account(
  account_id: ENV.fetch("BING_ACCOUNT_ID")
).fetch(:Account)

accounts = api.customer_management.find_accounts(
  customer_id: ENV.fetch("BING_CUSTOMER_ID"),
  account_filter: "",
  top_n: 25
).fetch(:AccountsInfo)

customers = api.customer_management.get_customers_info(
  customer_name_filter: "",
  top_n: 25
).fetch(:CustomersInfo)
```

To update an account, convert the response keys back to snake_case before sending it to the SDK:

```ruby
account = BingAdsRubySdk::Postprocessors::Snakize
  .new(JSON.parse(account.to_json))
  .call
account[:name] = "[TESTING PURPOSE] #{account.fetch(:name)}"

api.customer_management.update_account(account: account)
```

Customer updates work the same way and require the current customer `time_stamp` plus appropriate customer-level permissions:

```ruby
customer = BingAdsRubySdk::Postprocessors::Snakize
  .new(JSON.parse(customer.to_json))
  .call
customer[:name] = "Updated customer name"

api.customer_management.update_customer(customer: customer)
```

Signup creates a real customer and account. There is no customer/account deletion endpoint, so use it only with explicit approval and controlled business data:

```ruby
api.customer_management.signup_customer(
  customer: {
    customer_address: {
      city: "Paris",
      postal_code: "75001",
      line1: "1 rue de Rivoli",
      country_code: "FR"
    },
    industry: "NA",
    market_country: "FR",
    market_language: "French",
    name: "Example customer"
  },
  account: {
    name: "Example account",
    currency_code: "EUR",
    payment_method_id: nil
  },
  parent_customer_id: ENV.fetch("BING_PARENT_CUSTOMER_ID")
)
```

### Campaign Management

Campaigns and ad groups form the parent hierarchy for most advertising resources. Use paused resources for integration tests and delete children before parents.

```ruby
campaign_response = api.campaign_management.add_campaigns(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  campaigns: [{
    name: "SDK example campaign",
    daily_budget: 1,
    budget_type: "DailyBudgetStandard",
    time_zone: "PacificTimeUSCanadaTijuana",
    status: "Paused"
  }]
)
campaign_id = campaign_response.fetch(:CampaignIds).first

ad_group_response = api.campaign_management.add_ad_groups(
  campaign_id: campaign_id,
  ad_groups: [{name: "SDK example ad group", status: "Paused", language: "English"}]
)
ad_group_id = ad_group_response.fetch(:AdGroupIds).first
```

Query, update, and delete the hierarchy:

```ruby
api.campaign_management.get_campaigns_by_ids(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  campaign_ids: [campaign_id],
  fields: ["Id", "Name", "Status"]
)

api.campaign_management.update_campaigns(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  campaigns: [{
    id: campaign_id,
    name: "SDK example campaign updated",
    daily_budget: 1,
    budget_type: "DailyBudgetStandard",
    time_zone: "PacificTimeUSCanadaTijuana",
    status: "Paused"
  }]
)

api.campaign_management.delete_ad_groups(
  campaign_id: campaign_id,
  ad_group_ids: [ad_group_id]
)
api.campaign_management.delete_campaigns(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  campaign_ids: [campaign_id]
)
```

#### Responsive Search Ads

Use the convenience helper for the supported responsive search ad JSON shape. REST uses the `ResponsiveSearch` discriminator and scalar `ad_ids`; SOAP wrappers such as `{long: ad_id}` are not used by JSON.

```ruby
ad_response = api.campaign_management.add_responsive_search_ads(
  ad_group_id: ad_group_id,
  headlines: [
    "SDK headline one",
    "SDK headline two",
    "SDK headline three"
  ],
  descriptions: [
    "SDK description one",
    "SDK description two"
  ],
  final_urls: ["https://www.example.com/"],
  path1: "sdk",
  path2: "example"
)
ad_id = ad_response.fetch(:AdIds).first

api.campaign_management.update_ads(
  ad_group_id: ad_group_id,
  ads: [{
    id: ad_id,
    type: "ResponsiveSearch",
    status: "Paused",
    path1: "updated",
    path2: "example"
  }]
)

ads = api.campaign_management.get_ads_by_ad_group_id(
  ad_group_id: ad_group_id,
  ad_types: ["ResponsiveSearch"]
).fetch(:Ads, [])

api.campaign_management.delete_ads(
  ad_group_id: ad_group_id,
  ad_ids: [ad_id]
)
```

The lower-level helper remains available for other ad types or fields:

```ruby
api.campaign_management.add_ads(
  ad_group_id: ad_group_id,
  ads: [{
    type: "ResponsiveSearch",
    status: "Paused",
    final_urls: ["https://www.example.com/"],
    headlines: [{asset: {type: "TextAsset", text: "A headline"}}],
    descriptions: [{asset: {type: "TextAsset", text: "A description"}}]
  }]
)
```

#### Keywords, criteria, and budgets

```ruby
keyword = api.campaign_management.add_keywords(
  ad_group_id: ad_group_id,
  keywords: [{
    text: "sdk example keyword",
    match_type: "Exact",
    status: "Paused",
    bid: {amount: 0.10}
  }]
).fetch(:KeywordIds).first

api.campaign_management.update_keywords(
  ad_group_id: ad_group_id,
  keywords: [{id: keyword, status: "Paused", bid: {amount: 0.20}}]
)

api.campaign_management.get_keywords_by_editorial_status(
  ad_group_id: ad_group_id,
  editorial_status: "Active"
)

api.campaign_management.delete_keywords(
  ad_group_id: ad_group_id,
  keyword_ids: [keyword]
)

budget = api.campaign_management.add_budgets(
  budgets: [{name: "SDK example budget", amount: 1, budget_type: "DailyBudgetStandard"}]
).fetch(:BudgetIds).first

api.campaign_management.delete_budgets(budget_ids: [budget])
```

Campaign criteria and ad extensions use the same payload-forwarding style:

```ruby
criterion = api.campaign_management.add_campaign_criterions(
  campaign_criterions: [{
    campaign_id: campaign_id,
    criterion: {type: "LocationCriterion", location_id: 190},
    status: "Active",
    type: "NegativeCampaignCriterion"
  }],
  criterion_type: "Targets"
)

extension = api.campaign_management.add_ad_extensions(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  ad_extensions: [{type: "CalloutAdExtension", text: "SDK example"}]
)
```

### UET tags and conversion goals

UET tags and conversion goals do not have delete operations in the Microsoft API. Use an approved controlled account and retain or deactivate test resources deliberately.

```ruby
uet_response = api.campaign_management.add_uet_tags(
  uet_tags: [{name: "SDK example UET tag", description: "SDK integration test"}]
)
uet_tag_id = uet_response.fetch(:UetTagIds).first

api.campaign_management.update_uet_tags(
  uet_tags: [{id: uet_tag_id, name: "SDK example UET tag updated", description: "Updated"}]
)

goal_response = api.campaign_management.add_conversion_goals(
  conversion_goals: [{
    name: "SDK example conversion goal",
    conversion_window: 30,
    goal_category: "Other",
    goal_type: "Event",
    revenue: {type: "NoRevenue"},
    scope: "AllPages",
    status: "Active",
    tag_id: uet_tag_id
  }]
)
goal_id = goal_response.fetch(:ConversionGoalIds).first

api.campaign_management.get_conversion_goals_by_ids(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  conversion_goal_ids: [goal_id]
)
```

### Ad extensions and shared entities

```ruby
call_extension = api.campaign_management.add_ad_extensions(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  ad_extensions: [{
    type: "CallAdExtension",
    country_code: "FR",
    is_call_only: false,
    phone_number: "+33155555555"
  }]
)

sitelink_extension = api.campaign_management.add_ad_extensions(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  ad_extensions: [{
    type: "SitelinkAdExtension",
    description1: "Description one",
    description2: "Description two",
    display_text: "Visit our site",
    final_urls: ["https://www.example.com/"],
    tracking_url_template: "{lpurl}"
  }]
)

api.campaign_management.get_ad_extensions_by_ids(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  ad_extension_ids: [call_extension.fetch(:AdExtensionIdentities).first.fetch(:Id)],
  ad_extension_type: "CallAdExtension"
)
```

Shared lists and list items can be managed through the generic helpers. Delete list items before deleting their shared entity.

```ruby
list = api.campaign_management.add_shared_entity(
  shared_entity: {name: "SDK example exclusion list", type: "NegativeKeywordList"},
  list_items: [{type: "NegativeKeyword", text: "example", match_type: "Exact"}],
  shared_entity_scope: "Account"
)
shared_entity_id = list.fetch(:SharedEntityId)

api.campaign_management.get_list_items_by_shared_list(
  shared_entity_id: shared_entity_id,
  shared_entity_scope: "Account",
  shared_entity_type: "NegativeKeywordList"
)

api.campaign_management.delete_shared_entities(
  shared_entities: [{id: shared_entity_id, type: "NegativeKeywordList"}],
  shared_entity_scope: "Account"
)
```

### Bulk API

Bulk operations are asynchronous and use a file-transfer URL. Build the upload content with `BulkFileBuilder`, poll until the operation is complete, and parse result files with `BulkFileReader`.

```ruby
upload = api.bulk.get_bulk_upload_url(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  compress_upload: false,
  account_upload_scope: "Customer",
  entities: ["Campaigns"]
)

content = BingAdsRubySdk::BulkFileBuilder.new
  .add_campaign(name: "SDK bulk campaign", status: "Paused", budget: 1)
  .to_s

upload_result = JSON.parse(
  api.bulk.upload_file(
    upload_url: upload.fetch(:UploadUrl),
    content: content,
    filename: "sdk-campaign.csv"
  ),
  symbolize_names: true
)

status = api.bulk.get_bulk_upload_status(
  request_id: upload_result.fetch(:RequestId)
)

if status[:ResultFileUrl]
  rows = BingAdsRubySdk::BulkFileReader
    .new(api.bulk.download_file(url: status[:ResultFileUrl]))
    .to_csv
end
```

For a long-running upload, poll `get_bulk_upload_status` until `Completed`, `CompletedWithErrors`, or `Failed`. `BulkFileReader#to_csv` handles plain CSV, GZIP, ZIP, UTF-8 BOMs, and Microsoft Reporting metadata.

Pass an instrumentation callback to listen to the complete parsing lifecycle and report events to the telemetry service of your choice. The callback receives either a decode lifecycle event hash or a final parsing summary hash, depending on the phase being reported:

```ruby
instrumentation = lambda do |metrics|
  event_name = metrics.fetch(:event, metrics.fetch(:operation))

  remote_metrics_client.record(
    "bulk_file.#{event_name}",
    metrics
  )

  case metrics[:event]
  when :decode_start
    puts "Decoding #{metrics[:compression]} input"
  when :unzip_finish, :gunzip_finish
    puts "Decompressed #{metrics[:input_bytes]} bytes to #{metrics[:output_bytes]} bytes"
  when :decode_finish
    puts "Decode completed in #{metrics[:duration_ms]} ms"
  end
end

chunks = api.bulk.download_file(
  url: status.fetch(:ResultFileUrl),
  stream: true
)

BingAdsRubySdk::BulkFileReader
  .new(chunks, instrumentation: instrumentation)
  .each_row do |row|
    process_row(row)
  end
```

Events include `:decode_start`, `:decode_finish`, `:unzip_finish`, `:gunzip_finish`, and the final `:each_row` summary. The summary contains wall-clock time, process CPU time, process maximum RSS before and after parsing, and RSS delta. Decode events contain `compression`, `input_bytes`, `output_bytes`, `duration_ms`, `success`, and `error_class` when applicable. Use `to_csv` instead of `each_row` when you need a `CSV::Table`. Use `download_file` without `stream: true` when you want the existing buffered download behavior. Instrumentation failures are ignored so telemetry cannot interrupt parsing.

### Reporting API

Reporting uses submit/poll/download. The poll response may be `Pending` or `InProgress` before `Success`. A successful report can still have no download URL when no data is available.

```ruby
submission = api.reporting.submit_generate_report(
  report_request: {
    type: "AccountPerformanceReportRequest",
    format: "Csv",
    format_version: "2.0",
    report_name: "SDK account performance",
    return_only_complete_data: true,
    aggregation: "Daily",
    columns: ["TimePeriod", "AccountId", "Impressions", "Clicks", "Spend"],
    scope: {account_ids: [ENV.fetch("BING_ACCOUNT_ID")]},
    time: {
      custom_date_range_start: {year: 2026, month: 8, day: 1},
      custom_date_range_end: {year: 2026, month: 9, day: 3},
      report_time_zone: "PacificTimeUSCanadaTijuana"
    }
  }
)

request_id = submission.fetch(:ReportRequestId)
report_status = nil

20.times do
  report_status = api.reporting
    .poll_generate_report(report_request_id: request_id)
    .fetch(:ReportRequestStatus)
  break if %w[Success Error Failed].include?(report_status[:Status])
end

raise "Report did not complete" unless report_status[:Status] == "Success"

if report_status[:ReportDownloadUrl]
  rows = BingAdsRubySdk::BulkFileReader
    .new(api.reporting.download_file(url: report_status[:ReportDownloadUrl]))
    .to_csv

  rows.each do |row|
    puts row["TimePeriod"]
    puts row["Clicks"]
    puts row["Impressions"]
    puts row["Spend"]
  end
end
```

### Customer Billing

Customer Billing provides read operations and insertion-order mutations. Billing writes require the appropriate billing permissions and should be tested only with approved data.

```ruby
api.customer_billing.get_account_monthly_spend(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  month: 9,
  year: 2026
)

api.customer_billing.get_billing_documents_info(
  account_id: ENV.fetch("BING_ACCOUNT_ID")
)

api.customer_billing.search_insertion_orders(
  account_id: ENV.fetch("BING_ACCOUNT_ID"),
  predicates: [],
  page: {index: 0, size: 25}
)
```

### Error handling

The JSON client raises `ApiError` when Microsoft returns a non-empty error array. Inspect the category and errors without logging credentials or access tokens:

```ruby
begin
  api.campaign_management.add_campaigns(account_id: account_id, campaigns: campaigns)
rescue BingAdsRubySdk::Services::Json::ApiError => error
  warn error.message
  raise
end
```

### Testing JSON integrations

The repository uses RSpec, VCR, and WebMock for JSON integration coverage. Normal test runs replay checked-in cassettes without network access:

```shell
bundle exec rspec spec/integration/json_api
```

To record a new cassette, use a developer-generated OAuth store and load `.env` in the same shell. Record only approved read operations or disposable paused resources, clean up child resources before parents, and never commit `.env`, token stores, or unredacted cassettes:

```shell
set -a
. ./.env
set +a
BING_STORE_FILENAME=production_token.json \
VCR_RECORD=once bundle exec rspec spec/integration/json_api/reporting_spec.rb
```

The SOAP examples under `spec/examples/` remain useful for legacy SOAP behavior. The JSON equivalents live under `spec/integration/json_api/` and are the preferred reference for REST payloads and response shapes.

### Configuration
```ruby
BingAdsRubySdk.configure do |conf|
  conf.log = true
  conf.logger.level = Logger::DEBUG
  conf.pretty_print_xml = true
  # to filter sensitive data before logging
  conf.filters = ["AuthenticationToken", "DeveloperToken"]
  
  # Optionally allow ActiveSupport::Notifications to be emitted by Excon.
  # These notifications can then be sent on to your profiling system
  # conf.instrumentor = ActiveSupport::Notifications 
end
```

### Account creation and management
If you want to create an account using the API:
```ruby
soap_api.customer_management.signup_customer(
  parent_customer_id: parent_customer_id,
  customer: customer_data, # a hash with your params
  account: account_data.merge("@type" => "AdvertiserAccount")
)
```

Otherwise you can [use existing account IDs as explained here](https://learn.microsoft.com/en-us/advertising/guides/get-started?view=bingads-13#get-ids),
or use the `customer_management` endpoint as explained above.

Once you have your MS Advertising customer and account ids:
```ruby
soap_api.set_customer(customer_id: customer_id, account_id: account_id )

soap_api.campaign_management.get_campaigns_by_account_id(account_id: account_id)
```

You'll see services like `customer_management` implement some methods, but not all the ones available in the API.

The methods implemented contain additional code to ease data manipulation but any endpoint can be reached using `call` on a service.

```ruby
@cm = soap_api.customer_management

@cm.call(:find_accounts_or_customers_info, filter: 'name', top_n: 1)
# => { account_info_with_customer_data: { account_info_with_customer_data: [{ customer_id: "250364751", :

# VS method dedicated to extract data

@cm.find_accounts_or_customers_info(filter: 'name', top_n: 1)
# => [{ customer_id: "250364731" ...

```

### Reporting
You can generate the report following the 
[process recommended by Microsoft](https://learn.microsoft.com/en-us/advertising/guides/request-download-report?view=bingads-13):

That would mean coding something like this:

```ruby
submission_response = soap_api.reporting
  .call(:submit_generate_report,
     account_performance_report_request: {
       exclude_report_header: true,
       exclude_report_footer: true,
       exclude_column_headers: true,
       format: "Csv",
       aggregation: "Daily",
       filter: nil,
       columns: [
         {
           account_performance_report_column: "TimePeriod"
         },
         {
           account_performance_report_column: "AccountId"
         },
         {
           account_performance_report_column: "DeviceType"
         },
         {
           account_performance_report_column: "Clicks"
         }
       ],
       scope: {
         # Your account ID here
         account_ids: [{long: 1000000}]
       },
       time: {
         custom_date_range_start: {
           day: 7,
           month: 5,
           year: 2023
         },
         custom_date_range_end: {
           day: 8,
           month: 5,
           year: 2023
         }
       }
     }
  )

report_request_id = submission_response.fetch(:report_request_id)

# Then you can poll the API to check the status of the report generation
poll_response = soap_api.reporting.call(:poll_generate_report, report_request_id: report_request_id)

# When it is ready you can download it
report_request_status = poll_response.fetch(:report_request_status)

report_generation_status = report_request_status[:status].downcase.to_sym 
# => One of these: :pending, :error, :success

if report_generation_status == :success
  url = report_request_status[:report_download_url]
  # => The URL to download the report (with the library of your choice)
end
```

🛈 Report request example [here in the API docs](https://learn.microsoft.com/en-us/advertising/reporting-service/accountperformancereportrequest?view=bingads-13)

🛈 Hint: convert parameter names from PascalCase to snake_case when consulting the API docs

## Development
You can run `bin/console` for an interactive prompt that will allow you to experiment.

To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git
commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Updating to a new Bing API version
Bing regularly releases new versions of the API and removes support for old versions.
When you want to support a new version of the API, here are some of the things that
need to be changed:
* Go to https://docs.microsoft.com/en-us/bingads/guides/migration-guide to see what has changed
* Set the default SDK version in lib/bing_ads_ruby_sdk/version.rb

### Specs
After checking out the repo, run `bin/setup` to install dependencies. Then, run 
`rake spec` to run unit tests. 

If you want to run the integration tests they are in the `spec/examples/` 
folders. Remember that these will create real accounts and entities in Microsoft
Advertising so take care to check your account spending settings.

Here's how to run the tests:
* Make sure you have the token as described above
* Put your Client ID, Developer Token, and Parent Customer ID in the methods 
    with the same names in `spec/examples/examples.rb`
* Run the specs in order, for example:
  * `bundle exec rspec spec/examples/1_...`, at the end of the spec there will be
    a message at the end about copying an ID into `spec/examples/examples.rb`
  * `bundle exec rspec spec/examples/2_...` 
  * keep repeating until you have run all the specs in `spec/examples`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Effilab/bing_ads_ruby_sdk.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
