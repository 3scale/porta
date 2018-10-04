# Account drop


A developer account. See `User` drop if you are looking for the email addresses or similar information.
      

```liquid
<h1>Account organization name {{ current_account.name }}</h1>
<div>Plan {{ current_account.bought_account_plan.name }}</div>
<div>Telephone {{ current_account.telephone_number }}</div>

<div>{{ current_account.fields_plain_text }}</div>
<div>{{ current_account.extra_fields_plain_text }}</div>

{% if current_account.approval_required? %}
   <p>This account requires approval.</p>
{% endif %}

{% if current_account.credit_card_required? %}

  {% if current_account.credit_card_stored? %}
    <p>This account has credit card details stored in database.</p>
  {% else %}
    <p>Please enter your {{ 'credit card details' | link_to: urls.payment_details }}.</p>
  {% endif %}

  {% if current_account.credit_card_missing? %}
    <p>This account has no credit card details stored in database.</p>
  {% endif %}
{% endif %}
```

## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="account[name]"
       value="{{ account.name }}"
       class="{{ account.errors.name | error_class }}"/>
{{ account.errors.name | inline_errors }}
```

### id
Returns the id of the account.

### name
Returns the organization name of the developer's account.

### display_name
Returns account's display name

### vat_zero_text
Returns a text about a VAT zero.

### vat_rate
Return the VAT rate.

### unread_messages
Returns the unread messages.

### latest_messages
Returns the latest messages.

### bought_account_plan
Returns the plan the account has contracted.

### bought_account_contract
Returns the contract account.

### credit_card_display_number

### credit_card_expiration_date

### credit_card_required?
Returns whether the account is required to enter credit card details.

### credit_card_stored?
Returns whether the account has credit card details stored.

### credit_card_missing?
Returns whether the account has no credit card details stored.

### requires_credit_card_now?
Returns whether this buyer needs to edit credit card because of bought paid plans

### timezone
Returns timezone of this account.

### paid?
Returns whether the account has at least a paid contract.

### on_trial?
Returns whether the account is in the trial period, i.e. all paid contracts are in the trial period.

### telephone_number
Returns the telephone number of the account.

### approval_required?
Returns whether the account requires approval.

### created_at
Returns UNIX timestamp of account creation (signup).
__Example:__ Converting timestamp to JavaScript Date.
```liquid
<script>
  var data = new Date({{ account.created_at }} * 1000);
</script>
```

### full_address
Returns legal address, city and state.

### applications
Returns the applications of the account.

### subscribed_services
Returns an array with ServiceContract drops.

### country_name
Returns the country of the account.

### admin
Returns the admin user of this account.

### extra_fields_plain_text
Returns the extra fields defined for the account as plain text.

### fields_plain_text
Returns the fields defined for the account as plain text.

### extra_fields
Returns extra fields with values of this account.
__Example:__ Print all extra fields.
```liquid
{% for field in account.extra_fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### fields
Returns all fields with values of this account.
__Example:__ Print all fields.
```liquid
{% for field in account.fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### builtin_fields

### multiple_applications_allowed?

### billing_address
Returns the billing address of this account.

### has_billing_address?
Returns whether this account has a billing address or not.

### can
Give access to permission methods.
```liquid
%{ if account.can.be_deleted? %}
  <!-- do something -->
{% endif %}
```

### edit_url

### edit_ogone_billing_address_url

### edit_braintree_blue_credit_card_details_url

### edit_stripe_billing_address_url

### edit_adyen12_billing_address_url

-----------

# AccountPlan drop



__Example:__ Using account plan drop in liquid.
```liquid
<p class="notice">The examples for plan drop apply here</p>
```

## Methods
### selected?
Returns whether the plan is selected.
```liquid
{% if plan.selected? %}
  <p>You will signup to {{ plan.name }}</p>
{% endif %}
```

### bought?
Returns whether the plan is bought.
```liquid
{% if plan.bought? %}
   <p>You are  on this plan already!</p>
{% endif %}
```

### features
Returns an array of available features.

### setup_fee
Returns the setup fee.

### name
Returns the name of the plan.
```liquid
<h1>We offer you a new {{ plan.name }} plan!</h1>
```

### system_name
Returns the system name of the plan.
```liquid
{% for plan in available_plans %}
  {% if plan.system_name == 'my_free_plan' %}
    <input type="hidden" name="plans[system_name]" value="{{ plan.system_name }}"/>
    <p>You will buy our only free plan!</p>
  {% endif %}
{% endfor %}
```

### id
Returns the plan ID.

### free?
The plan is free if it is not 'paid' (see the 'paid?' method).
```liquid
{% if plan.free? %}
   <p>This plan is free of charge.</p>
{% else %}
   <div>
     <p>Plan costs:</p>
     <div>Setup fee {{ plan.setup_fee }}</div>
     <div>Flat cost {{ plan.flat_cost }}</div>
  </div>
{% endif %}
```

### trial_period_days
Returns the number of trial days in a plan.
```liquid
<p>This plan has a free trial period of {{ plan.trial_period_days }} days.</p>
```

### paid?
The plan is 'paid' when it has a non-zero fixed or setup fee or there are pricing rules present.
```liquid
{% if plan.paid? %}
   <p>this plan is a paid one.</p>
{% else %}
   <p>this plan is a free one.</p>
{% endif %}
```

### approval_required?
Returns whether the plan requires approval.
```liquid
{% if plan.approval_required? %}
   <p>This plan requires approval.</p>
{% endif %}
```

### flat_cost
Returns the monthly fixed fee of the plan. (including currency)

### cost
Returns the monthly fixed fee of the plan.

-----------

# Alert drop



__Example:__ Using alert drop in liquid.
```liquid
<h1>Alert details</h1>
<div>Level {{ alert.level }}</div>
<div>Message {{ alert.message }}</div>
<div>Utilization {{ alert.utilization }}</div>
```

## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="alert[name]"
       value="{{ alert.name }}"
       class="{{ alert.errors.name | error_class }}"/>
{{ alert.errors.name | inline_errors }}
```

### level
The alert level can be 50, 80, 90, 100, 120, 150, 200, or 300.

### message
Text message describing the alert, for example 'SMS check status per minute: 5 of 5'.

### utilization
Decimal number marking the actual utilization that triggered the alert (1.0 is equal to 100%).
```liquid
Used by {{ alert.utilization | times: 100 }} percent.
```

### unread?
Whether the alert has been read or not (boolean)

### state
The current state of the alert ('unread', 'read' or 'deleted')

### read_alert_url
The URL that marks the alert as read
```liquid
{{ 'Read' | update_button: alert.read_alert_url, class: 'mark-as-read', disable_with: 'Marking...', title: 'Mark as read' }}
```

### dom_level
A dom-friendly level identifier of the alert, for example 'above-100'

### formatted_level
The formatted utilization level of the alert, for example '≥ 100 '

### delete_alert_url
The URL that deletes the alert
```liquid
{{ '<i class="fa fa-trash"></i>' | html_safe | link_to:  alert.delete_alert_url, title: 'Delete alert', method: 'delete' }}
```

-----------

# ApiSpec drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="api_spec[name]"
       value="{{ api_spec.name }}"
       class="{{ api_spec.errors.name | error_class }}"/>
{{ api_spec.errors.name | inline_errors }}
```

### url
Returns the url of the API spec.

### system_name
Returns the name of the spec.

### service
Returns the service of the spec if it has any or `nil` otherwise.

-----------

# Application drop



__Example:__ Using application drop in liquid.
```liquid
<h1>Application {{ application.name }} (<span title="Application ID">{{ application.application_id }}</span>)</h1>
<p>{{ application.description }}</p>
```

## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="application[name]"
       value="{{ application.name }}"
       class="{{ application.errors.name | error_class }}"/>
{{ application.errors.name | inline_errors }}
```

### id
Returns the id of the application.

### can_change_plan?
Returns 'true' if changing the application is allowed either directly or by request.

### trial?

Returns true if the contract is still in the trial period.

__Note__: If you change the trial period length of a plan,
it does not affect existing contracts.
           

### live?

### state
There are three possible states:

        - pending
        - live
        - suspended
      

### remaining_trial_period_days
Number of days left in the trial period.

### plan
Returns a plan drop with the plan of the application.

### plan_change_permission_name
Returns name of the allowed action.

### plan_change_permission_warning
Returns a warning message for the allowed action.

### admin_url
Returns the admin_url of the application.

### path

### name
Returns the name of the application.

### can

### oauth

### pending?
Returns 'true' if application state is pending.

### buyer_alerts_enabled?

### alerts

### description
Returns the description of the application.

### redirect_url
Returns the redirect URL for the OAuth request of the application.

### filters_limit
Returns the amount of referrer filters allowed for this application.

### keys_limit
Returns the amount of application keys allowed for this application.

### referrer_filters
Returns the referrer filters associated with this application.

### rejection_reason
Returns the reason for rejecting an application.

### user_key
Returns the user_key of application.

### application_id
Returns the application_id of an application.

### key
Returns the application id or the user key.

### url
Returns URL of the built-in detail view for this application.

### edit_url
Returns URL of the built-in edit view for this application.

### update_user_key_url

### alerts_url

### purge_alerts_url

### mark_alerts_as_read_url

### application_keys_url

### service
Service to which the application belongs to.

### keys
Returns the keys of an application.
```liquid
{% case application.keys.size %}
{% when 0 %}
  Generate your application key.
{% when 1 %}
  <h3>Application key for {{ application.name }} {{ application.application_id }}</h3>
  <p>Key is: {{ application.keys.first }}</p>
{% else %}
  <h3>Application keys for {{ application.name }} {{ application.application_id }}</h3>
  <ul>
    {% for key in application.keys %}
      <li>{{ key }}</li>
    {% endfor %}
  </ul>
{% endcase %}
```

### oauth_mode?

### user_key_mode?

### app_id_mode?

### change_plan_url

### application_keys

### extra_fields
Returns non-hidden extra fields with values for this application.
__Example:__ Print all extra fields.
```liquid
{% for field in application.extra_fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### fields
Returns all built-in and extra fields with values for this application.
__Example:__ Print all fields.
```liquid
{% for field in application.fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### builtin_fields
Returns only built-in fields of the application.

### cinstance

-----------

# ApplicationKey drop





## Methods
### id

### value

### url

### application

-----------

# ApplicationPlan drop





## Methods
### selected?
Returns whether the plan is selected.
```liquid
{% if plan.selected? %}
  <p>You will signup to {{ plan.name }}</p>
{% endif %}
```

### bought?
Returns whether the plan is bought.
```liquid
{% if plan.bought? %}
   <p>You are  on this plan already!</p>
{% endif %}
```

### features
Returns the visible features of the plan.
```liquid
{% if plan == my_free_plan %}
   <p>These plans are the same.</p>
{% else %}
   <p>These plans are not the same.</p>
{% endif %}
```

### setup_fee
Returns the setup fee of the plan.

### name
Returns the name of the plan.
```liquid
<h1>We offer you a new {{ plan.name }} plan!</h1>
```

### system_name
Returns the system name of the plan.
```liquid
{% for plan in available_plans %}
  {% if plan.system_name == 'my_free_plan' %}
    <input type="hidden" name="plans[system_name]" value="{{ plan.system_name }}"/>
    <p>You will buy our only free plan!</p>
  {% endif %}
{% endfor %}
```

### id
Returns the plan ID.

### free?
The plan is free if it is not 'paid' (see the 'paid?' method).
```liquid
{% if plan.free? %}
   <p>This plan is free of charge.</p>
{% else %}
   <div>
     <p>Plan costs:</p>
     <div>Setup fee {{ plan.setup_fee }}</div>
     <div>Flat cost {{ plan.flat_cost }}</div>
  </div>
{% endif %}
```

### trial_period_days
Returns the number of trial days in a plan.
```liquid
<p>This plan has a free trial period of {{ plan.trial_period_days }} days.</p>
```

### paid?
The plan is 'paid' when it has a non-zero fixed or setup fee or there are pricing rules present.
```liquid
{% if plan.paid? %}
   <p>this plan is a paid one.</p>
{% else %}
   <p>this plan is a free one.</p>
{% endif %}
```

### approval_required?
Returns whether the plan requires approval.
```liquid
{% if plan.approval_required? %}
   <p>This plan requires approval.</p>
{% endif %}
```

### flat_cost
Returns the monthly fixed fee of the plan. (including currency)

### cost
Returns the monthly fixed fee of the plan.

### metrics
Returns the metrics of the plan.

### usage_limits
Returns the usage limits of the plan.

### service
Returns the service of the plan.

-----------

# AuthenticationProvider drop





## Methods
### name
Name of the SSO Integration

### kind
Kind of the SSO Integration. Useful for styling.

### authorize_url
OAuth authorize url.

### callback_url
OAuth callback url.

-----------

# Base drop





## Methods
### login_url

### user_identified?

-----------

# Base drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="base[name]"
       value="{{ base.name }}"
       class="{{ base.errors.name | error_class }}"/>
{{ base.errors.name | inline_errors }}
```

### title
Returns the title of result.

### kind
Returns the kind of result; can be 'topic' or 'page'.

### url
Returns the resource URL of the result.

### description
Returns a descriptive string for the result.

-----------

# BillingAddressField drop





## Methods
### input_name

### label

### choices

### errors

### html_id

### hidden?

### visible?

### read_only?

### name

### value

### required

-----------

# Can drop





## Methods
### be_updated?

### be_destroyed?

### add_referrer_filters?

### add_application_keys?

### regenerate_user_key?

### regenerate_oauth_secret?

### manage_keys?

### delete_key?

-----------

# Can drop





## Methods
### change_plan?

-----------

# Cas drop





## Methods
### login_url

### user_identified?

-----------

# Contract drop



```liquid
Plan of the contract {{ contract.plan.name }}
```

## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="contract[name]"
       value="{{ contract.name }}"
       class="{{ contract.errors.name | error_class }}"/>
{{ contract.errors.name | inline_errors }}
```

### id
Returns the id.

### can_change_plan?
Returns true if any change is possible.

### trial?

Returns true if the contract is still in the trial period.

__Note__: If you change the trial period length of a plan,
it does not affect existing contracts.
           

### live?

### state
There are three possible states:

        - pending
        - live
        - suspended
      

### remaining_trial_period_days
Number of days left in the trial period.

### plan
Returns the plan of the contract.

### plan_change_permission_name
Returns name of the allowed action.

### plan_change_permission_warning
Returns a warning message for the allowed action.

-----------

# Country drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="country[name]"
       value="{{ country.name }}"
       class="{{ country.errors.name | error_class }}"/>
{{ country.errors.name | inline_errors }}
```

### to_str

### code

### label

-----------

# CountryField drop





## Methods
### value
Returns ID of the country.
```liquid
{{ account.fields.country.value }} => 42

compare with:

{{ account.fields.country }} => 'United States'
```

### name
Returns system name of the field.

### required

### hidden?

### hidden

### visible?

### visible

### read_only

### errors

### input_name

### html_id

### label
Returns label of the field.
```liquid
{{ account.fields.country.label }}
<!-- => 'Country' -->
```

### to_str
Returns name of the country.
```liquid
{{ account.fields.country }} => 'United States'
```

### choices

-----------

# CurrentUser drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="current_user[name]"
       value="{{ current_user.name }}"
       class="{{ current_user.errors.name | error_class }}"/>
{{ current_user.errors.name | inline_errors }}
```

### admin?
Returns whether the user is an admin.
```liquid
{% if user.admin? %}
  <p>You are an admin of your account.</p>
{% endif %}
```

### username
Returns the username of the user, HTML escaped.

### account
Returns the account of the user.

### name
Returns the first and last name of the user.

### oauth2?
Returns true if user has stored oauth2 authorizations

### email
Returns the email of the user.

### password_required?

This method will return `true` for users using the built-in
Developer Portal authentication mechanisms and `false` for
those that are authenticated via Janrain, CAS or other
single-sign-on method.
      
```liquid
{{ if user.password_required? }}
  <input name="account[user][password]" type="password">
  <input name="account[user][password_confirmation]" type="password">
{{ endif }}
```

### sections
Returns the list of sections the user has access to.
```liquid
{% if user.sections.size > 0 %}
  <p>You can access following sections of our portal:</p>
   <ul>
    {% for section in user.sections %}
      <li>{{ section }}</li>
    {% endfor %}
  </ul>
{% endif %}
```

### role
Returns the role of the user.

### roles_collection
Returns a list of available roles for the user.
```liquid
{% for role in user.roles_collection %}
  <li>
    <label for="user_role_{{ role.key }}">
      <input
        {% if user.role == role.key %}
          checked="checked"
        {% endif %}
      class="users_ids" id="user_role_{{ role.key }}" name="user[role]" type="radio" value="{{ role.key }}">
      {{ role.text }}
    </label>
    </li>
  {% endfor %}
```

### url
Returns the resource URL of the user.
```liquid
{{ 'Delete' | delete_button: user.url }}
```

### edit_url
Returns the URL to edit the user.
```liquid
{{ 'Edit' | link_to: user.edit_url, title: 'Edit', class: 'action edit' }}
```

### can
Exposes rights of current user which are dependent
 on your settings and user's role.
        
 You can call these methods on the returned object:

 - invite_user?
 - create_application?
```liquid
(
        {% if current_user.can.invite_users? %}
           {{ '<i class="fa fa-trash pull-right"></i>' | html_safe | link_to: invitation.url, class: 'pull-right btn btn-link', method: 'delete' }}
        {% endif %}
      )
```

### extra_fields
Returns non-hidden extra fields with values for this user.
__Example:__ Print all extra fields.
```liquid
{% for field in user.extra_fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### fields
Returns all fields with values for this user.
__Example:__ Print all fields.
```liquid
{% for field in user.fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### builtin_fields
Returns all built-in fields with values for this user.

### sso_authorizations
Returns SSO Authorizations collection.

-----------

# Error drop


        When a form fails to submit because of invalid data, the `errors` array
        will be available on the related model.
      



## Methods
### attribute
Returns value of the attribute to which this `error` is related.
```liquid
{{ account.errors.org_name.first.attribute }}
<!-- org_name -->
```

### message
Returns description of the error.
```liquid
{{ account.errors.first.message }}
<!-- can't be blank -->
```

### value
Returns value of the attribute to which this `error` is related.
```liquid
{{ account.errors.org_name.first.value }}
 <!-- => "ACME Co." -->
```

### to_str
Returns full description of the error (includes the attribute name).
```liquid
{{ model.errors.first }}
<!-- => "Attribute can't be blank" -->
```

-----------

# Errors drop



__Example:__ Get all errors.
```liquid
{% for error in form.errors %}
  attribute: {{ error.attribute }}
  ...
{% endfor %}
```

## Methods
### empty?
Returns true if there are no errors.
```liquid
{% if form.errors == empty %}
  Contgratulations! You have no errors!
{% endfor %}
```

### present?
Returns true if there are errors.
```liquid
{% if form.errors == present %}
  Sorry, there were errors.
{% endfor %}
```

-----------

# Feature drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="feature[name]"
       value="{{ feature.name }}"
       class="{{ feature.errors.name | error_class }}"/>
{{ feature.errors.name | inline_errors }}
```

### name
Returns the name of the feature.
```liquid
<h1>Feature {{ feature.name }}</h1>
```

### description
Returns the description of the feature.

### has_description?
Returns description of the feature or information that there is no description.
```liquid
{% if feature.has_description? %}
  {{ feature.description }}
{% else %}
   This feature has no description.
{% endif %}
```

### system_name
Returns system name of the feature (system wide unique name).
```liquid
{% if feature.system_name == 'promo_feature' %}
  <div>This feature is available only today!</div>
{% endif %}
```

-----------

# Field drop





## Methods
### value
Returns value of the field.
```liquid
Name: {{ account.fields.first_name.value }}
```

### name
Returns system name of the field.

### required

### hidden?

### hidden

### visible?

### visible

### read_only

### errors

### input_name
Returns the name for the HTML input that is expected when the form is submitted.
```liquid
<input name="{{ account.fields.country.input_name }}" value="{{account.fields.country}}" />
<!-- the 'name' attribute will be 'account[country]' -->
```

### html_id
Returns a unique field identifier that is commonly used as HTML ID attribute.
```liquid
{{ account.fields.country.html_id }}
<!--  => 'account_country' -->
```

### label
Returns label of the field.
```liquid
{{ account.fields.country.label }}
<!-- => 'Country' -->
```

### to_str
Returns the value of the field if used as variable.
```liquid
{{ account.fields.first_name }} => 'Tom'
```

### choices

Returns array of choices available for that field, if any. For example,
for a field called `fruit` it may respond with `['apple', 'bannana', 'orange']`.

You can define the choices in your [admin dashboard][fields-definitions].
Each of the array elements responds to `id` and `label` which
are usually just the same unless the field is a special built-in one (like `country`)
It is recommended to use those methods rather that output the `choice` 'as is'
for future compatibility.
            
```liquid
{% for choice in field.choices %}
  <select name="{{ field.input_name }}" id="{{ field.html_id }}_id"
          class="{{ field.errors | error_class }}">
  <option {% if field.value == choice %} selected {% endif %} value="{{ choice.id }}">
    {{ choice }}
  </option>
{% endfor %}
```

-----------

# Flash drop





## Methods
### messages
Returns an array of messages.
```liquid
{% for message in flash.messages %}
   <p id="flash-{{ message.type }}">
     {{ message.text }}
   </p>
{% endfor %}
```

-----------

# Forum drop





## Methods
### enabled?
Returns true if you have forum functionality enabled.
```liquid
{% if forum.enabled? %}
  <a href="/forum">Check out our forum!</a>
{% endif %}
```

### latest_posts

-----------

# I18n drop



```liquid
Provide useful strings for i18n support:

{{ object.some_date | date: i18n.long_date }}
```

## Methods
### short_date
Alias for `%b %d`.
```liquid
Dec 11
```

### long_date
Alias for `%B %d, %Y`.
```liquid
December 11, 2013
```

### default_date
Alias for `%Y-%m-%d`.
```liquid
2013-12-11
```

### default_time
Alias for `%d %b %Y %H:%M:%S %Z`.
```liquid
"16 Mar 2017 16:45:21 UTC"
```

-----------

# Invitation drop



```liquid
<div> Email: {{ invitation.email }} </div>
<div>

<tr id="invitation_{{ invitation.id }}">
  <td> {{ invitation.email }} </td>
  <td> {{ invitation.sent_at | date: i18n.short_date }} </td>
  <td>
    {% if invitation.accepted? %}
      yes, on {{invitation.accepted_at | format: i18n.short_date }}
    {% else %}
      no
    {% endif %}
  </td>
</tr>
```

## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="invitation[name]"
       value="{{ invitation.name }}"
       class="{{ invitation.errors.name | error_class }}"/>
{{ invitation.errors.name | inline_errors }}
```

### email
Returns email address.

### accepted?
Returns true if the invitation was accepted.

### accepted_at
Returns a date if the invitation was accepted.
```liquid
{{ invitation.accepted_at | date: i18n.short_date }}
```

### sent_at
Returns the creation date.
```liquid
{{ invitation.sent_at | date: i18n.short_date }}
```

### resend_url
Returns the URL to resend the invitation.
```liquid
{{ "Resend" | update_button: invitation.resend_url}}
```

### url
Returns the resource URL.
```liquid
{{ "Delete" | delete_button: invitation.url }}
```

-----------

# Invoice drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="invoice[name]"
       value="{{ invoice.name }}"
       class="{{ invoice.errors.name | error_class }}"/>
{{ invoice.errors.name | inline_errors }}
```

### friendly_id
Returns a friendly id
```liquid
<td> {{ invoice.friendly_id }} </td>
<td> {{ invoice.name }} </td>
<td> {{ invoice.state }} </td>
<td> {{ invoice.cost }} {{ invoice.currency }} </td>
```

### id

### name
Returns a string composed of month and year.

### state

### cost
Returns a number with two decimals.
```liquid
23.00
```

### currency

### cost_without_vat
Returns cost without VAT.

### vat_rate
Returns VAT rate.

### vat_amount
Returns VAT ammount.

### exists_pdf?
Return true if the PDF was generated.

### period_begin
```liquid
{{ invoice.period_begin | date: i18n.short_date }}
```

### period_end
```liquid
{{ invoice.period_end | date: i18n.long_date }}
```

### issued_on
```liquid
{{ invoice.issued_on | date: i18n.long_date }}
```

### due_on
```liquid
{{ invoice.due_on | date: i18n.long_date }}
```

### paid_on
```liquid
{{ invoice.paid_on | date: i18n.long_date }}
```

### vat_code

### fiscal_code

### account
Returns an AccountDrop.

### buyer_account

### line_items
Returns an array of LineItemDrop.
```liquid
{% for line_item in invoice.line_items %}
  <tr class="line_item {% cycle 'odd', 'even' %}">
    <th>{{ line_item.name }}</th>
    <td>{{ line_item.description }}</td>
    <td>{{ line_item.quantity }}</td>
    <td>{{ line_item.cost }}</td>
  </tr>
{% endfor %}
```

### payment_transactions
Returns an array of PaymentTransactionDrop.
```liquid
{% for payment_transaction in invoice.payment_transactions %}
  <tr>
    <td> {% if payment_transaction.success? %} Success {% else %} Failure {% endif %} </td>
    <td> {{ payment_transaction.created_at }} </td>
    <td> {{ payment_transaction.reference }} </td>
    <td> {{ payment_transaction.message }} </td>
    <td> {{ payment_transaction.amount }} {{ payment_transaction.currency }} </td>
  </tr>
{% endfor %}
```

### url
Returns the resource URL of the invoice.
```liquid
{{ "Show" | link_to: invoice.url }}
```

### pdf_url
Returns the resource URL of the invoice PDF.
```liquid
{{ "PDF" | link_to: invoice.pdf_url }}
```

-----------

# LineItem drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="line_item[name]"
       value="{{ line_item.name }}"
       class="{{ line_item.errors.name | error_class }}"/>
{{ line_item.errors.name | inline_errors }}
```

### name
```liquid
{% for line_item in invoice.line_items %}
  <tr class="line_item {% cycle 'odd', 'even' %}">
    <th>{{ line_item.name }}</th>
    <td>{{ line_item.description }}</td>
    <td>{{ line_item.quantity }}</td>
    <td>{{ line_item.cost }}</td>
  </tr>
{% endfor %}
```

### description

### quantity

### cost

-----------

# Message drop





## Methods
### type

Possible types of the messages are:

 - success (not used by now)
 - info
 - warning
 - danger
        

### text

-----------

# Message drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="message[name]"
       value="{{ message.name }}"
       class="{{ message.errors.name | error_class }}"/>
{{ message.errors.name | inline_errors }}
```

### id
Returns the ID of the message.

### subject
If subject is not present then either a truncated body or `(no subject)` string is returned.

### body
Returns body of the message.

### created_at
Returns the creation date.
```liquid
{{ message.created_at | date: i18n.short_date }}
```

### url
URL of the message detail, points either to inbox or outbox.

### state
Either 'read' or 'unread'.

### sender
Returns the name of the sender.

### to
Returns the name of the receiver.

### recipients

-----------

# Metric drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="metric[name]"
       value="{{ metric.name }}"
       class="{{ metric.errors.name | error_class }}"/>
{{ metric.errors.name | inline_errors }}
```

### unit
Returns the unit of the metric.
```liquid
This metric is measured in {{ metric.unit | pluralize }}
```

### description
Returns the description of the metric.

### name
Returns the name of the metric.
```liquid
<h3>Metric {{ metric.name }}</h3>
<p>{{ metric.description }}</p>
```

### system_name
Returns the system name of the metric.
```liquid
<h3>Metric {{ metric.name }}</h3>
<p>{{ metric.system_name }}</p>
```

### usage_limits
Returns the usage limits of the metric.
```liquid
{% if metric.usage_limits.size > 0 %}
   <p>Usage limits of the metric</p>
   <ul>
     {% for usage_limit in metric.usage_limits %}
       <li>{{ usage_limit.period }} : {{ usage_limit.value }}</li>
     {% endfor %}
   </ul>
 {% else %}
   <p>This metric has no usage limits.</p>
{% endif %}
```

### pricing_rules
Returns the pricing rules of the metric.
```liquid
{% if metric.pricing_rules.size > 0 %}
  <p>Pricing rules of the metric</p>
  <ul>
  {% for pricing_rule in metric.pricing_rules %}
    <li>{{ pricing_rule.cost_per_unit }}</li>
  {% endfor %}
  </ul>

{% else %}
  <p>This metric has no pricing rules.</p>
{% endif %}
```

### has_parent

-----------

# Page drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="page[name]"
       value="{{ page.name }}"
       class="{{ page.errors.name | error_class }}"/>
{{ page.errors.name | inline_errors }}
```

### title
Returns the title of the page.
```liquid
<title>{{ page.title }}</title>
```

### system_name
Returns system name of the page.
```liquid
{% if page.system_name == 'my_page' %}
  {% include 'custom_header' %}
{% endif %}
```

-----------

# Page drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="page[name]"
       value="{{ page.name }}"
       class="{{ page.errors.name | error_class }}"/>
{{ page.errors.name | inline_errors }}
```

### title

### kind

### url

### description

-----------

# Pagination drop





## Methods
### page_size
Number of items on one full page.
```liquid
<div class="pagination">
  {% for part in pagination.parts %}
    {% if part.is_link %}
      {% case part.rel %}
      {% when 'previous' %}
        {% assign css_class = 'previous_page' %}
      {% when 'next' %}
        {% assign css_class = 'next_page' %}
      {% else %}
        {% assign css_class = '' %}
      {% endcase %}

      <a class="{{ css_class }}" rel="{{ part.rel}}" href="{{ part.url }}">{{ part.title }}</a>
    {% else %}
      {% case part.rel %}
      {% when 'current' %}
         <em class="current">{{ part.title }}</em>
      {% when 'gap' %}
         <span class="gap">&#x2026;</span>
      {% else %}
         <span>{{ part.title }}</span>
      {% endcase %}
    {% endif %}
  {% endfor %}
</div>


<!-- Outputs:
  ============================================
<div class="pagination">
  <a class="previous_page" rel="prev" href="?page=7">&#x2190; Previous</a>
  <a rel="start" href="?page=1">1</a>
  <a href="?page=2">2</a>
  <a href="?page=3">3</a>
  <a href="?page=4">4</a>
  <a href="?page=5">5</a>
  <a href="?page=6">6</a>
  <a rel="prev" href="?page=7">7</a>
  <em class="current">8</em>
  <a rel="next" href="?page=9">9</a>
  <a href="?page=10">10</a>
  <a href="?page=11">11</a>
  <a href="?page=12">12</a>
  <span class="gap">&#x2026;</span>
  <a href="?page=267">267</a>
  <a href="?page=268">268</a>
  <a class="next_page" rel="next" href="?page=9">Next &#x2192;</a>
</div>
=======================================
-->
```

### current_page
Number of the currently selected page.

### current_offset
Items skipped so far.

### pages
Total number of pages.

### items
Total number of items in all pages.

### previous
Number of the previous page or empty.

### next
Number of the next page or empty.

### parts
Elements that render a user-friendly pagination. See the [part drop](#part-drop) for more information.

-----------

# Part drop





## Methods
### url

### rel

### current?

### is_link

### title

### to_s

-----------

# PaymentGateway drop





## Methods
### braintree_blue?
Returns whether current payment gateway is authorize.Net.

### authorize_net?
Returns whether current payment gateway is authorize.Net.

### type
Returns the type of the payment gateway.

-----------

# PaymentTransaction drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="payment_transaction[name]"
       value="{{ payment_transaction.name }}"
       class="{{ payment_transaction.errors.name | error_class }}"/>
{{ payment_transaction.errors.name | inline_errors }}
```

### currency
Returns the currency.
```liquid
{% for payment_transaction in invoice.payment_transactions %}
  <tr>
    <td> {% if payment_transaction.success? %} Success {% else %} Failure {% endif %} </td>
    <td> {{ payment_transaction.created_at }} </td>
    <td> {{ payment_transaction.reference }} </td>
    <td> {{ payment_transaction.message }} </td>
    <td> {{ payment_transaction.amount }} {{ payment_transaction.currency }} </td>
  </tr>
{% endfor %}
```

### amount
Returns the amount.

### created_at
Returns the creation date.

### success?
Returns true if successful.

### message
Returns the message of the transaction.

### reference
Returns the reference.

-----------

# PlanChange drop

An attempt of plan change. It is used in plan upgrade workflow when developer does not have credit card details filled in and wants to upgrade to a paid plan

```liquid
<div class="row">
  <div class="col-md-9">
    {% if plan_changes.size > 0 %}
    <p>
      You have begun to change plans of the following applications. <br>
      Please review.
    </p>
    <table class="table panel panel-default" id="applications">
      <thead class="panel-heading">
      <tr>
        <th>Name</th>
        <th>Chosen plan</th>
        <th>Accept</th>
        <th>Reject</th>
      </tr>
      </thead>
      <tbody class="panel-body">
      {% for change in plan_changes %}
      <tr class="{% cycle 'applications': 'odd', 'even' %}" id="application_{{ change.contract_id }}">
        <td>
          {{ change.contract_name }}
        </td>
        <td>
          From <strong>{{ change.plan_name }}</strong> to <strong>{{ change.new_plan_name }}</strong>
        </td>
        <td>
          {{ 'Confirm' | update_button: change.confirm_path , class: 'plan-change-button' }}
        </td>
        <td>
          {{ 'Cancel' | delete_button: change.cancel_path , class: 'plan-change-button' }}
        </td>
      </tr>
      {% endfor %}
      </tbody>

    </table>
    {% else %}
    <p>
      You have no changes in your application plans.
      {{ 'Go back to applications' | link_to: urls.applications }}
    </p>
    {% endif %}
  </div>
</div>
```

## Methods
### contract
Returns the contract on which the changes will apply.

### plan
Returns the chosen plan.

### previous_plan
Returns the current plan.

### confirm_path
Returns the url to confirm the change. The request method must be POST

### cancel_path
Returns the url to cancel the change. The request method must be DELETE

-----------

# PlanFeature drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="plan_feature[name]"
       value="{{ plan_feature.name }}"
       class="{{ plan_feature.errors.name | error_class }}"/>
{{ plan_feature.errors.name | inline_errors }}
```

### name
Returns the name of the feature.
```liquid
<h1>Feature {{ feature.name }}</h1>
```

### description
Returns the description of the feature.

### has_description?
Returns description of the feature or information that there is no description.
```liquid
{% if feature.has_description? %}
  {{ feature.description }}
{% else %}
   This feature has no description.
{% endif %}
```

### system_name
Returns system name of the feature (system wide unique name).
```liquid
{% if feature.system_name == 'promo_feature' %}
  <div>This feature is available only today!</div>
{% endif %}
```

### enabled?

-----------

# Post drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="post[name]"
       value="{{ post.name }}"
       class="{{ post.errors.name | error_class }}"/>
{{ post.errors.name | inline_errors }}
```

### title

### kind

### url

### description

-----------

# Post drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="post[name]"
       value="{{ post.name }}"
       class="{{ post.errors.name | error_class }}"/>
{{ post.errors.name | inline_errors }}
```

### body
Text of the post.

### topic
Every post belongs to a [topic](#topic-drop).

### created_at
Date when this post created.
```liquid
{{ post.created_at | date: i18n.short_date }}
```

### url
The URL of this post within its topic.

-----------

# PricingRule drop





## Methods
### cost_per_unit
Returns the cost per unit of the pricing rule.
__Example:__ Using pricing rule drop in liquid.
```liquid
<h1>Pricing rule</h1>
<div>Min value {{ pricing_rule.min }}</div>
<div>Max value {{ pricing_rule.max }}</div>
<div>Cost per unit {{ pricing_rule.cost_per_unit }}</div>
```

### min
Returns the minimum value of the pricing rule.

### max
Returns the maximum value of the pricing rule.

### plan
Returns plan of pricing rule.

-----------

# Provider drop





## Methods
### name
Returns name of your organization. That can be changed via the [admin dashboard][provider-account-edit].
```liquid
<div>Domain {{ provider.domain }}</div>

{% if provider.multiple_applications_allowed? %}
   <div>
     <p>Applications</p>
     <ul>
     {% for app in account.applications %}
       <li>{{ app.name }}</li>
     {% endfor %}
     </ul>
   </div>
{% else %}
   <div>Application {{ account.applications.first.name }}</div>
{% endif %}

For general questions contact us at {{ provider.support_email }}.
For invoice or payment related questions contact us at {{ provider.finance_support_email }}.
```

### full_address
Can be composed by legal address, city and state.

### country_name
Returns the country.

### payment_gateway
Returns the payment gateway associated with your organization.

### domain
Domain of your developer portal.

### timezone
Returns timezone that you use. Can be changed in your [administration dashboard][provider-account-edit].

### support_email
Support email of the account.

### finance_support_email
Finance support email of the account.

### telephone_number
Returns the telephone number of the account.

### multiple_applications_allowed?
*True* if developers can have more separate applications with
              their own keys, stats, etc. __Depends on your 3scale plan__.
           
```liquid
{% if provider.multiple_applications_allowed? %}
   <div>
     <p>Applications</p>
     <ul>
     {% for app in account.applications %}
       <li>{{ app.name }}</li>
     {% endfor %}
     </ul>
   </div>
{% else %}
   <div>Application {{ account.applications.first.name }}</div>
{% endif %}
```

### logo_url
Returns the logo URL.
```liquid
<img src={{ provider.logo_url }}"/>
```

### multiple_services_allowed?
*True* if your 3scale plan allows you to manage multiple APIs
               as separate [services][support-terminology-service].
           
```liquid
{% if provider.multiple_services_allowed? %}
  {% for service in provider.services %}
     Service {{ service.name }} is available.
  {% endfor %}
{% endif %}
```

### finance_allowed?

### multiple_users_allowed?
*True* if the developer accounts can have multiple logins
              associated with them (__depends on your 3scale plan__)
              and its visibility has been turned on for your develoeper
              portal in the [settings][cms-feature-visibility].
```liquid
{% if provider.multiple_users_allowed? %}
  <ul id="subsubmenu">
    <li>
       {{ 'Users' | link_to: urls.users }}
    </li>
    <li>
      {{ 'Sent invitations' | link_to: urls.invitations }}
    </li>
  </ul>
{% endif %}
```

### account_plans
Returns all published account plans.
```liquid
<p>We offer following account plans:</p>
<ul>
{% for plan in model.account_plans %}
  <li>{{ plan.name }} <input type="radio" name="plans[id]" value="{{ plan.id }}"/></li>
{% endfor %}
</ul>
```

### services
Returns all defined services.
```liquid
<p>You can sign up to any of our services!</p>
<ul>
{% for service in provider.services %}
  <li>{{ service.name }} <a href="/signup/service/{{ service.system_name }}">Signup!</a></li>
{% endfor %}
```

### signups_enabled?
You can enable or disable signups in the [usage rules section][usage-rules] of your admin dashboard.

### account_management_enabled?
You can enable or disable account management in the [usage rules section][usage-rules].

### api_specs
Returns API spec collection.
```liquid
<ul>
{% for api_spec in provider.api_specs %}
  <li>{{ api_spec.system_name }}</li>
{% endfor %}
</ul>
```

-----------

# ReferrerFilter drop





## Methods
### id

### value

### delete_url

### application

-----------

# Request drop



__Example:__ Using request drop in liquid.
```liquid
<h1>Request details</h1>
<div>URI {{ request.request_uri }}</div>
<div>Host {{ request.host }}</div>
<div>Host and port {{ request.host_with_port }}</div>
```

## Methods
### request_uri
Returns the URI of the request.

### host_with_port
Returns the host with port of the request.

### host
Returns the host part of the request URL.

### path
Returns the path part of the request URL.
```liquid
{% if request.path == '/' %}
  Welcome on a landing page!
{% else %}
  This is just an ordinary page.
{% endif %}
```

-----------

# Role drop





## Methods
### name
Returns internal name of the role, important for the system.

### description
Returns description of the role.

-----------

# SSOAuthorization drop





## Methods
### authentication_provider_system_name
Returns the authentication provider name.
```liquid
{% for authorization in current_user.sso_authorizations %}
  <p>{{ authorization.authentication_provider_system_name }}</p>
{% endfor %}
```

### id_token
Returns the id_token.
```liquid
{% for authorization in current_user.sso_authorizations %}
  <p>{{ authorization.id_token }}</p>
{% endfor %}
```

-----------

# Search drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="search[name]"
       value="{{ search.name }}"
       class="{{ search.errors.name | error_class }}"/>
{{ search.errors.name | inline_errors }}
```

### query
Returns the searched string.
```liquid
<h2>{{ search.token }}</h2>
<p>found on {{ search.total_found }} {{ search.item | pluralize }} </p>
<dl>
  {% for result in search.results %}
    <dt>
      <span class="kind"> [ {{ result.kind | capitalize}} ] </span>
      {{ result.title | link_to: result.url }}
    </dt>
    <dd>
      {{ result.description }}
    </dd>
  {% endfor %}
</dl>
```

### total_found
Returns the number of matching elements.

### results
Returs an array of results for the search.

-----------

# Service drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="service[name]"
       value="{{ service.name }}"
       class="{{ service.errors.name | error_class }}"/>
{{ service.errors.name | inline_errors }}
```

### name
Returns the name of the service.

### system_name
Returns the system name of the service.
```liquid
{% case service.system_name %}
{% when 'api' %}
  API is our newest service!
{% when 'old' %}
  Unfortunately we dont allow more signups to our old service.
{% endcase %}
```

### description
Returns the description of the service.

### subscribed?
Returns whether the service is subscribed to.
```liquid
{% if service.subscribed? %}
   <p>You already subscribed to this service.</p>
{% endif %}
```

### subscription

Returns subscription (`ServiceContract` drop) of the currently
logged in user if they are subscribed to this service, Nil otherwise.
            
```liquid
{% if service.subscription %}
   Your applications for service {{ service.name }} are:
   {% for app in service.subscription.applications %}
     {{ app.name }}<br/>
   {% endfor %}
{% else %}
   <p>You are not subscribed to this.</p>
{% endif %}
```

### subscribable?

### subscribe_url

### application_plans
Returns the **published** application plans of the service.
```liquid
{% for service in model.services %}
  <h3>{{ service.name }} application plans:</h3>
  <dl>
  {% for application_plan in service.application_plans %}
    <dt>{{ application_plan.name }}</dt>
    <dd>{{ application_plan.system_name }}</dd>
  {% endfor %}
  </dl>
{% endfor %}
```

### service_plans
Returns the *published* service plans of the service.
```liquid
<p>We offer following service plans:</p>
<dl>
{% for service in model.services %}
  {% for service_plan in service.service_plans %}
    <dt>{{ service_plan.name }}</dt>
    <dd>{{ service_plan.system_name }}</dd>
  {% endfor %}
{% endfor %}
</dl>
```

### plans
Returns the application plans of the service.

### features
Returns the visible features of the service.
```liquid
{% if service.features.size > 0 %}
  <p>{{ service.name }} has following features:</p>
  <ul>
  {% for feature in service.features %}
    <li>{{ feature.name }}</li>
  {% endfor %}
  </ul>
{% else %}
  <p>Unfortunately, {{ service.name }} currently has no features.</p>
{% endif %}
```

### apps_identifier

Depending on the authentication mode set, returns either 'ID',
'API key' or 'Client ID' for OAuth authentication.
      
```liquid
{{ service.application_key_name }}
```

### backend_version

### referrer_filters_required?

### metrics
Returns the metrics of the service.
```liquid
<p>On {{ service.name }} we measure following metrics:</p>
<ul>
{% for metric in service.metrics %}
  <li>{{ metric.name }}</li>
{% endfor %}
</ul>
```

### support_email
Support email of the service.

### api_specs
Returns API spec collection.
```liquid
<ul>
{% for api_spec in service.api_specs %}
  <li>{{ api_spec.system_name }}</li>
{% endfor %}
</ul>
```

-----------

# ServiceContract drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="service_contract[name]"
       value="{{ service_contract.name }}"
       class="{{ service_contract.errors.name | error_class }}"/>
{{ service_contract.errors.name | inline_errors }}
```

### id

### can_change_plan?
Returns true if any change is possible.

### trial?

Returns true if the contract is still in the trial period.

__Note__: If you change the trial period length of a plan,
it does not affect existing contracts.
           

### live?

### state
There are three possible states:

        - pending
        - live
        - suspended
      

### remaining_trial_period_days
Number of days left in the trial period.

### plan
Returns the plan of the contract.

### plan_change_permission_name
Returns name of the allowed action.

### plan_change_permission_warning
Returns a warning message for the allowed action.

### name

### system_name

### change_plan_url

### service

### applications

### can
Exposes specific rights of the current user for that subscription.
```liquid
{% if subscription.can.change_plan? %}
  ...
{% endif %}
```

-----------

# ServicePlan drop





## Methods
### selected?
Returns whether the plan is selected.
```liquid
{% if plan.selected? %}
  <p>You will signup to {{ plan.name }}</p>
{% endif %}
```

### bought?
Returns whether the plan is bought.
```liquid
{% if plan.bought? %}
   <p>You are  on this plan already!</p>
{% endif %}
```

### features
Returns the visible features of the plan.
```liquid
{% if plan == my_free_plan %}
   <p>These plans are the same.</p>
{% else %}
   <p>These plans are not the same.</p>
{% endif %}
```

### setup_fee
Returns the setup fee of the plan.

### name
Returns the name of the plan.
```liquid
<h1>We offer you a new {{ plan.name }} plan!</h1>
```

### system_name
Returns the system name of the plan.
```liquid
{% for plan in available_plans %}
  {% if plan.system_name == 'my_free_plan' %}
    <input type="hidden" name="plans[system_name]" value="{{ plan.system_name }}"/>
    <p>You will buy our only free plan!</p>
  {% endif %}
{% endfor %}
```

### id
Returns the plan ID.

### free?
The plan is free if it is not 'paid' (see the 'paid?' method).
```liquid
{% if plan.free? %}
   <p>This plan is free of charge.</p>
{% else %}
   <div>
     <p>Plan costs:</p>
     <div>Setup fee {{ plan.setup_fee }}</div>
     <div>Flat cost {{ plan.flat_cost }}</div>
  </div>
{% endif %}
```

### trial_period_days
Returns the number of trial days in a plan.
```liquid
<p>This plan has a free trial period of {{ plan.trial_period_days }} days.</p>
```

### paid?
The plan is 'paid' when it has a non-zero fixed or setup fee or there are pricing rules present.
```liquid
{% if plan.paid? %}
   <p>this plan is a paid one.</p>
{% else %}
   <p>this plan is a free one.</p>
{% endif %}
```

### approval_required?
Returns whether the plan requires approval.
```liquid
{% if plan.approval_required? %}
   <p>This plan requires approval.</p>
{% endif %}
```

### flat_cost
Returns the monthly fixed fee of the plan. (including currency)

### cost
Returns the monthly fixed fee of the plan.

### service
__Example:__ Using service plan drop in liquid.
```liquid
<p class="notice">The examples for plan drop apply here</p>
<div>Service of this plan {{ plan.service.name }}</div>
```

-----------

# TimeZone drop





## Methods
### full_name

### to_str

### identifier

-----------

# Today drop





## Methods
### month
Returns current month (1-12).

### day
Returns current day of the month (1-31).

### year
Returns current year.
__Example:__ Create dynamic copyright
```liquid
<span class="copyright">&copy;{{ today.year }}</span>
```

### beginning_of_month
Returns the date of beginning of current month.
```liquid
This month began on {{ today.beginning_of_month | date: '%A' }}
```

-----------

# Topic drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="topic[name]"
       value="{{ topic.name }}"
       class="{{ topic.errors.name | error_class }}"/>
{{ topic.errors.name | inline_errors }}
```

### title
Name of the topic. Submitted when first post to the thread is posted.

### url

-----------

# Topic drop





## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="topic[name]"
       value="{{ topic.name }}"
       class="{{ topic.errors.name | error_class }}"/>
{{ topic.errors.name | inline_errors }}
```

### title

### kind

### url

### description

-----------

# Url drop





## Methods
### to_s

### to_str

### title

### current_or_subpath?

True if the path of the current page is the same as this one
or it's a subpath of it (i.e. extended by ID). For
example with `{{ urls.messages_outbox }}` these will return true:

 - /admin/sent/messages/sent
 - /admin/sent/messages/sent/42

But not these:

 - /admin/sent/messsages/new
 - /admin/sent/messsages/received/2

See also '#active?', '#current?'.
      

### current?

True if the URL's path is the the same as of the current. Parameters
and other components are not taken into account. See also '#active?'.
      
```liquid
{% assign url = urls.messages_inbox %}
<!-- => http://awesome.3scale.net/admin/messages/sent -->

<!-- Current page: http://awesome.3scale.net/admin/messages/sent?unread=1 -->
{{ url.current? }} => true

<!-- Current page: http://awesome.3scale.net/admin/messages -->
{{ url.current? }} => false
```

### active?

True if the current page is in the same menu structure
as this URL. See also '#current?'.
      
```liquid
{% assign url = urls.messages_inbox %}
<!-- => http://awesome.3scale.net/admin/messages/sent -->

<!-- Current page: http://awesome.3scale.net/admin/messages -->
{{ url.active? }} => true

<!-- Current page: http://awesome.3scale.net/admin/messages/trash -->
{{ url.active? }} => true

<!-- Current page: http://awesome.3scale.net/admin/stats -->
{{ url.active? }} => false
```

-----------

# Urls drop





## Methods
### provider

### cas_login
```liquid
<a href="{{ urls.signup }}">sign up here</a>
<a href="{{ urls.service_subscription }}">subscribe to a service here</a>
```

### new_application

### signup
URL of a signup page. Accessible for everyone.
```liquid
<a href="{{ urls.signup }}?{{ service_plan | param_filter }}&{{ app_plan | param_filter }}" >Signup Now!</a>
```

### search
URL which all the search requests should be sent to.
```liquid
<form action="{{ urls.search }}" method="get">
  <input name="q" type="text" title="Search the site" value=""/>
  <input type="submit" value="Search" name="commit">
</form>
```

### login

### logout

### forgot_password

### service_subscription
URL to the service subscription page. Only for logged in users.
```liquid
<a href="{{ urls.service_subscription }}?{{ service_plan | param_filter }}" >
  Subscribe to service {{ service.name }}
</a>
```

### compose_message
URL to a page that allows the developer to contact provider via the internal messaging system.

### messages_new
URL to a page that allows the developer to contact provider via the internal messaging system.

### messages_outbox
URL to the list of messages sent by a developer.

### messages_trash

### empty_messages_trash

### credit_card_terms

### credit_card_privacy

### credit_card_refunds

### personal_details
URL or Nil if user account management is disabled (check your [usage rules section][usage-rules]).

### access_details
A page with API key(s) and other authentication information. Depends on the authentication strategy.

### new_invitation
Page to invite new users.

### invitations
List of all the sent invitations.

### dashboard

### applications

### api_access_details

### services

### messages_inbox
URL to the list of received messages.

### stats

### account_overview

### users

### account_plans

### invoices

### payment_details
A page to enter credit card details. Differs depending on the payment gateway of your choice.

-----------

# UsageLimit drop



__Example:__ Using usage limit drop in liquid.
```liquid
You cannot do more than {{ limit.value }} {{ limit.metric.unit }}s per {{ limit.period }}
```

## Methods
### period
Returns the period of the usage limit.

### metric
Usually `hits` but can be any custom method.

### value
Returns the value of the usage limit.

-----------

# User drop



```liquid
<h1>User {{ user.display_name }}</h1>
<div>Account {{ user.account.name }}</div>
<div>Username {{ user.username }}</div>
<div>Email {{ user.email }}</div>
<div>Website {{ user.website }}</div>
```

## Methods
### errors

If a form for this model is rendered after unsuccessful submission,
this returns the errors that occurred.
```liquid
<input name="user[name]"
       value="{{ user.name }}"
       class="{{ user.errors.name | error_class }}"/>
{{ user.errors.name | inline_errors }}
```

### admin?
Returns whether the user is an admin.
```liquid
{% if user.admin? %}
  <p>You are an admin of your account.</p>
{% endif %}
```

### username
Returns the username of the user, HTML escaped.

### account
Returns the account of the user.

### name
Returns the first and last name of the user.

### oauth2?
Returns true if user has stored oauth2 authorizations

### email
Returns the email of the user.

### password_required?

This method will return `true` for users using the built-in
Developer Portal authentication mechanisms and `false` for
those that are authenticated via Janrain, CAS or other
single-sign-on method.
      
```liquid
{{ if user.password_required? }}
  <input name="account[user][password]" type="password">
  <input name="account[user][password_confirmation]" type="password">
{{ endif }}
```

### sections
Returns the list of sections the user has access to.
```liquid
{% if user.sections.size > 0 %}
  <p>You can access following sections of our portal:</p>
   <ul>
    {% for section in user.sections %}
      <li>{{ section }}</li>
    {% endfor %}
  </ul>
{% endif %}
```

### role
Returns the role of the user.

### roles_collection
Returns a list of available roles for the user.
```liquid
{% for role in user.roles_collection %}
  <li>
    <label for="user_role_{{ role.key }}">
      <input
        {% if user.role == role.key %}
          checked="checked"
        {% endif %}
      class="users_ids" id="user_role_{{ role.key }}" name="user[role]" type="radio" value="{{ role.key }}">
      {{ role.text }}
    </label>
    </li>
  {% endfor %}
```

### url
Returns the resource URL of the user.
```liquid
{{ 'Delete' | delete_button: user.url }}
```

### edit_url
Returns the URL to edit the user.
```liquid
{{ 'Edit' | link_to: user.edit_url, title: 'Edit', class: 'action edit' }}
```

### can
Gives access to permission methods.
```liquid
{% if user.can.be_managed? %}
  <!-- do something -->
{% endif %}
```

### extra_fields
Returns non-hidden extra fields with values for this user.
__Example:__ Print all extra fields.
```liquid
{% for field in user.extra_fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### fields
Returns all fields with values for this user.
__Example:__ Print all fields.
```liquid
{% for field in user.fields %}
  {{ field.label }}: {{ field.value }}
{% endfor %}
```

### builtin_fields
Returns all built-in fields with values for this user.

-----------

