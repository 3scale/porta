@javascript
Feature: Creating layout for CMS pages
  As a provider
  I want to manage CMS data objects

  Background:
    Given a provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost" on its admin domain
    And I go to the CMS page

  Scenario: Layout
    When I follow "New Layout" from the CMS dropdown
    And I fill in the following:
      | System name | potato |

    And I fill in the draft with:
        """
          {% content %}
        """
    And I press "Create Layout"
    Then I should see "Layout created"

    When I fill in the following:
      | System name | brand-new-potato |
    And I press "Save"
    Then I should see "Layout saved"

    When I press "Publish"
    Then I should see "Layout saved and published"
