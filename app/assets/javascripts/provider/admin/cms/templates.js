(function($){
    $(function(){
        // ... & DROP
        $(document).on('cms-template:init', function(event){
            jQueryUI(event.target).find('#subsections-container').droppable({
                hoverClass: 'subsection-hover',
                drop: function(event, ui) {
                    var el = $(ui.helper);
                    var id = el.data('type').toLowerCase() + "-" +el.data('id');

                    $('#subsections-container thead').remove();
                    $('#subsections-container tbody').append(
                        '<tr id="' + id + '">' +
                        '<td>' +  el.children('a').text() + '</td>' +
                        '<td>' + el.data('type') + '</td>' +
                        '<td><a href="#" onclick="$(\'#'+ id + '\').remove()">Remove</a></td>' +
                        '<input type="hidden" name="cms_section['+ el.data('param').toLowerCase() +'_ids][]" ' +
                        'value="'+ el.data('id') + '" />' +
                        '</tr>');
                }
            });
        });

        $(document).on('change', '#cms_template_content_type, #cms_template_liquid_enabled', function(event){
            var content_type = $('#cms_template_content_type').val();
            var liquid_enabled = $('#cms_template_liquid_enabled:checked').length == 1;
            var codemirror = $("#cms_template_draft").data('codemirror');

            if(codemirror) {
                $(codemirror).trigger("change", [content_type, liquid_enabled]);
            }
        }).triggerHandler('change');

        $(document).on('cms-template:init', function(event){
            $(event.target).find('#cms_template_content_type, #cms_template_liquid_enabled').trigger('change');
        });

        $(document).on('click', 'a[href="#cms-template-revert"]', function(event){
            // this needs to be bound before initializing tabs
            event.stopImmediatePropagation();

            var draft = $('#cms_template_draft').data('codemirror');
            var live = $('#cms_template_published').data('codemirror');

            draft.setValue(live.getValue());
            $.flash("Reverted draft to a currently published version.");

            // pulsate the editor
            $('.CodeMirror-lines').animate({ opacity: 0.2 }, 500, function() { $(this).animate({ opacity: 1.0}); } );

            var save = confirm("Your draft is now reset to latest published version.\nDo you want to save your changes?");

            if(save) {
                $.rails.handleRemote($(this).closest('form'));
            }

            return false;
        });

        $(document).on('cms-template:init', function(event){
            jQueryUI(event.target).find('#cms-template-editor-tabs').parent().tabs({
                show: function(event, ui){
                    $(ui.panel).trigger('cms.refresh');
                }
            });
        });

        $(document).on('click', '.remove-from-section', function(event){
            $(this).closest("tr[id]").fadeOut(function(){ $(this).remove(); });
            return false;
        });

        $(document).on('click', 'a[href^="#cms-set-content-type-"]', function(event){
            $('#cms_template_content_type').val($(this).data('mime-type')).trigger('change');
            return false;
        });

        $('#tab-content').trigger('cms-template:init');
    });

})(jQuery);
