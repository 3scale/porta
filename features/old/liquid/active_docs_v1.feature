@javascript
Feature: ActiveDocs
  In order to rule the world
  As a provider

  Background:
    Given a provider "foo.example.com"
    And the current provider is foo.example.com

  Scenario: Loading ActiveDocs 1.0
    Given provider "foo.example.com" has a swagger 1.0
    Given the provider has CMS Page "/version-10" with:
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
    And the CMS Page "/version-10" has main layout

    And the current domain is "foo.example.com"
    When I visit "/version-10"
    Then I should see "Echo"
