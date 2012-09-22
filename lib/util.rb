module Util
  module_function

  def compile!(type, source, options = {})
    compiled = case type.to_sym
      when :sass, :scss
        Sass.compile(source, 
          syntax: type.to_sym, 
          cache: true
        )
      when :less
        Less::Parser.new.parse(source).to_css
      when :stylus
        Stylus.compile source
      else
        halt 400, "Unknown type requested."
    end
    compiled = YUI::CssCompressor.new.compress(compiled) if options[:compress]
    compiled
  end
end