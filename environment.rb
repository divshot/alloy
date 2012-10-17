ENV['RACK_ENV'] ||= 'development'
VALID_TYPES = %w(css sass scss less stylus)

require 'bundler'
Bundler.setup :default, (ENV['RACK_ENV'] || 'development').to_sym

require 'sass'
require 'compass'
require 'stylus'
require 'sinatra'
require 'rack/throttle'
require 'securerandom'
require 'redis'
require 'mongo_mapper'
require 'yui/compressor'
require 'aws/s3'

require 'url2png'

paths = Sass::Engine::DEFAULT_OPTIONS[:load_paths]
paths << Compass::Frameworks[:compass].stylesheets_directory


Url2png.config({
  api_key: ENV['URL2PNG_KEY'],
  private_key: ENV['URL2PNG_SECRET']
})
Url2png.default_size = "320x180"

Stylus.use(:nib)

if ENV['REDISTOGO_URL']
  uri = URI.parse(ENV["REDISTOGO_URL"])
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  $redis = Redis.new
end

if ENV['MONGOHQ_URL']
  MongoMapper.config = { ENV['RACK_ENV'] => { 'uri' => ENV['MONGOHQ_URL'] } }
else
  MongoMapper.config = { ENV['RACK_ENV'] => { 'database' => "alloy_#{ENV["RACK_ENV"]}" } }
end
MongoMapper.connect(ENV['RACK_ENV'])

if ENV['S3_KEY']
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['S3_KEY'],
    :secret_access_key => ENV['S3_SECRET']
  )
end

$:.unshift File.dirname(__FILE__)
require 'lib/throttle'
require 'lib/util'

require 'models/package'
require 'models/build'
require 'models/quickshot'

require 'app'