__Application Keys__ - List keys of the first app of a currently logged-in user.

```liquid
{% assign application = current_account.applications.first %}

<dl>Application</dl>: <dd>{{ application.name }}</dd>
<dl>App ID</dl>:      <dd>{{ application.application_id }}</dd>
<dl>Keys</dl>:        <dd>{{ application.keys | join: ', ' }}</dd>
```