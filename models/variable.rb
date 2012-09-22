class Variable
  include MongoMapper::EmbeddedDocument

  key :name, String, required: true
  key :label, String
  key :type, String, required: true, default: "text"
  key :default, String

  validates_inclusion_of :type, in: %w(text font color gradient dimension)

  embedded_in :package
  
  def label
    self[:label] || self.name
  end

  def render(val = nil)
    if val || default
      "@#{name}: #{val || default};"
    else
      ""
    end
  end
end