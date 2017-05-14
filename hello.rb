require 'dotenv/load'
require 'sinatra'

get '/' do
  "Hello World! #{ENV['test']}"
end
