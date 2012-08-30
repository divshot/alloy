module Chic
  class App < Sinatra::Base
    get '/' do
      erb :home
    end

    before{ parse_json_params! if request.content_type == 'application/json' }

    post '/compile/sass' do
      output_style = (params[:output_style] || "nested").to_sym
      
      content_type "text/css"
      Sass.compile(params[:source], 
        syntax: :sass, 
        cache: true,
        style: output_style
      )
    end

    post '/compile/scss' do
      output_style = (params[:output_style] || "nested").to_sym
      
      content_type "text/css"
      Sass.compile(params[:source], 
        syntax: :scss, 
        cache: true,
        style: output_style
      )
    end

    post '/compile/less' do
      content_type "text/css"
      LessJs.compile params[:source]
    end

    post '/compile/stylus' do
      content_type "text/css"
      Stylus.compile params[:source]
    end

    def parse_json_params!
      json_params = MultiJson.load(request.body.read)
      json_params.each_pair do |k,v|
        params[k] = v
      end
    rescue MultiJson::DecodeError
      halt 400, "Invalid JSON request."
    end
  end
end