require 'sprockets'
require 'compass'
require 'sprockets-sass'
require 'sprockets-helpers'
require 'coffee-script'

Assets = Sprockets::Environment.new
  Assets.append_path 'assets/javascripts'
  Assets.append_path 'assets/stylesheets'
  Assets.append_path 'vendor/assets/javascripts'
  Assets.append_path 'vendor/assets/stylesheets'