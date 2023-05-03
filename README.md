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
api = BingAdsRubySdk::Api.new(
  oauth_store: store,
  developer_token: 'your_dev_token',
  client_id: 'your_bing_client_id'
)
```

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
api.customer_management.signup_customer(
  parent_customer_id: parent_customer_id,
  customer: customer_data, # a hash with your params
  account: account_data.merge("@type" => "AdvertiserAccount")
)
```

Otherwise you can [use existing account IDs as explained here](https://learn.microsoft.com/en-us/advertising/guides/get-started?view=bingads-13#get-ids),
or use the `customer_management` endpoint as explained above.

Once you have your MS Advertising customer and account ids:
```ruby
api.set_customer(customer_id: customer_id, account_id: account_id )

api.campaign_management.get_campaigns_by_account_id(account_id: account_id)
```

You'll see services like `customer_management` implement some methods, but not all the ones available in the API.

The methods implemented contain additional code to ease data manipulation but any endpoint can be reached using `call` on a service.

```ruby
@cm = api.customer_management

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
submission_response = api.reporting.submit_generate_report(
  account_report_request: {
    aggregation: 'Daily',
    columns: %w[...],
    scope: { account_ids: [account_id] },
    time: { 
      custom_date_range_start: {
        day: 1,
        month: 1, 
        year: 2019
      },
      custom_date_range_end: {
        # ...
      }
    }
  }
)

report_request_id = submission_response.fetch(:report_request_id)

# Then you can poll the API to check the status of the report generation
poll_response = api.reporting.poll_generate_report(report_request_id: report_request_id)

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
