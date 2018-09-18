# Tag 'active_docs'
# Tag 'braintree_customer_form'

Renders a form to enter data required for Braintree Blue payment gateway.
# Tag 'csrf'

Renders the cross site request forgery meta tags.

__Example:__ Using csrf tag in liquid
```liquid
<html>
  <head>
    {% csrf %}
  </head>
</html>
```
# Tag 'cdn_asset'

Provides the desired asset file

__Example:__ Using cdn_asset tag in liquid
```liquid
%{ cdn_asset '/swagger/2.1.3/swagger.js' %}
```
# Tag 'content'

Renders body of a page. Use this only inside a layout.
# Tag 'content_for'
# Tag 'debug'


Prints all liquid variables available in a template into an HTML comment.'
We recommend __to remove this tag__ from public templates.
      

```liquid
{% debug:help %}
```
# Tag 'email'


The `email` tag allows you to customize headers of your outgoing emails and is
available only inside the email templates.

There are several convenience subtags such as `cc` or `subject` (see the table below)
that simplify the job but you can also use a `header` subtag to set an arbitrary
SMTP header for the message.

| Subtag        | Description        | Example                                           |
|---------------|--------------------|---------------------------------------------------|
| subject       | dynamic subject    | {% subject = 'Greetings from Example company!' %} |
| cc            | carbon copy        | {% cc = 'boss@example.com' %}                     |
| bcc           | blind carbon copy  | {% bcc = 'all@example.com' %}                     |
| from          | the actual sender  | {% from = 'system@example.com' %}                 |
| reply-to      |                    | {% reply-to = 'support@example.com' %}            |
| header        | custom SMTP header | {% header 'X-SMTP-Group' = 'Important' %}         |
| do_not_send   | discard the email  | {% do_not_send %}                                 |
    

__Example:__ Conditional blind carbon copy
```liquid
{% email %}
  {% if plan.system_name == 'enterprise' %}
     {% bcc 'marketing@world-domination.org' %}
  {% endif%}
{% endemail %}
```

__Example:__ Disabling emails at all
```liquid
{% email %}
  {% do_not_send %}
{% endemail %}
```

__Example:__ Signup email filter
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
# Tag 'flash'

Renders informational or error messages of the system.

__DEPRECATED__: This tag is deprecated, use FlashDrop instead.

__Example:__ Using flash tag in liquid
```liquid
<html>
  <body>
   {% flash %}
  </body>
</html>
```
# Tag 'footer'

Renders a footer HTML snippet.

__DEPRECATED__: This tag is deprecated, use a CMS partial instead
# Tag 'form'


Renders a form tag with an action and class attribute specified, depending on the name
of the form. The supported forms are:

 <table>
   <tr>
     <th>Form</th>
     <th>Allowed Field Names</th>
     <th>Spam Protection</th>
     <th>Notes</th>
   </tr>
   <tr>
     <th>application.create</th>
     <td>
       <ul>
         <li>application[name]</li>
         <li>application[description]</li>
         <li>application[&lt;any-extra-field&gt;]</li>
       </ul>
     </td>
     <td>No</td>
     <td></td>
   </tr>
   <tr>
     <th>application.update</th>
     <td>
       <ul>
         <li>application[name]</li>
         <li>application[description]</li>
         <li>application[&lt;any-extra-field&gt;]</li>
       </ul>
     </td>
     <td>No</td>
     <td></td>
   </tr>
   <tr>
     <th>signup</th>
     <td>
       <ul>
         <li>account[org_name]</li>
         <li>account[org_legaladdress]</li>
         <li>account[org_legaladdress_cont]</li>
         <li>account[city]</li>
         <li>account[state]</li>
         <li>account[zip]</li>
         <li>account[telephone_number]</li>
         <li>account[country_id]</li>
         <li>account[&lt;any-extra-field&gt;]</li>
         <li>account[user][username]</li>
         <li>account[user][email]</li>
         <li>account[user][first_name]</li>
         <li>account[user][last_name]</li>
         <li>account[user][password]</li>
         <li>account[user][password_confirmation]</li>
         <li>account[user][title]</li>
         <li>account[user][&lt;any-extra-field&gt;]</li>
       </ul>
     </td>
     <td>Yes</td>
     <td>Sign Up directly to plans of your choice by adding one
         or more hidden fields with a name <code>plan_ids[]</code>.
         If a parameter of such name is found in the current URL,
         the input field is added automagically.
     </td>
   </tr>
 </table>
      

__Example:__ A form to create an application
```liquid
{% form 'application.create', application %}
   <input type='text' name='application[name]'
          value='{{ application.name }}'
          class='{{ application.errors.name | error_class }}'/>

   {{ application.errors.name | inline_errors }}

   <input name='commit'  value='Create!'>
{% endform %}
```
# Tag 'latest_forum_posts'

An HTML table with latest forum posts.

__DEPRECATED__: Use `forum` drop instead.

__Example:__ Using latest_forum_posts tag liquid
```liquid
{% latest_forum_posts %}
```
# Tag 'latest_messages'

Renders a HTML snippet with the latest messages for the user.

__Example:__ Using latest_messages tag liquid
```liquid
{% latest_messages %}
```
# Tag 'logo'

Renders the logo.

__DEPRECATED__: This tag is deprecated, use {{ provider.logo_url }} instead.

__Example:__ Using menu tag in liquid
```liquid
<html>
  <body>
   {% logo %}
  </body>
</html>
```
# Tag 'menu'

__DEPRECATED__: This tag is deprecated, use '{% include "menu" %}' instead.
# Tag 'oldfooter'

Renders a footer HTML snippet.

__DEPRECATED__: This tag is deprecated, use a CMS partial instead
# Tag 'plan_widget'

Includes a widget to review or change application plan

```liquid
{% if application.can_change_plan? %}
  <a href="#choose-plan-{{ application.id }}"
     id="choose-plan-{{application.id}}">
    Review/Change
  </a>
  {% plan_widget application, wizard: true %}
{% endif %}
```
# Tag 'portlet'


This tag includes portlet by system name.
      
# Tag 'sort_link'

Renders a link that sorts the column of table based on current params

__Example:__ Using sort_link in liquid
```liquid
<html>
  <table>
    <thead>
      <tr>
        <th>
          {% sort_link column: 'level'  %}
        </th>
        <th>
          {% sort_link column: 'timestamp' label: 'Time'  %}
        </th>
      </tr>
    </thead>
  </table>
</html>
```
# Tag 'submenu'

Renders a submenu HTML snippet for a logged in user.

__DEPRECATED__: This tag is deprecated, use a 'submenu' partial instead

__Example:__ Using submenu tag in liquid
```liquid
<html>
  <body>
   {% submenu %}
  </body>
</html>
```
# Tag '3scale_essentials'
# Tag 'user_widget'

Renders a user widget HTML snippet.

__DEPRECATED__: This tag is deprecated, use a CMS partial instead

__Example:__ Using user_widget tag in liquid
```liquid
<html>
  <body>
   {% user_widget %}
    <p class="notice">If you are logged in you see profile related links above.</p>
    <p class="notice">If you are not login you are invited to login or signup.</p>
  </body>
</html>
```
