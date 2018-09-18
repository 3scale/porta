$.fn.extend({
  insertAtCaret: function(myValue){
    this.each(function(i) {
      if (document.selection) {
        this.focus();
        sel = document.selection.createRange();
        sel.text = myValue;
        this.focus();
      } else if (this.selectionStart || this.selectionStart == '0') {
        var startPos = this.selectionStart;
        var endPos = this.selectionEnd;
        var scrollTop = this.scrollTop;
        this.value = this.value.substring(0, startPos)+myValue+this.value.substring(endPos,this.value.length);
        this.focus();
        this.selectionStart = startPos + myValue.length;
        this.selectionEnd = startPos + myValue.length;
        this.scrollTop = scrollTop;
      } else {
        this.value += myValue;
        this.focus();
      }
    })
  }
});

function insertLink(link) {
  $("textarea.editor").insertAtCaret(link);
  $.fancybox.close();
}

function toggleExpandable(el, id) {
  if($(el).hasClass('expandable')) {
    $.ajax({
      url: "/cms/file_browser?sid="+id,
      success: function(html) {
        $(el).parent().append(html);
        $(el).removeClass('expandable').addClass('collapsed');
      }
    });
  } else {
    $(el).next().toggle();
    if($(el).hasClass('collapsed')) {
      $(el).removeClass('collapsed').addClass('expanded');
    } else {
      $(el).removeClass('expanded').addClass('collapsed');
    }
  }
}

