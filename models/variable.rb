class Variable
  include MongoMapper::EmbeddedDocument

  key :name, String, required: true
  key :label, String, required: true
  key :type, String
  key :default

  validates_inclusion_of :type, in: %w(text font color gradient)
end