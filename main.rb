if ENV['RACK_ENV'] != 'production'
	require 'dotenv/load'
end

require 'sinatra'

require 'json'
require 'uri'

require 'telegramAPI'

api = TelegramAPI.new(ENV['TG_API_TOKEN'].to_s)

def is_admin?(user_id)
  admin_ids = ENV['TG_ADMIN_ID'].to_s.split(';')
  admin_ids << ENV['TG_SUPER_ADMIN_ID'].to_s
  return admin_ids.include?(user_id.to_s)
end

def get_urls(text)
  URI.extract(text.to_s, ['http', 'https'])
end

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
    message = data["message"]
    if message["chat"] && message["chat"]["id"]
      from = message["from"]
      if is_admin?(from["id"])
        if message["text"]
          urls = get_urls(message["text"])
          if urls.empty?
            puts "NoUrl - Message with no urls: #{message["text"]}"
            api.sendMessage(message["chat"]["id"], "No urls.")
          else
            urls.each do |url|
              api.sendMessage(message["chat"]["id"], url)
            end
          end
        else
          puts "EmptyoMessage - Message with no text: #{message}"
        end
      else
        puts "NotAdmin - Message by not admin user: #{from}"
        api.sendMessage(message["chat"]["id"], "My mum told me not to talk to stranger.")
      end
    else
      puts "MissingArgs - No chat id for response: #{data}"
    end
  else
    puts "MissingArgs - No message: #{data}"
  end

  # Return an empty json, to say "ok" to Telegram
  content_type :json
  {}.to_json
end

#HEROKU_APP_NAME missing so do it manually
#r = api.setWebhook("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com/#{ENV['TG_WEBHOOK_TOKEN']}").to_json
#puts "setWebhook Result: #{r}" 