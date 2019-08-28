require 'dotenv/load'

namespace :bing_token do
  desc "Gets and stores Bing OAuth token in file"
  task :get, [:filename, :bing_developer_token, :bing_client_id, :bing_client_secret] do |task, args|

    filename = args[:filename] || ENV.fetch('BING_STORE_FILENAME')
    developer_token = args[:bing_developer_token] || ENV.fetch('BING_DEVELOPER_TOKEN')
    bing_client_id = args[:bing_client_id] || ENV.fetch('BING_CLIENT_ID')
    bing_client_secret = args[:bing_client_secret] || ENV.fetch('BING_CLIENT_SECRET')

    store = ::BingAdsRubySdk::OAuth2::FsStore.new(filename)
    auth = BingAdsRubySdk::OAuth2::AuthorizationHandler.new(
      developer_token: developer_token,
      client_id: bing_client_id,
      store: store,
      client_secret: bing_client_secret
    )
    puts "Go to #{auth.code_url}",
         "You will be redirected to a URL at the end. Paste it here in the console and press enter"

    full_url = STDIN.gets.chomp
    auth.fetch_from_url(full_url)

    puts "Written to store"
  end
end
