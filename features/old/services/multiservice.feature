Feature: Multiservice feature
  In order to provide various APIs
  As a provider
  I want to have multiple services

  Background:
    Given a provider "foo.3scale.localhost"
    And a default service of provider "foo.3scale.localhost" has name "Fancy API"
    And a service "Second service" of provider "foo.3scale.localhost"
    And current domain is the admin domain of provider "foo.3scale.localhost"

  @javascript
  Scenario: Can create new service setting
    Given I am logged in as provider "foo.3scale.localhost"
     And provider "foo.3scale.localhost" has "can create service" set to "true"
    When I am on the provider dashboard
    Then I should see "Create Product"
    Then I should see "Create Backend"

  @javascript
  Scenario: Create new product
    Given I am logged in as provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_services" switch allowed
      And service discovery is not enabled
    When I am on the provider dashboard
     And I follow "Create Product"
     And I fill in "Name" with "Less fancy API"
     And I press "Create Product"
    Then I should see "Less fancy API"

  @javascript
  Scenario: Create new product: Fail scenario error message
    Given I am logged in as provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_services" switch allowed
      And service discovery is not enabled
    When I am on the provider dashboard
      And I follow "Create Product"
      And I fill in "Name" with "Invalid API"
      And I fill in "System name" with "I am using spaces"
      And I press "Create Product"
    Then I should see the flash message "Product could not be created"

    @javascript
    Scenario: Create new product: with blank product name
      Given I am logged in as provider "foo.3scale.localhost"
        And provider "foo.3scale.localhost" has "multiple_services" switch allowed
        And service discovery is not enabled
      When I am on the provider dashboard
        And I follow "Create Product"
        And I fill in "System name" with "Less fancy API"
        And I press "Create Product"
      Then I should see "Can't be blank"

    @javascript
    Scenario: Create new product: Fail scenario error message
      Given I am logged in as provider "foo.3scale.localhost"
        And provider "foo.3scale.localhost" has "multiple_services" switch allowed
        And service discovery is not enabled
      When I am on the provider dashboard
        And I follow "Create Product"
        And I fill in "Name" with "Less fancy API"
        And I fill in "System name" with "SystemName@123"
        And I press "Create Product"
      Then I should see "Only ASCII letters, numbers, dashes and underscores are allowed."

    @javascript
    Scenario: Create new product: with already existed product name
      Given I am logged in as provider "foo.3scale.localhost"
        And a service for provider "foo.3scale.localhost" with system_name "Fancy API"
      When I am on the provider dashboard
        And I follow "Create Product"
        And I fill in "Name" with "Product Name"
        And I fill in "System name" with "Fancy API"
        And I press "Create Product"
      Then I should see "Has already been taken"

  @wip
  Scenario: Create new backend
    Given I am logged in as provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "multiple_services" switch allowed
      And service discovery is not enabled
    When I am on the provider dashboard
     And I follow "Create Backend"
    #  And I fill in "Name" with "Less fancy Backend"
    #  And I press "Add Backend"
    # Then I should see "Less fancy Backend"

  @javascript
  Scenario: Edit service
    Given I am logged in as provider "foo.3scale.localhost"
      And I am on the edit page for service "Fancy API" of provider "foo.3scale.localhost"
    When I fill in "Name" with "Less fancy API"
     And I press "Update Product"
     And I follow "Applications" within the main menu
     And I follow "Usage Rules"
     And I uncheck "Developers can manage applications"
     And I press "Update Product"
     And I follow "Overview"
    Then I should see "Less fancy API"

  Scenario: Delete Service
    Given I am logged in as provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And I am on the edit page for service "Second service" of provider "foo.3scale.localhost"
    When I follow "I understand the consequences, proceed to delete 'Second service' product" and I confirm dialog box
    Then I should see "Product 'Second service' will be deleted shortly."
