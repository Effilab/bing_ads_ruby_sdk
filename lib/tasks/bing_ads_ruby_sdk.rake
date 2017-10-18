require 'bing_ads_ruby_sdk/cache'

BingAdsRubySdk.logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity} #{datetime} #{progname} #{msg}".tap do |line|
    puts nil, line
  end
end

namespace :bars do
  namespace :cache do
    desc 'Build cache'
    task :build do
      BingAdsRubySdk::Cache.build
    end

    desc 'Check cache'
    task :check do
      BingAdsRubySdk::Cache.check
    end

    desc 'Clear cache'
    task :clear do
      BingAdsRubySdk::Cache.clear
    end

    desc 'Reset cache'
    task reset: %i[clear build check]
  end
end
