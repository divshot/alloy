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
    $('form button').html('Compiling...').attr('disabled', true);
    $.ajax({
      url: url,
      type: 'POST',
      dataType: "text",
      data: data,
      error: function(res, status, err) {
        alert('Compile Error: ' + err);
        $('form button').html('Compile').attr('disabled', false);
      },
      success: function(text) {
        $('form button').html('Compile').attr('disabled', false);
        $("#result").show().find("code").text(text);
        Prism.highlightAll();
      }
    });
  });
});