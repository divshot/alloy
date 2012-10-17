require 'rack/cors'

require 'logger'
class AppLogger < Logger
  alias write <<
end
$logger = AppLogger.new(STDOUT)
$logger.level = Logger::Severity::DEBUG
use Rack::CommonLogger, $logger

use Rack::Cors do
  allow do
    origins '*'
    resource '/compile/*', :headers => :any, :methods => [:post]
    resource '/builds', :headers => :any, :methods => [:post]
    resource '/shots', :headers => :any, :methods => [:post]
  end
end

require './environment'

require './assets'
map '/assets' do
  run Assets
end

run Alloy::App