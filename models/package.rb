require 'models/variable'
require 'models/style'
require 'models/build'

class Package
  include MongoMapper::Document

  key :name, String, required: true
  key :label, String, required: true
  key :description, String
  key :public, Boolean, default: false
  key :type, String, required: true

  validates_inclusion_of :type, in: VALID_TYPES
  
  many :variables
  many :styles
  many :builds

  def style(name)
    styles.each do |style|
      return style if style.name == name.to_s
    end
    nil
  end

  def build(name)
    builds.each do |build|
      return build if build.name == name.to_s
    end
    nil
  end

  def compile_variables(overrides = {})
    variables.map{|variable|
      variable.render(overrides[variable.name])
    }.join("\n")
  end

  def compile_source(build_name, options = {})
    build(build_name).compile(options)
  end

  def compile(build_name, options = {})
    source = compile_source(build_name, options = {})
    Util.compile!(type, source, options)
  end
end