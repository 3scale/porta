Feature: Multiservice feature
  In order to provide various APIs
  As a provider
  I want to have multiple services

  Background:
    Given a provider "foo.example.com"
    And a default service of provider "foo.example.com" has name "Fancy API"
    And a service "Second service" of provider "foo.example.com"
    And current domain is the admin domain of provider "foo.example.com"

  Scenario: Can create new service setting
    Given I am logged in as provider "foo.example.com"
     And provider "foo.example.com" has "can create service" set to "true"
    When I am on the provider dashboard page
    Then I should see "Create Service"
     And I should see "ID for API calls is"
     And I should see "system name is"

  @javascript
  Scenario: Create new service
    Given I am logged in as provider "foo.example.com"
      And provider "foo.example.com" has "multiple_services" switch allowed
      And service discovery is not enabled
    When I am on the provider dashboard page
     And I follow "Create Service"
     And I fill in "Name" with "Less fancy API"
     And I press "Create Service"
    Then I should see "Less fancy API"

  Scenario: Edit service
    Given I am logged in as provider "foo.example.com"
      And I am on the edit page for service "Fancy API" of provider "foo.example.com"
    When I fill in "Name" with "Less fancy API"
     And I press "Update Service"
     And I follow "Settings" within the side tabs
     And I uncheck "Developers can manage applications"
     And I press "Update Service"
     And I follow "Less fancy API"
    Then I should see "Less fancy API"

  @javascript
  Scenario: Delete Service
    Given I am logged in as provider "foo.example.com"
    And provider "foo.example.com" has "multiple_services" switch allowed
    And I am on the edit page for service "Second service" of provider "foo.example.com"
    When I follow "I understand the consequences, proceed to delete 'Second service' service" and I confirm dialog box
    Then I should see "Service 'Second service' will be deleted shortly."
