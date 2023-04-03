@javascript
Feature: ActiveDocs
  In order to rule the world
  As a provider

  Background:
    Given a provider "foo.3scale.localhost"
    And the current provider is foo.3scale.localhost

  Scenario: Loading ActiveDocs 1.0
    Given a service with a Swagger 1.2 spec
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

    And the current domain is "foo.3scale.localhost"
    When I visit "/version-10"
    Then I should see "Echo"
