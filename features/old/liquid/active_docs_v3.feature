@javascript
Feature: ActiveDocs
  In order to rule the world
  As a provider

  Background:
    Given a provider "foo.example.com"
    And the current provider is foo.example.com

  # FIXME packs are not loaded
  @wip
  Scenario: Loading new Swagger template with javascript packs
    Given provider "foo.example.com" has the swagger example of signup
    And the provider has cms page "/swagger-ui-3" with:
    """
    {% content_for javascripts %}
      {{ 'active_docs.js' | javascript_include_tag }}
    {% endcontent_for %}

    <h3>ActiveDocs version 3</h3>

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

    And the current domain is "foo.example.com"
    When I visit "/swagger-ui-3"
    Then I should see "A sample echo API"
