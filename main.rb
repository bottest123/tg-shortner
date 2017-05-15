if ENV['RACK_ENV'] != 'production'
	require 'dotenv/load'
end

require 'sinatra'

require 'json'
require 'uri'

require 'telegramAPI'

puts "App name: #{ENV['HEROKU_APP_NAME']}"

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
  content_type :json
  empty_json = {}.to_json

  # Get Telegram Data
  request.body.rewind
  body = request.body.read
  data = body.length >= 2 ? JSON.parse(body) : nil

  puts "Data received: #{data}"

  unless data["message"]
    puts "MissingArgs - No message: #{data}"
    return empty_json
  end

  message = data["message"]
  unless message["chat"] && message["chat"]["id"]
    puts "MissingArgs - No chat id for response: #{data}"
    return empty_json
  end

  from = message["from"]
  unless is_admin?(from["id"])
    puts "NotAdmin - Message by not admin user: #{from}"
    api.sendMessage(message["chat"]["id"], "My mum told me not to talk to stranger.")
    return empty_json
  end

  unless message["text"]
    puts "EmptyMessage - Message with no text: #{message}"
    return empty_json
  end

  urls = get_urls(message["text"])
  if urls.empty?
    puts "NoUrl - Message with no urls: #{message["text"]}"
    api.sendMessage(message["chat"]["id"], "No urls.")
  else
    urls.each do |url|
      api.sendMessage(message["chat"]["id"], url)
    end
  end

  # Return an empty json, to say "ok" to Telegram
  return {}.to_json
end

#HEROKU_APP_NAME missing so do it manually
#r = api.setWebhook("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com/#{ENV['TG_WEBHOOK_TOKEN']}").to_json
#puts "setWebhook Result: #{r}" 