#= require "spine.js"

$ ->
  class Style extends Spine.Model
    @configure 'Style', 'name', 'type', 'content'

    @fromFile: (filename, content)=>
      parts = filename.split(".")
      type = parts.pop()
      name = parts.join('.')

      new Style
        id: name
        name: name
        type: type.toLowerCase()
        content: content

  class StyleList extends Spine.Controller
    el: $("#style-list")
    constructor: ->
      super
      Style.bind 'change', @render

    render: =>
      @el.html ''
      Style.each (style)=>
        listing = $ """
          <div class='style'>
            <input type='text' name='name[]' value='#{style.name}' class='input-large'/>
            <select name='types[]' class='input-small'>
              <option value='css'>CSS</option>
              <option value='sass'>SASS</option>
              <option value='scss'>SCSS</option>
              <option value='less'>LESS</option>
              <option value='stylus'>Stylus</option>
            </select>
            <textarea name='content[]'>#{style.content}</textarea>
          </div>
        """
        listing.find("select").val(style.type)

        @el.append listing

  $('#files').on 'change', (e)->
    files = e.currentTarget.files;

    for file in files
      ((file)->
        reader = new FileReader();
        reader.onload = (e)=>
          Style.fromFile(file.name, e.target.result).save()
        reader.readAsText(file)
      )(file)

  new StyleList()
  window.Style = Style