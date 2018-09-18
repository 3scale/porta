//= require vendor/urlify
//= require vendor/jquery/mailgun_validator

//= require vendor/jquery.tipsy

(function ($) {

    $(function () {
        $('form input').tipsy({trigger: 'focus', gravity: 'w'});

        $('.signup_form :input').each(function () {
            $(this).placeholder();
        });

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


        //var org_name = $('#account_org_name');

        var user_email = $('#account_user_email');
        var user_email_error = $('<p class="inline-errors"></p>');
        var email_parent = user_email.parent('li');
        var previous_email_error = user_email.next(".inline-errors");

        user_email.mailgun_validator({
            api_key: 'pubkey-889234583a41faa6d99b50ae152b2a3f',
            success: function (response) {
                var error_message = '';

                user_email_error.remove();

                if (response.is_valid) {
                    email_parent.removeClass('error');
                    user_email_error.remove();
                } else {
                    email_parent.addClass('error');

                    if (response.did_you_mean) {
                        error_message = "Did you mean: " + response.did_you_mean + "?";
                    }
                    else {
                        error_message = "The email address should exist.";
                    }
                }
                previous_email_error.hide();
                user_email_error.appendTo(email_parent).text(error_message);
            },
            error: function () {
                user_email_error.remove();
            }
        })
    });
})(jQuery);
