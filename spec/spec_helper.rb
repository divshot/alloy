require File.dirname(__FILE__) + '/../environment'

require 'rack/test'
require 'factory_girl'
require 'pry'

Dir[File.dirname(__FILE__) + "/support/*.rb"].each do |file|
  load file
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include Rack::Test::Methods
  config.include FactoryGirl::Syntax::Methods
end