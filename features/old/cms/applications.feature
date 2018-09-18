Feature: CMS Applications
  As a user I should be able to list my applications

  Background:
    Given a provider "foo.example.com" with default plans
      And provider "foo.example.com" has all the templates setup
      And the current provider is foo.example.com
      And the current domain is foo.example.com
    Given a buyer "supetramp" signed up to application plan "Default"
      And I am logged in as "supetramp"

  Scenario: No pagination
    And I follow "Applications"
      Then I should see "supetramp's app"
      Then I should not see "Previous"
      Then I should not see "Next"

  Scenario: Pagination
    Given buyer "supetramp" has 40 applications
    
    And I follow "Applications"
      Then I should not see "App 9"
      Then I should see "App 35"
      Then I should see "Previous" within ".pagination"
      Then I should see "Next" within ".pagination"

    And I follow "2" within ".pagination"
      Then I should not see "App 35"
      Then I should see "App 9"
      Then I should see "Previous" within ".pagination"
      Then I should see "Next" within ".pagination"

  Scenario: Service name unvisible
    And I follow "Applications"
      Then I should not see "default" within "table#applications"

  Scenario: Service name visible
    And a service "Verduras" of provider "foo.example.com"
    And a published service plan "Tomato" of service "Verduras"
    And provider "foo.example.com" has "multiple_services" visible

    And I follow "Applications"
      Then I should see "default" within "table#applications"
