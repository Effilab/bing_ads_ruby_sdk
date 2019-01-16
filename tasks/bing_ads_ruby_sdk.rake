require 'dotenv/load'

namespace :token do
  desc "Update test config file and store with Bing OAuth2 token"
  task :update do
    store = ::BingAdsRubySdk::OAuth2::Store::FsStore.new(ENV.fetch('BING_TOKEN_NAME'))
    auth = BingAdsRubySdk::OAuth2::AuthorizationCode.new(
      {
        developer_token: ENV.fetch('BING_DEVELOPER_TOKEN'),
        client_id: ENV.fetch('BING_CLIENT_ID')
      },
      store: store
    )

    puts "Go to #{auth.code_url}",
         "You will be redirected to a URL at the end. Paste it here in the console and press enter"

    full_url = STDIN.gets.chomp
    auth.fetch_from_url(full_url)

    puts "Written to store"
  end
end
