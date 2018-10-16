# BingAdsRubySdk

## Installation

Add the following to your application's Gemfile:

```ruby
# You currently need to use this version of lolsoap:
gem 'lolsoap', github: 'effilab/lolsoap', branch: 'edge'

gem 'bing_ads_ruby_sdk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bing_ads_ruby_sdk

## Usage
### Configure the app
```ruby
BingAdsRubySdk.logger.level = :debug

# This is optionnal, if you already have a token,
# You can set a file directly to the store:
BingAdsRubySdk::OAuth2::FsStore.config = "credentials.json"

@api ||= BingAdsRubySdk::Api.new(
  oauth_store: BingAdsRubySdk::OAuth2::FsStore,
  credentials: {
    developer_token: '123abc',
    client_id:       '1a-2b-3c'
  }
).tap do |api|
  api.customer(
    id:         123,
    account_id: 456
  )
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

You should provide a replacement for the `BingAdsRubySdk::OAuth2::FsStore` OAuth token store (oauth_store) when initialising the BingAdsRubySdk::Api class. All you need to know should be in the gem documentation.

You can use the RedisStore this way:


```ruby
BingAdsRubySdk.logger.level = :debug

# Set the Redis connection
$redis = Redis.new
BingAdsRubySdk::OAuth2::Store::RedisStore.redis = $redis

@api ||= BingAdsRubySdk::Api.new(
  oauth_store: BingAdsRubySdk::OAuth2::Store::RedisStore,
  credentials: {
    developer_token: '123abc',
    client_id:       '1a-2b-3c'
  }
).tap do |api|
  api.customer(
    id:         123,
    account_id: 456
  )
end
```



Please see `spec/examples/` for a number of examples on how to use the SDK

### Bootsrap Authorization code flow
Before you can connect to the Bing Ads API you need to make an authentication
token available to the SDK. Here's how to do it:

* Follow Bing Ads documentation to setup a native app
  * https://msdn.microsoft.com/en-us/library/bing-ads-user-authentication-oauth-guide(v=msads.100).aspx

* Run the token generator and follow the instructions

```
$ bing_ads_token_from_code

$ cat .token* # Should output something like this: {"access_token":"....
```

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

### Generating the cache
The gem parses the WSDL provided by Bing to generate stubs. These are stored as serialized objects
in the .cache folder. `Marshal.dump` is used so this means that you can use the generated cache
stored in the repository if you are using the same Major version of Ruby as was used to build the cache.

If you need to use another major version of Ruby or you want to prepare the gem for use with another
version of the Bing Ads API, you will need to regenerate that cache. Here's how to do that.

Add the gem tasks in your project Rakefile

```ruby
import 'tasks/bing_ads_ruby_sdk.rake'
```

```shell
bundle exec rake -T
rake bars:cache:build  # Build cache
rake bars:cache:check  # Check cache
rake bars:cache:clear  # Clear cache
rake bars:cache:reset  # Reset cache : clear, build and check
```
The safest thing to do is to reset the cache.

### Specs
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

You can run tests using the following : `bundle exec rake`

If you wish to run full example tests please understand that this will pollute
any account that you use, so perhaps it would be best not to use an account with
payment information attached.

Currently the credentials are accessed by the example tests using environment
variables so you will need to set these first. This could be achieved using
[Direnv](https://direnv.net/), or `source my_exports.sh`, or just exporting values at the command line.

Here is an example:
```
export ACCEPTANCE_CUSTOMER_ID=<YOUR CUSTOMER ID>
export ACCEPTANCE_ACCOUNT_ID=<YOUR ACCOUNT ID>
export ACCEPTANCE_USER_ID=<YOUR USER ID>
export ACCEPTANCE_DEVELOPER_TOKEN=<YOUR DEVELOPER TOKEN>
export ACCEPTANCE_CLIENT_ID=<YOUR CLIENT ID>

bundle exec rspec spec/examples
```

To release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git
commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Effilab/bing_ads_ruby_sdk.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
