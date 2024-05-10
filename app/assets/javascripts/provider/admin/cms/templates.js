(function($){
    $(function(){
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

        $(document).on('click', '.remove-from-section', function(event){
            $(this).closest("tr[id]").fadeOut(function(){ $(this).remove(); });
            return false;
        });

        $('#tab-content').trigger('cms-template:init');
    });

})(jQuery);
