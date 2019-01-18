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

## Getting Started

In order to use Bing's api you need to get your api credentials from bing. From there them gem handles the oauth token generation.

By default, there is only one store in the gem to store the oauth token. It's a filesystem based store. You can create yourself to store credentials in database or wherever you desire. The store class must implement `read` and `write(data)` instance methods.

To get your token, run:
```ruby
rake bing_token:get[my_token.json,your_dev_token,your_bing_client_id]

```


Then to use the api:
```ruby
store = ::BingAdsRubySdk::OAuth2::FsStore.new('my_token.json')
api = BingAdsRubySdk::Api.new(
  oauth_store: store,
  credentials: {
    developer_token: 'your_dev_token',
    client_id: 'your_bing_client_id'
  }
)
api.customer_management.find_accounts_or_customers_info(
  filter: 'name',
  top_n: 1
)
```

## Configure the gem
```ruby
BingAdsRubySdk.configure do |conf|
  conf.log = true
  conf.logger.level = Logger::DEBUG
  conf.pretty_print_xml = true
  # to filter sensitive data before logging
  conf.filters = ["AuthenticationToken", "DeveloperToken"]
end
```

In `credentials.json` you should have:
```json
{
  "access_token": "ABCD",
  "refresh_token": "JT4HhmS",
  "issued_at": "2018-03-08 14:52:04 +0100",
  "expires_in": 3600
}
```

Please see `spec/bing_ads_ruby_sdk/services` for a number of examples on how to use the SDK

## Development

### Updating to a new Bing API version
Bing regularly releases new versions of the API and removes support for old versions.
When you want to support a new version of the API, here are some of the things that
need to be changed:
* Go to https://docs.microsoft.com/en-us/bingads/guides/migration-guide to see what has changed
* Add a new v*.yml config file to lib/bing_ads_ruby_sdk/config/
  * The migration guide will tell you what endpoints to use in the new configuration file
* Generate the cache files for the new version as detailed below
* Set the default SDK version in lib/bing_ads_ruby_sdk/version.rb
* Update the list of supported versions in lib/bing_ads_ruby_sdk/configuration.rb
* Run the integration tests using `bundle exec rspec spec/examples/`, and fix the tests

If you want to remove support for a version of the API:
* Remove the version from the versions list in lib/bing_ads_ruby_sdk/configuration.rb
* Remove the config file for the version in lib/bing_ads_ruby_sdk/config/
* Remove the cache folder for the version in lib/bing_ads_ruby_sdk/.cache/

### Specs
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git
commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Effilab/bing_ads_ruby_sdk.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
