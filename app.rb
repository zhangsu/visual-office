require 'sinatra'

class VisualOffice < Sinatra::Base
  configure :development, :test do
    ENV["REDISTOGO_URL"] = 'redis://localhost:6379'
  end

  configure do
    require 'redis'
    uri = URI.parse(ENV["REDISTOGO_URL"])
    REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  get '/' do
    REDIS.set('foo', 'bar')
    puts RESDIS.get('foo')
    haml :index, ugly: true
  end
end

