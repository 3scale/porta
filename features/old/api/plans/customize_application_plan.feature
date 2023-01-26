Feature: Application Plan customization
  In order to fullfill special requirements of my clients
  As a provider
  I want to customize their plan

  Background:
    Given a published plan "Pro" of provider "Master account"
    And plan "Pro" has "custom plans" enabled

    And a provider "foo.3scale.localhost" signed up to plan "Pro"
    And provider "foo.3scale.localhost" is charging its buyers

    And an application plan "Basic" of provider "foo.3scale.localhost"
    And plan "Basic" has monthly fee of 1000

    And a buyer "bob" signed up to application plan "Basic"

  @ignore-backend @javascript
  Scenario: Customize the same plan twice (to check duplicate handling)
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    When I am logged in as provider "foo.3scale.localhost"

    And I go to the provider side application page for "bob"
    Then I should see "Application Plan: Basic"
    When I follow "Convert to a Custom Plan"
    Then I should see "Custom Application Plan"

   When a buyer "tom" signed up to application plan "Basic"
    And I go to the provider side application page for "tom"
    Then I should see "Application Plan: Basic"
    When I follow "Convert to a Custom Plan"
    # Customizing the same plan again would cause name conflict -> dialog appears
    #And I fill in "Name" with "unique customized name"
    #And I fill in "System name" with "unique_customized_name"
    #And I press "Create #Application plan"
   Then I should see "Custom Application Plan"

  @ignore-backend
  Scenario: Decustomize
    Given buyer "bob" has customized plan
    When I am logged in as provider "foo.3scale.localhost" on its admin domain
    And I go to the provider side application page for "bob"
    Then I should see "Custom Application Plan"
    When I press "Remove customization"
    Then I should see "Application Plan: Basic"

  @ignore-backend
  Scenario: Can edit custom plans
    # this switch is not needed for the core functionality but apps
    # list wouldn't be available if not set
    Given provider "foo.3scale.localhost" has "multiple_applications" switch allowed
      When buyer "bob" has customized plan
       And I am logged in as provider "foo.3scale.localhost" on its admin domain
       And I go to the applications admin page
       And I follow "Basic (custom)"
     Then I should see "Application Plan Basic (custom)"
