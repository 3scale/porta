@javascript
Feature: ActiveDocs
  In order to rule the world
  As a provider

  Background:
    Given a provider "foo.3scale.localhost"
    And the current provider is foo.3scale.localhost

  Scenario: Loading Swagger UI v2
    Given a service with a Swagger 2 spec
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

    And the current domain is "foo.3scale.localhost"
    When I visit "/version-20"
    Then I should see "A sample echo API"

  Scenario: Loading new Swagger v2 template with new cdn_asset tag
    Given a service with a Swagger 2 spec
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

    And the current domain is "foo.3scale.localhost"
    When I visit "/version-22"
    Then I should see "A sample echo API"
