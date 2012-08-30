require 'bundler'
Bundler.setup :default, (ENV['RACK_ENV'] || 'development').to_sym

require 'sass'
require 'compass'
require 'less-js'
require 'stylus'
require 'sinatra'
require 'securerandom'
require 'redis'
require 'yui/compressor'

paths = Sass::Engine::DEFAULT_OPTIONS[:load_paths]
paths << Compass::Frameworks[:compass].stylesheets_directory

Stylus.use(:nib)

require './app'
run Chic::App