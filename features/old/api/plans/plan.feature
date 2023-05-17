Feature: Plans management
  In order to have control over my plans
  As a provider
  I want to be able to manage the plans

  @javascript
  Scenario: Navigating to plans admin page in enterprise mode
    Given a provider "foo.3scale.localhost"
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "service_plans" visible
      And I am logged in as provider "foo.3scale.localhost"

    When I follow "Dashboard"
     And I follow "API"
     And I follow "0 application plans"
    Then I should be on the application plans admin page
    When I go to the service plans admin page
    Then I should be on the service plans admin page
