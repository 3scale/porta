__Menu__ - A basic developer portal navigation widget.

```liquid
{% if current_user %}
  <b>{{ current_user.username }}</b> |
  {{ 'Dashboard' | link_to: urls.dashboard }}
  {{ 'Logout'    | link_to: urls.logout }}
{% else %}
  {{ 'Login'  | link_to: urls.login }}
  {{ 'Signup' | link_to: urls.signup }}
{% endif %}
```
