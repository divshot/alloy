require 'tempfile'

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
        file = Tempfile.new('source')
        file.write source
        file.close

        output = `./node_modules/.bin/lessc #{file.path}`
      when :stylus
        Stylus.compile source
      when :css
        source
      else
        halt 400, "Unknown type requested."
    end
    compiled = Util.compress!(compiled) if options[:compress]
    compiled
  end

  def compress!(source)
    YUI::CssCompressor.new.compress(source)
  end
end