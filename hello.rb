if ENV['RACK_ENV'] != 'production'
	require 'dotenv/load'
end
require 'sinatra'

get '/' do
  "Hello World! #{ENV['test']}"
end
