@javascript @ajax @selenium
Feature: ActiveDocs
  In order to rule the world
  As a provider

  Background:
    Given a provider "foo.example.com"
    And the current provider is foo.example.com

  Scenario: Loading ActiveDocs 1.0
    Given provider "foo.example.com" has a swagger 1.0
    Given the provider has cms page "/version-10" with:
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

    And the current domain is "foo.example.com"
    When I visit "/version-10"
    Then I should see "Echo"

  Scenario: Loading Swagger UI
    Given provider "foo.example.com" has the swagger example of signup
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

    And the current domain is "foo.example.com"
    When I visit "/version-20"
    Then I should see "A sample echo API"

  Scenario: Loading new Swagger template with new cdn_asset tag
    Given provider "foo.example.com" has the swagger example of signup
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

    And the current domain is "foo.example.com"
    When I visit "/version-22"
    Then I should see "A sample echo API"
