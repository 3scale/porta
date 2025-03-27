@javascript
Feature: CMS Partials
  As a provider
  I want to manage CMS data objects

  Background:
    Given a provider is logged in
    And I go to the CMS page

  Scenario: Partial
    When I follow "New Partial" from the CMS "New Page" dropdown
    And I fill in the following:
      | System name | potato |
    And I fill in the draft with:
      """
      awesomeness builtin
      """
    And I press "Create Partial"
    Then I should see "Partial created"
    When I fill in the following:
      | System name | brand-new-potato |
    And I press "Save"
    Then I should see "Partial saved"
    And CMS Partial "brand-new-potato" should have:
      | Draft       | awesomeness builtin |
      | System name | brand-new-potato    |

  Scenario: Builtin partial
    Given provider "foo.3scale.localhost" has all the templates setup
    When I go to the CMS page
    And I choose builtin page "submenu" in the CMS sidebar
    And I fill in the draft with:
      """
      awesomeness builtin
      """
    And I press "Save"
    Then I should see "Partial saved"
    And I press "Publish"
    Then I should see "Partial saved and published"
