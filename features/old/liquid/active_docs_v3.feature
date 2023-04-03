@javascript
Feature: ActiveDocs
  In order to rule the world
  As a provider

  Background:
    Given a provider "foo.3scale.localhost"
    And the current provider is foo.3scale.localhost

  Scenario: Loading new Swagger template with javascript packs
    Given a service with a OAS 3.0 spec
    And the provider has cms page "/swagger-ui-3" with:
    """
    {% content_for javascripts %}
      {{ 'active_docs.js' | javascript_include_tag }}
    {% endcontent_for %}

    <h3>ActiveDocs version 3</h3>

    <div id="swagger-ui-container">

    <script type="text/javascript">
      (function () {
        var url = "{{provider.api_specs.first.url}}";
        SwaggerUI({
          url: url,
          dom_id: '#swagger-ui-container',
          supportedSubmitMethods: ['get', 'post', 'put', 'delete', 'patch'],
          apisSorter: 'alpha',
          operationsSorter: 'method',
          docExpansion: 'list',
          transport: function (httpClient, obj) { ApiDocsProxy.execute(httpClient, obj) }
        });
      }());
    </script>
    """
    And the cms page "/swagger-ui-3" has main layout

    And the current domain is "foo.3scale.localhost"
    When I visit "/swagger-ui-3"
    Then I should see "A sample echo API"
