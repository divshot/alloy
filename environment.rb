ENV['RACK_ENV'] ||= 'development'
VALID_TYPES = %w(css sass scss less stylus)

require 'bundler'
Bundler.setup :default, (ENV['RACK_ENV'] || 'development').to_sym

require 'sass'
require 'compass'
require 'less'
require 'stylus'
require 'sinatra'
require 'rack/throttle'
require 'rack/cors'
require 'securerandom'
require 'redis'
require 'mongo_mapper'
require 'yui/compressor'

paths = Sass::Engine::DEFAULT_OPTIONS[:load_paths]
paths << Compass::Frameworks[:compass].stylesheets_directory

Stylus.use(:nib)

if ENV['REDISTOGO_URL']
  uri = URI.parse(ENV["REDISTOGO_URL"])
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  $redis = Redis.new
end

MongoMapper.config = { ENV['RACK_ENV'] => { 'uri' => ENV['MONGOHQ_URL'] } }
MongoMapper.connect(ENV['RACK_ENV'])

$:.unshift File.dirname(__FILE__)
require 'lib/throttle'
require 'lib/util'
require 'models/package'
require 'app'