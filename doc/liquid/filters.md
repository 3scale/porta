# FormHelpers filters

## error_class filter
Outputs error class if argument is not empty.
__Example:__ Using error_class to show output an error class.
```liquid
<input class="{{ form.errors.description | error_class }}" />
```

## inline_errors filter
Outputs error fields inline in paragraph.
__Example:__ Using inline_errors to show errors inline.
```liquid
{{ form.errors.description | inline_errors }}
```
-----------

# ParamFilter filters

## to_param filter
Converts a supplied drop to URL parameter if possible.
__Example:__ Using to_param filter in liquid.
```liquid
<h1>Signup to a service</h1>
<a href="{{ urls.signup }}?{{ service | to_param }}">Signup to {{ service.name }}</a>
```
-----------

# Common filters

## group_by filter
Group collection by some key.
__Example:__ Group applications by service.
```liquid
{% assign grouped = applications | group_by: 'service' %}
{% for group in grouped %}
  Service: {{ group[0 }}
  {% for app in group[1] %}
    Application: {{ app.name }}
  {% endfor %}
{% endfor %}
```

## any filter
True if any string in the collection equals to the parameter.
__Example:__ Are there any pending apps of the current account?
```liquid
{% assign has_pending_apps = current_account.applications | map: 'state' | any: 'live' %}
```

## stylesheet_link_tag filter
Stylesheet link

## javascript_include_tag filter
Javascript includes tag.

## image_tag filter
Outputs an <img> tag using the parameters as its `src` attribute.
```liquid
{{ 'http://example.com/cool.gif' | image_tag }}
# => <img src="http://example.com/cool.gif" >
```

## mail_to filter
Converts email address to a 'mailto' link.
```liquid
{{ 'me@there.is' | mail_to }}
# => <a href="mailto:me@there.is">me@there.is</a>
```

## html_safe filter
Marks content as HTML safe so that it is not escaped.

## pluralize filter
Converts word to plural form.

## delete_button filter

Generates a button to delete a resource present on the URL.
First parameter is a URL, second is a title. You can also add more
HTML tag attributes as a third parameter.

To add a confirmation dialog, add a confirm attribute with a
confirmation text
      
```liquid
{{ 'Delete Message' | delete_button: message.url, class: 'my-button',
  confirm: 'are you sure?' }}
```

## delete_button_ajax filter

Generates a button to delete a resource present on the URL using AJAX.
First parameter is a URL, second is a title.

To add a confirmation dialog, add a confirm attribute with a
confirmation text.
      
```liquid
{{ 'Delete Message' | delete_button_ajax: message.url, confirm: 'are you sure?' }}
```

## update_button filter

Generates a button to 'update' (HTTP PUT request) a resource present on the URL.
First parameter is a URL, second is a title. You can also add more
HTML tag attributes as a third parameter.

To change the text of the submit button on submit, add a disable_with attribute with a
the new button text.
      
```liquid
{{ 'Resend' | update_button: message.url, class: 'my-button', disable_with: 'Resending…' }}
```

## update_button_ajax filter

Generates a button to 'update' (HTTP PUT request) a resource present on
the URL using AJAX. First parameter is a URL, second is a title. You can
also add more HTML tag attributes as a third parameter.

To change the button text on submit, add a disable_with attribute with a
the new button text.
      
```liquid
{{ 'Resend' | update_button: message.url, class: 'my-button', disable_with: 'Resending…' }}
```

## create_button filter

Generates a button to create a resource present on the URL.
First parameter is a URL, second is a title. You can
also add more HTML tag attributes as a third parameter.

To change the button text on submit, add a disable_with attribute with a
the new button text.
      
```liquid
{{ 'Create Message' | create_button: message.url, disable_with: 'Creating message…' }}
```

## create_button_ajax filter

Generates a button to create a resource present on the URL using AJAX.
First parameter is a URL, second is a title. You can
also add more HTML tag attributes as a third parameter.

To change the button text on submit, add a disable_with attribute with a
the new button text.
      
```liquid
{{ 'Create Message' | create_button: message.url, disable_with: 'Creating message…' }}
```

## regenerate_oauth_secret_button filter

## link_to filter
Create link from given text
```liquid
{{ "See your App keys" | link_to:'/my-app-keys' }}
```

## dom_id filter
-----------

