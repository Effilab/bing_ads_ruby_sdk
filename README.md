# BingAdsRubySdk

## Installation

Add the following to your application's Gemfile:

```ruby
# Once the merge request is approved we will remove github dependence
gem 'lolsoap', github: 'effilab/lolsoap', branch: 'edge'

gem 'bing_ads_ruby_sdk'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bing_ads_ruby_sdk
### Generate the cache
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

## Usage
### Configure the app
```ruby
BingAdsRubySdk.logger.level = :debug

@api ||= BingAdsRubySdk::Api.new(
  oauth_store: MyRedisStore,
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
You can / should provide an other oauth token store on Api init than the default BingAdsRubySdk::OAuth2::FsStore, all you need to know should be in the gem documentation.

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
