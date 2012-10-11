require 'digest/sha1'

module Alloy
  class App < Sinatra::Base
    configure :production do
      use Alloy::Throttle, max: 100, cache: $redis
    end

    helpers do
      def bookmarklet_code(type)
        source = <<-JS
        javascript:(function(e,a,g,h,f,c,b,d){if(!(f=e.jQuery)||g>f.fn.jquery||h(f)){c=a.createElement("script");c.type="text/javascript";c.src="http://ajax.googleapis.com/ajax/libs/jquery/"+g+"/jquery.min.js";c.onload=c.onreadystatechange=function(){if(!b&&(!(d=this.readyState)||d=="loaded"||d=="complete")){h((f=e.jQuery).noConflict(1),b=1);f(c).remove()}};a.documentElement.childNodes[0].appendChild(c)}})(window,document,"1.3.2",function($,L){$("body").append("<div id='divshot-alloy-message' style='-webkit-border-radius: 4px; border-radius: 4px; position:fixed; font-size: 18px; bottom: 15px; left: 50%; margin-left: -300px; background: rgba(0,0,0,0.75); padding: 4px 10px; width: 600px; text-align: center; font-family: sans-serif; color: white;'>Click any textarea element to compile #{type} into CSS</div>");var action=function(){$("*").unbind("click",action);$("#divshot-alloy-message").remove();if($(this).is("textarea")){var a=$(this);var b=$(this).val();a.val("Compiling, please wait...");$.ajax({type:"POST",dataType:"text",url:"http://alloy.divshot.com/compile",data:{source:b,type:"#{type.downcase}",},success:function(c){a.val(c)},error:function(){alert("Something went wrong.");a.val(b)}})}else{alert("You didn't click a textarea.")}return false};$("*").bind("click",action);});
        JS
        Rack::Utils.escape_html(source.strip)
      end
    end

    use Rack::Cors do
      allow do
        origins '*'
        resource '/compile*', :headers => :any, :methods => :post
        resource '/builds*', :headers => :any, :methods => :post
      end
    end

    get '/' do
      redirect ENV["HOME_URL"], 301 if ENV["HOME_URL"]
      erb :home
    end

    get '/packages/new' do
      erb :package_form
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

    post '/builds' do
      halt 400 unless params[:type] && params[:source]

      build = Build.new(params[:type], params[:source])
      build.store!

      content_type 'application/json'
      MultiJson.dump(build.serializable_hash)
    end

    def compile_options_from_params(package, params)
      out = {}
      params.each_pair do |k,v|
        if %w(compress).include? k
          out[k] = v
        elsif package.variable(k)
          (out["variables"] ||= {})[k] = v
        end
      end
      out
    end

    get '/packages/:name/source/:target' do
      content_type "text/plain"
      package = Package.find_by_name(params[:name])
      package.compile_source(params[:target], compile_options_from_params(package, params))
    end

    get '/packages/:name/compile/:target' do
      content_type "text/css"
      package = Package.find_by_name(params[:name])
      package.compile(params[:target], compile_options_from_params(package, params))
    end

    get '/packages/:name/build/:target' do
      content_type "text/css"
      package = Package.find_by_name(params[:name])
      
      source = package.compile_source(params[:target], compile_options_from_params(package,params))
      build = Build.new(package.type, source, "#{package.name}/#{package.version_string}/#{params[:target]}")
      build.store!

      content_type 'application/json'
      MultiJson.dump(build.serializable_hash)
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
      compiled = Util.compile!(type, source, options)
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