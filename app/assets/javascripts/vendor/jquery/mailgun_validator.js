// More API details: https://api.mailgun.net/v2/address
// TODO: replace this with npm package mailgun.js

function mailgun_validator(address_text, options) {
    // don't run validator without input
    if (!address_text) {
        return;
    }

    // length check
    if (address_text.length > 512) {
        error_message = 'Stream exceeds maxiumum allowable length of 512.';
        if (options && options.error) {
            options.error(error_message);
        }
        else {
            console.log(error_message);
        }
        return;
    }

    // validator is in progress
    if (options && options.in_progress) {
        options.in_progress();
    }

    // require api key
    if (options && options.api_key == undefined) {
        console.log('Please pass in api_key to mailgun_validator.')
    }

    var success = false;

    // make ajax call to get validation results
    $.ajax({
        type: "GET",
        url: 'https://api.mailgun.net/v2/address/validate?callback=?',
        // 3scale change, we added syntax_only false to enable DNS validation
        data: { address: address_text, api_key: options.api_key, syntax_only: false },
        dataType: "jsonp",
        crossDomain: true,
        success: function(data, status_text) {
            success = true;
            if (options && options.success) {
                options.success(data);
            }
        },
        error: function(request, status_text, error) {
            success = true;
            error_message = 'Error occurred, unable to validate address.';

            if (options && options.error) {
                options.error(error_message);
            }
            else {
                console.log(error_message);
            }
        }
    });

    // timeout incase of some kind of internal server error
    setTimeout(function() {
        error_message = 'Error occurred, unable to validate address.';
        if (!success) {
            if (options && options.error) {
                options.error(error_message);
            }
            else {
                console.log(error_message);
            }
        }
    }, 30000);

}
