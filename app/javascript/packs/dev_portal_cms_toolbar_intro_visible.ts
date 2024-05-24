/* eslint-disable */
// @ts-nocheck
import $ from 'jquery'

(function(){
  var added_style = $();

  var add_style_to_iframe = function () {
    var style = $(this).find('option:selected').data('snippet');
    var frame = frames['developer-portal'];
    var doc;

    if (frame.document == undefined)
      doc = (frame.contentWindow || frame.contentDocument);
    else
      doc = frame;

    added_style.remove();

    if(!style) return;

    added_style = $('<style>' + style + '</style>');

    $('body', doc.document || doc).append(added_style);
  };

  $('iframe#developer-portal').on('load', add_style_to_iframe);
  $('#theme-picker')
          .on('change', add_style_to_iframe)
          .on('change', function () {
            var picker = $(this);

            var snippet = picker.find('option:selected').data('snippet');
            var style = "<style>" + snippet + '\n' + "</style>";
            var explain = '<!-- Copy & paste this snippet into your template called main layout to make this change permanent -->';
            var text = snippet ? explain + '\n\n' + style : '';

            $('#theme-snippet')
                    .toggle(text.length > 0)
                    .find('textarea').val(text);

          });
}());
