class Build
  include MongoMapper::EmbeddedDocument

  key :name, String, required: true
  key :label, String, required: true
  key :styles, Array, default: []
  key :default, Boolean, default: false

  embedded_in :package

  def compile(options = {})
    contents = styles.map{|style_name|
      style = package.style(style_name)
      
      if style_name == "{variables}"
        out = ""
        out << "//\n// Alloy Variables\n// ---------------------------------------------------\n\n"
        out << package.compile_variables(options["variables"] || {})
      elsif style
        out = style.content
      end
      
      out
    }

    contents.join("\n\n")
  end
end