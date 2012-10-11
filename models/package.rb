require 'models/variable'
require 'models/style'
require 'models/target'

class Package
  include MongoMapper::Document

  key :name, String, required: true
  key :label, String, required: true
  key :version
  key :description, String
  key :public, Boolean, default: false
  key :type, String, required: true

  validates_inclusion_of :type, in: VALID_TYPES
  
  many :variables
  many :styles
  many :targets

  def style(name)
    styles.each do |style|
      return style if style.name == name.to_s
    end
    nil
  end

  def target(name)
    targets.each do |target|
      return target if target.name == name.to_s
    end
    nil
  end

  def variable(name)
    variables.each do |variable|
      return variable if variable.name == name.to_s
    end
    nil
  end

  def version_string
    version.is_a?(Array) ? version.join(".") : version.to_s
  end

  def compile_variables(overrides = {})
    overrides = HashWithIndifferentAccess.new(overrides)

    variables.map{|variable|
      variable.render(overrides[variable.name])
    }.join("\n")
  end

  def compile_source(target_name, options = {})
    options = HashWithIndifferentAccess.new(options)

    target(target_name).compile(options)
  end

  def compile(target_name, options = {})
    options = HashWithIndifferentAccess.new(options)

    source = compile_source(target_name, options)
    Util.compile!(type, source, options)
  end
end