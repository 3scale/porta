@javascript
Feature: CMS Partials
  As a provider
  I want to manage CMS data objects

  Background:
    Given a provider is logged in
    And I go to the CMS page
    And wait a moment

  Scenario: Partial
    Given they select "New Partial" from the CMS new content dropdown
    And I fill in the following:
      | System name | potato |
    And fill in the draft with:
      """
      awesomeness builtin
      """
    And I press "Create Partial"
    Then I should see "Template created"
    When I fill in the following:
      | System name | brand-new-potato |
    And I press "Save"
    Then I should see "Template saved"
    Then field "System name" should be "brand-new-potato"
    And the draft template should contain "awesomeness builtin"

  Scenario: Builtin partial
    Given provider "foo.3scale.localhost" has all the templates setup
    When I go to the CMS page
    And follow "submenu" within the CMS sidebar
    And fill in the draft with:
      """
      awesomeness builtin
      """
    And I press "Save"
    Then I should see "Template saved"
    And I press "Publish"
    Then I should see "Template saved and published"
