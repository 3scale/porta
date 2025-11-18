@javascript
Feature: Multiservice feature
  In order to provide various APIs
  As a provider
  I want to have multiple services

  Background:
    Given a provider is logged in
    And the provider has "multiple_services" visible
    And a default service of provider "foo.3scale.localhost" has name "Fancy API"

  Scenario: Can create new service setting
    Given the provider has the following setting:
      | can create service | true |
    When I am on the provider dashboard
    Then I should see "Create Product"
    Then I should see "Create Backend"

  Scenario: Create new product
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And service discovery is not enabled
    When I am on the provider dashboard
    And I follow "Create Product"
    And I fill in "Name" with "Less fancy API"
    And I press "Create Product"
    Then I should see "Less fancy API"

  Scenario: Create new product: with blank product name
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And service discovery is not enabled
    When I am on the provider dashboard
    And I follow "Create Product"
    And I fill in "System name" with "Less fancy API"
    And I press "Create Product"
    Then I should see "Can't be blank"

  Scenario: Create new product: Fail scenario error message
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And service discovery is not enabled
    When I am on the provider dashboard
    And I follow "Create Product"
    And I fill in "Name" with "Less fancy API"
    And I fill in "System name" with "SystemName@123"
    And I press "Create Product"
    Then I should see "invalid"
    And they should see a toast alert with text "System name invalid"

  Scenario: Create new product: with already existing System name
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And service discovery is not enabled
    And a service "Fancy Name" of provider "foo.3scale.localhost"
    When I am on the new service page
    And I fill in "Name" with "Fancy Api"
    And I fill in "System name" with "api"
    And I press "Create Product"
    Then I should see "Has already been taken"
    And they should see a toast alert with text "System name has already been taken"

  @wip
  Scenario: Create new backend
    Given I am logged in as provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And service discovery is not enabled
    When I am on the provider dashboard
    And I follow "Create Backend"
  # And I fill in "Name" with "Less fancy Backend"
  # And I press "Add Backend"
  # Then I should see "Less fancy Backend"

  Scenario: Edit service
    And I am on the edit page for service "Fancy API" of provider "foo.3scale.localhost"
    When I fill in "Name" with "Less fancy API"
    And I press "Update Product"
    And I go to the usage rules of service "Less fancy API"
    And I uncheck "Developers can manage applications"
    And I press "Update product"
    And I go to the overview page of product "Less fancy API"
    And I follow "Product Overview"
    Then I should see "Less fancy API"

  Scenario: Delete Service
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And a service "Second service" of provider "foo.3scale.localhost"
    And I am on the edit page for service "Second service" of provider "foo.3scale.localhost"
    When I follow "I understand the consequences, proceed to delete 'Second service' product"
    And confirm the dialog
    Then I should see "Product 'Second service' will be deleted shortly"
