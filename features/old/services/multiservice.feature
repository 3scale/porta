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
    When I am on the provider dashboard
    Then I should see "New Product"
    Then I should see "New Backend"

  @javascript
  Scenario: Create new product
    Given I am logged in as provider "foo.example.com"
      And provider "foo.example.com" has "multiple_services" switch allowed
      And service discovery is not enabled
    When I am on the provider dashboard
     And I follow "New Product"
     And I fill in "Name" with "Less fancy API"
     And I press "Create Product"
    Then I should see "Less fancy API"

  @javascript
  Scenario: Create new product: Fail scenario error message
    Given I am logged in as provider "foo.example.com"
    And provider "foo.example.com" has "multiple_services" switch allowed
    And service discovery is not enabled
    When I am on the provider dashboard
    And I follow "New Product"
    And I fill in "Name" with "Invalid API"
    And I fill in "System name" with "I am using spaces"
    And I press "Create Product"
    Then I should see the flash message "System name invalid. Only ASCII letters, numbers, dashes and underscores are allowed."

  @wip
  Scenario: Create new backend
    Given I am logged in as provider "foo.example.com"
      And provider "foo.example.com" has "multiple_services" switch allowed
      And service discovery is not enabled
    When I am on the provider dashboard
     And I follow "New Backend"
    #  And I fill in "Name" with "Less fancy Backend"
    #  And I press "Add Backend"
    # Then I should see "Less fancy Backend"

  @javascript
  Scenario: Edit service
    Given I am logged in as provider "foo.example.com"
      And all the rolling updates features are off
      And I am on the edit page for service "Fancy API" of provider "foo.example.com"
    When I fill in "Name" with "Less fancy API"
     And I press "Update Service"
     And I follow "Integration" within the main menu
     And I follow "Settings"
     And I uncheck "Developers can manage applications"
     And I press "Update Service"
    Then I should see "Less fancy API"

  Scenario: Delete Service
    Given I am logged in as provider "foo.example.com"
    And provider "foo.example.com" has "multiple_services" switch allowed
    And I am on the edit page for service "Second service" of provider "foo.example.com"
    When I follow "I understand the consequences, proceed to delete 'Second service' service" and I confirm dialog box
    Then I should see "Product 'Second service' will be deleted shortly."

  Scenario: Delete Service without apiap
    Given I am logged in as provider "foo.example.com"
    And provider "foo.example.com" has "multiple_services" switch allowed
    And I have rolling updates "api_as_product" disabled
    And I am on the edit page for service "Second service" of provider "foo.example.com"
    When I follow "I understand the consequences, proceed to delete 'Second service' service" and I confirm dialog box
    Then I should see "Service 'Second service' will be deleted shortly."

  @javascript
  Scenario: Folded services have no overview data
    Given I am logged in as provider "foo.example.com"
    And provider "foo.example.com" has "multiple_services" switch allowed
    When I am on the provider dashboard
    And service "Fancy API" is folded
    Then I should not see "Fancy API" overview data
