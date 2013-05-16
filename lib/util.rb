require 'tempfile'
require "stringio"

module Alloy
  class CompileError < StandardError; end
end

module Util
  module_function

  def capture_stderr &block
    real_stderr, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = real_stderr
  end

  def compile!(type, source, options = {})
    compiled = case type.to_sym
      when :sass, :scss
        begin
          Sass.compile(source, 
            syntax: type.to_sym, 
            cache: true
          )
        rescue Sass::SyntaxError => e
          raise Alloy::CompileError, e.message
        end
      when :less
        file = Tempfile.new('source')
        file.write source
        file.close

        output = `./node_modules/.bin/lessc #{file.path} 2>&1`

        if $?.to_i > 0
          raise Alloy::CompileError, output
        else
          output
        end
      when :stylus
        begin
          Stylus.compile source
        rescue ExecJS::ProgramError => e
          raise Alloy::CompileError, e.message
        end
      when :css
        source
      else
        halt 400, "Unknown type requested."
    end
    compiled = Util.compress!(compiled) if options[:compress] == "true"
    compiled
  end

  def compress!(source)
    YUI::CssCompressor.new.compress(source)
  end
end