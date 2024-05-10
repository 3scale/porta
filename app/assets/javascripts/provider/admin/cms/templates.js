(function($){
    $(function(){
        $(document).on('click', '.remove-from-section', function(event){
            $(this).closest("tr[id]").fadeOut(function(){ $(this).remove(); });
            return false;
        });

        $('#tab-content').trigger('cms-template:init');
    });

})(jQuery);
