Feature: Plans management
  In order to have control over my plans
  As a provider
  I want to be able to manage the plans

  Scenario: Navigating to plans admin page in enterprise mode
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And provider "foo.example.com" has "service_plans" visible
      And I am logged in as provider "foo.example.com"

    When go to the dashboard page
      And I follow "Overview"
      And I follow "0 application plans"
    Then I should be on the application plans admin page
    When I follow "Service Plans"
    Then I should be on the service plans admin page
