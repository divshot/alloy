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
      end
    end

    get '/' do
      redirect ENV["HOME_URL"], 301 if ENV["HOME_URL"]
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
            syntax: type.to_sym, 
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