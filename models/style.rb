class Style
  include MongoMapper::EmbeddedDocument

  key :name, String, required: true
  key :type, String, required: true
  key :label, String

  key :description, String
  key :content, String

  validates_inclusion_of :type, in: VALID_TYPES

  embedded_in :package

  def label
    self[:label] || name
  end
end