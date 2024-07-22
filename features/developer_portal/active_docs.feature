@javascript
Feature: ActiveDocs

  As a provider, I want to show my API documentation in the developer portal.

  Background:
    Given a provider
    And a product "My API"
    And a buyer "Jane"
    And the buyer logs in

  Scenario: Loading ActiveDocs 1.0
    Given the product has a Swagger 1.2 spec "Echo"
    And the provider has cms page "/version-10" with:
      """
      {% active_docs version: "1.0" %}

      <h3>ActiveDocs version 1.0</h3>

      <div class='api-docs-wrap'></div>

      <script type="text/javascript">
        $(function () {
          ThreeScale.APIDocs.init([]);
        });
      </script>
      """
    And the cms page "/version-10" has main layout
    When they visit "/version-10"
    Then they should see "Echo"

  Scenario: Loading Swagger UI v2
    Given the product has a Swagger 2 spec "Echo"
    And the provider has cms page "/version-20" with:
      """
      {% active_docs version: "2.0" %}

      <h3>ActiveDocs version 2.0</h3>

      <script type="text/javascript">
        $(function () {
          window.swaggerUi.load();
        });
      </script>
      """
    And the cms page "/version-20" has main layout
    When they visit "/version-20"
    Then they should see "A sample echo API"

  Scenario: Loading new Swagger v2 template with new cdn_asset tag
    Given the product has a Swagger 2 spec "Echo"
    And the provider has cms page "/version-22" with:
      """
      {% cdn_asset /swagger-ui/2.2.10/swagger-ui.js %}
      {% cdn_asset /swagger-ui/2.2.10/swagger-ui.css %}

      <h3>ActiveDocs version 2.2.10</h3>

      {% include 'shared/swagger_ui' %}

      <script type="text/javascript">
        (function () {
          window.swaggerUi.load();
        }());
      </script>
      """
    And the cms page "/version-22" has main layout
    When they visit "/version-22"
    Then they should see "A sample echo API"

  Scenario: Loading OAS 3.0 template with javascript packs
    Given the product has a OAS 3.0 spec "Echo"
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
    When they visit "/swagger-ui-3"
    Then they should see "A sample echo API"
