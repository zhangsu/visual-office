require 'sinatra'

get '/' do
  haml :index, ugly: true
end
