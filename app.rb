module Alloy
  class App < Sinatra::Base
    use Alloy::Throttle, max: 100, cache: $redis

    get '/' do
      erb :home
    end

    before{ parse_json_params! if request.content_type == 'application/json' }

    post '/compile' do
      compile! params[:type], params[:source], params
    end

    post '/compile/sass' do
      compile! :sass, params[:source], params
    end

    post '/compile/scss' do
      compile! :scss, params[:source], params
    end

    post '/compile/less' do
      compile! :less, params[:source], params
    end

    post '/compile/stylus' do
      compile! :stylus, params[:source], params
    end

    def parse_json_params!
      json_params = MultiJson.load(request.body.read)
      json_params.each_pair do |k,v|
        params[k] = v
      end
    rescue MultiJson::DecodeError
      halt 400, "Invalid JSON request."
    end

    def compile!(type, source, options = {})
      content_type "text/css"
      compiled = case type.to_sym
        when :sass, :scss
          Sass.compile(source, 
            syntax: type, 
            cache: true
          )
        when :less
          LessJs.compile source
        when :stylus
          Stylus.compile source
        else
          halt 400, "Unknown type requested."
      end
      compiled = YUI::CssCompressor.new.compress(compiled) if options[:compress]

      track_stats!(type, source, options)
      compiled
    end

    def track_stats!(type, source, options)
      $redis.incrby "stats:compiles", 1
      $redis.incrby "stats:bytes_compiled", source.bytesize
      $redis.incrby "stats:lines_compiled", source.lines.count

      $redis.zincrby "stats:types:bytes_compiled", source.bytesize, type.to_s
      $redis.zincrby "stats:types:lines_compiled", source.lines.count, type.to_s
      $redis.zincrby "stats:types:compiles", 1, type.to_s
    end
  end
end