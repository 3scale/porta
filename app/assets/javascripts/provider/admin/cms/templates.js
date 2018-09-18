(function($){
    $.partial_paths = function(paths){
        $(function(){
            $('.cms-section-picker').change(function(){
                var section_id = parseInt($(this).val(), 10);
                $('.cms-path-autocomplete').attr('placeholder', paths[section_id]);
            }).trigger('change');
            $('.cms-path-autocomplete').focus(function(){
                var path = $(this);
                if(path.val() === ""){
                    path.val(path.attr('placeholder'));
                    this.select();
                }
            });

        });
    };

    $(function(){
        // Open/Close 'Advanced Options' on load
        $(document).on('cms-template:init', function(event){
            toggledInputsInit();
        });

        // keyboard actions
        //
        (function(){
            var save = function(){
                $("#cms_template_submit").click();
            };
            // this makes mousetrap work inside codemirror
            // just have to load it in right time (after textarea is created)
            //
            // $(".CodeMirror textarea").addClass("mousetrap");

            Mousetrap.bind(['meta+s', 'ctrl+s', 'command+s'], function(e){
                save();
                return false;
            });

        }());

        // init change detection
        $(window).on('beforeunload', function(e){
            var textareas = $(".codemirror textarea[name]"),
                changed = false;

            textareas.each(function(){
                var textarea = $(this),
                    codemirror = textarea.data('codemirror');

                if(codemirror && codemirror.getValue() !== textarea.val()) {
                    changed = true;
                }
            });

            if(changed) {
                return "You are about to leave unsaved content.";
            }
        });

        // Preview links should ask if there is unsaved content
        $(document).on('click', 'a[data-preview=draft]', function(event, skip){
            var textarea = $("#cms_template_draft"),
                codemirror = textarea.data('codemirror'),
                link = $(this);

            if(codemirror && codemirror.getValue() !== textarea.val()) { // changed
                var save = confirm("You have unsaved draft changes.\nDo you want to save them before previewing?");

                if (save) {
                    codemirror.save();
                    var ajax = $.rails.handleRemote(link.closest('form'));
                    ajax.success(function(){ window.open(link.attr('href')); });
                    event.preventDefault();
                }
            }
        });

        $(document).on('cms-template:init', function(event){
            var toggle = $('<a class="important-button dropdown-toggle" href="#">').append('<i class="fa fa-caret-down">');

            $(event.target).find(".dropdown-buttons ol").each(function(){
                var list = $(this);
                list.find('li:first :input').clone().insertBefore(list).addClass('important-button');

                // replace ol with ul because of formtastic
                list.replaceWith(function(){
                    return (list = $("<ul>").html($(this).html()).addClass("dropdown"));
                });

                toggle.clone().insertAfter(list);
            });
        });


        // DRAG ...
        $(document).on('sidebar:init', function(event){
            $(event.target).find('li.draggable').draggable({
                helper: function(e){
                    var element = $(e.currentTarget);

                    return element.clone().prependTo(element.parent().parent()).addClass('dragged')[0];
                },
                revert: 'invalid'
            });
        });

        // ... & DROP
        $(document).on('cms-template:init', function(event){
            $(event.target).find('#subsections-container').droppable({
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
            $(event.target).find('#cms-template-editor-tabs').parent().tabs({
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
