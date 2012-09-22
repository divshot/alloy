require './environment'

require './assets'
map '/assets' do
  run Assets
end

run Alloy::App