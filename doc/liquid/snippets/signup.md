__Signup__ - Signup links to all plans of a service with system name 'api'.

```liquid
{% for plan in provider.services.api.application_plans %}
  <a href="{{ urls.signup }}?{{ plan | to_param }}">
    Signup to plan {{ plan.name }}
  </a>
{% endfor %}
```
