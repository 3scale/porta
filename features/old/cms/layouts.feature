@javascript
Feature: Creating layout for CMS pages
  As a provider
  I want to manage CMS data objects

  Background:
    Given a provider is logged in
    And I go to the CMS page

  Scenario: Layout
    When I follow "New Layout" from the CMS "New Page" dropdown
    And I fill in the following:
      | System name | potato |
    And I fill in the draft with:
      """
      {% content %}
      """
    And I press "Create Layout"
    Then I should see "Template created"
    When I fill in the following:
      | System name | brand-new-potato |
    And I press "Save"
    Then I should see "Template saved"
    When I press "Publish"
    Then I should see "Template saved and published"
