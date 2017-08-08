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

## Usage
### Configure the app
```ruby
BingAdsRubySdk::Logger.level = :debug

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

### Bootsrap Authorization code flow
* Follow Bing Ads documentation to setup a native app
  * https://msdn.microsoft.com/en-us/library/bing-ads-user-authentication-oauth-guide(v=msads.100).aspx
* Follow the bin/token_from_code instructions to generate the token.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Effilab/bing_ads_ruby_sdk.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
