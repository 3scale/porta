Feature: End User Plan creation
  In order to offer my client different usage conditions for end users
  As a provider
  I want to create different end user plans for them

  Background:
    Given a provider "foo.example.com"
      And an application plan "pro3M" of provider "master"
      And current domain is the admin domain of provider "foo.example.com"
      And provider "foo.example.com" has "end_users" switch allowed
      And I am logged in as provider "foo.example.com"

  Scenario: Navigate to End User Plans
    When I am on the edit page for service "API" of provider "foo.example.com"
     And I follow "End-users"
     And I follow "End-user Plans"
    Then I should be on the end user plans of service "API" page of provider "foo.example.com"

  Scenario: Redirect to upgrade notice when end users switch is denied
    Given provider "foo.example.com" has "end_users" switch denied
    When I am on the edit page for service "API" of provider "foo.example.com"
     And I should not see the link "End-user Plans"

  Scenario: Create new End User Plan
    When I am on the end user plans of service "API" page of provider "foo.example.com"
     And I follow "New"
     And I fill in "Name" with "First end user Plan"
     And I press "Create EndUser plan" and I confirm dialog box
    Then I should see "First end user Plan"
     And I should be on the end user plans of service "API" page of provider "foo.example.com"

  Scenario: In allowed state, but with End User Plans hidden I should not see End User Plans menu
    Given provider "foo.example.com" has "end_users" switch allowed
      And provider has end_user plans hidden from the ui
      And I am on the edit page for service "API" of provider "foo.example.com"
      Then there should not be any mention of end user plans

  @javascript @ajax
  Scenario: Selecting default End User Plan
    Given an end user plan "First" of provider "foo.example.com"
    Given an end user plan "Second" of provider "foo.example.com"
    When I am on the end user plans of service "API" page of provider "foo.example.com"

    When I select "First" as default end user plan
    Then "First" should be default end user plan for service "API"

    When I select "Second" as default end user plan
    Then "Second" should be default end user plan for service "API"
