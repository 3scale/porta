# Tag 'email'


The `email` tag allows you to customize headers of your outgoing emails and is
available only inside the email templates.

The `email` tag allows you to customize headers of your outgoing messages.
There are several convenience subtags such as `cc` or `subject` (see the table below)
that simplify the job, but you can also use a `header` subtag to set an arbitrary
SMTP header for the message.

| Subtag        | Description        | Example                                           |
|---------------|--------------------|---------------------------------------------------|
| subject       | dynamic subject    | {% subject = 'Greetings from Example company!' %} |
| cc            | carbon copy        | {% cc = 'boss@example.com' %}                     |
| bcc           | blind carbon copy  | {% bcc = 'all@example.com' %}                     |
| from          | the actual sender  | {% from = 'system@example.com' %}                 |
| reply-to      |                    | {% reply-to = 'support@example.com' %}            |
| header        | custom SMTP header | {% header 'X-SMTP-Group' = 'Important' %}         |
| do_not_send   | custom SMTP header | {% do_not_send %}                                 |
    

__Example:__ Conditional blind carbon copy.
```liquid

{% email %}
  {% if plan.system_name == 'enterprise' %}
     {% bcc 'marketing@world-domination.org' %}
  {% endif%}
{% endemail %}
     
```

__Example:__ Disabling emails.
```liquid

{% email %}
  {% do_not_send %}
{% endemail %}
    
```

__Example:__ Signup email filter.
```liquid

{% email %}
  {% if plan.system == 'enterprise' %}
    {% subject = 'Greetings from Example company!' %}
    {% reply-to = 'support@example.com' %}
  {% else %}
    {% do_not_send %}
  {% endif %}
{% endemail %}
     
```
