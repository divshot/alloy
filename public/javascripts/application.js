$(function() {
  var editor = ace.edit($("#editor")[0]);
  editor.setTheme("ace/theme/vibrant_ink");
  editor.setShowPrintMargin(false);
  editor.renderer.setShowGutter(false);
  editor.session.setTabSize(2);

  var setType = function(type) {
    editor.session.setValue($("#" + type + "-default").html());
  }
  setType("sass");

  $("input[name=type]").change(function() {
    setType($("input[name=type]:checked").val());
  });

  $("form").submit(function(e) {
    e.preventDefault();
    var url = "/compile/" + $("input[name=type]:checked").val()
    var data = {source: editor.session.getValue() }
    if ($("#field_compress").is(":checked")) data.compress = true;
    $.ajax({
      url: url,
      type: 'POST',
      dataType: "text",
      data: data,
      success: function(text) {
        $("#result").show().find("code").text(text);
        Prism.highlightAll();
      }
    });
  });
});