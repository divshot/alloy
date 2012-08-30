require 'bundler'
Bundler.setup :default, (ENV['RACK_ENV'] || 'development').to_sym

require 'sass'
require 'compass'
require 'less-js'
require 'stylus'
require 'sinatra'
require 'rack/throttle'
require 'rack/cors'
require 'securerandom'
require 'redis'
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

require File.dirname(__FILE__) + '/throttle'
require File.dirname(__FILE__) + '/app'