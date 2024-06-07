//= require vendor/urlify

(function ($) {

    $(function () {
        var first_name = $("#account_user_first_name");
        var first_name_val = first_name.val();
        var last_name_list_item = $("#account_user_last_name_input");
        var last_name_errors = last_name_list_item.find(".inline-errors");


        if (first_name_val !== "") {
            last_name_errors.find(".first-name").html(first_name_val);
        }

        first_name.change(function (e) {
            var first_name_val = first_name.val();
            var last_name_list_item = $("#account_user_last_name_input");
            var last_name_hints = last_name_list_item.find(".inline-hints");
            var last_name_errors = last_name_list_item.find(".inline-errors");

            if (first_name_val !== "") {
                last_name_hints.find(".first-name").html(first_name_val);
                last_name_errors.find(".first-name").html(first_name_val);
            }
        });


        var domain = $("#account_subdomain");
        var self_domain = $("#account_self_subdomain");

        domain.keyup(function () {
            var val = domain.val();
            if (val !== "") {
                val += "-admin";
            }
            self_domain.val(val);
        });

        if (domain.val() === "") {
            domain.data('autoupdate', true);
        }

        domain.change(function (e) {
            if (domain.val() === "") {
                domain.data('autoupdate', true);
            } else {
                domain.data('autoupdate', false);
            }
        });

        $(document).on('keyup', '#account_org_name', function () {
            var name = $(this).val();
            var slug = window.URLify(name);
            domain.parent('li').removeClass('hidden');
            self_domain.parent('li').removeClass('hidden');

            if (domain.data('autoupdate')) {
                domain.val(slug);
                domain.trigger('keyup');
            }
        });
    });
})(jQuery);
