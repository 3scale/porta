@javascript
Feature: Services switch
  To have different provider plans
  As a member or admin
  I want to see correct links depending on my multiple service switch activation

  Background:
    Given a provider is logged in
    And the provider has "multiple_applications" visible
    Given the default product of provider "master" has name "Master API"
    Given the following application plan:
      | Product    | Name  |
      | Master API | pro3M |
    And service discovery is not enabled

  @wip
  Scenario: In denied state, I should see link to upgrade warning
    Given I am on the provider dashboard
    And I follow "Create Product"
    Then I should be on the upgrade notice page for "multiple_services"

  Scenario: In allowed state (hidden and visible), I should have the functionality enabled
    Given the provider has "multiple_services" switch allowed
    And I am on the provider dashboard
    And I follow "Create Product"
    Then I should be on the new service page

  Scenario: In allowed state (hidden and visible), I should be able to access the page by url
    Given the provider has "multiple_services" switch allowed
    And I go to the new service page
    Then I should see "New Product"
