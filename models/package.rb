require 'models/variable'
require 'models/style'

class Package
  include MongoMapper::Document

  key :name, String, required: true
  key :slug, String, required: true
  key :description, String
  key :public, Boolean, default: false

  validates_inclusion_of :type, in: %w(sass scss less stylus)

  many :variables
  many :styles

  def compile(variables = {})

  end
end