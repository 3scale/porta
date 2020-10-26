@javascript
Feature: Services switch
  To have different provider plans
  As a member or admin
  I want to see correct links depending on my multiple service switch activation

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has multiple applications enabled
      And an application plan "pro3M" of provider "master"
      And service discovery is not enabled
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"

  @wip
  Scenario: In denied state, I should see link to upgrade warning
    Given I am on the provider dashboard
      And I follow "Create Product"
    Then I should be on the upgrade notice page for "multiple_services"

  Scenario: In allowed state (hidden and visible), I should have the functionality enabled
    Given provider "foo.3scale.localhost" has "multiple_services" switch allowed
      And I am on the provider dashboard
      And I follow "Create Product"
    Then I should be on the new service page

  Scenario: In allowed state (hidden and visible), I should be able to access the page by url
    Given provider "foo.3scale.localhost" has "multiple_services" switch allowed
      And I go to the new service page
    Then I should see "New Product"
