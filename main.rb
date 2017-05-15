if ENV['RACK_ENV'] != 'production'
	require 'dotenv/load'
end

require 'telegramAPI'
require 'sinatra'
require 'json'

api = TelegramAPI.new ENV['TG_API_TOKEN'].to_s

post "/#{ENV['TG_WEBHOOK_TOKEN']}" do
  status 200

  # Get Telegram Data
  request.body.rewind
  body = request.body.read
  data = body.length >= 2 ? JSON.parse(body) : nil

  # Output data on stdout
  p data
  # {
  #   "update_id"=>341826966,
  #   "message"=>{
  #     "message_id"=>2,
  #     "from"=>{
  #       "id"=>123456789,
  #       "first_name"=>"Deuteu",
  #       "last_name"=>"Deuteu",
  #       "username"=>"Deuteu"
  #     },
  #     "chat"=>{
  #       "id"=>123456789,
  #       "first_name"=>"Deuteu",
  #       "last_name"=>"Deuteu",
  #       "username"=>"Deuteu",
  #       "type"=>"private"
  #     },
  #     "date"=>1494875758,
  #     "text"=>"test"
  #   }
  # }
  if data["message"]
    api.sendMessage(data["message"]["chat"]["id"], data["message"]["text"])
  end

  # Return an empty json, to say "ok" to Telegram
  content_type :json
  {}.to_json
end

#HEROKU_APP_NAME missing so do it manually
#r = api.setWebhook("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com/#{ENV['TG_WEBHOOK_TOKEN']}").to_json
#puts "setWebhook Result: #{r}" 