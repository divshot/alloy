class Style
  include MongoMapper::EmbeddedDocument

  key :name, String
  key :type, String
  key :label, String
  key :description, String

  validates_inclusion_of :type, in: ['sass scss less stylus']
end