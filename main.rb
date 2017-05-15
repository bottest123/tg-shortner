if ENV['RACK_ENV'] != 'production'
	require 'dotenv/load'
end

require 'telegramAPI'
require 'sinatra'
require 'json'

get "/#{ENV['TG_WEBHOOK_TOKEN']}" do
  status 200

  # Get Telegram Data
  request.body.rewind
  body = request.body.read
  data = body.length >= 2 ? JSON.parse(body) : nil

  # Output data on stdout
  p data

  # Return an empty json, to say "ok" to Telegram
  content_type :json
  {}.to_json
end

#HEROKU_APP_NAME missing so do it manually
#r = api.setWebhook("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com/#{ENV['TG_WEBHOOK_TOKEN']}").to_json
#puts "setWebhook Result: #{r}" 