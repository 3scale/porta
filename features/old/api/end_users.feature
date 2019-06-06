@backend @javascript
Feature: End User management
  In order to manage end users
  As a provider
  I want to have interface to search, delete and change plan

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "end_users" switch allowed
      And an end user plan "First" of provider "foo.example.com"
    Given current domain is the admin domain of provider "foo.example.com"

  Scenario: Deny access when end users switch is denied
    Given provider "foo.example.com" has "end_users" switch denied
      And I am logged in as provider "foo.example.com"
     When I want to go to the end users of service "API" page of provider "foo.example.com"
     Then I should get access denied

  Scenario: Create new end user
    Given I am logged in as provider "foo.example.com"
    When I am on the end users of service "API" page of provider "foo.example.com"
     And I follow "New"
     And I fill in "Username" with "uuid-of-the-end-user"
     And I press "Create End User"
    Then I should see "uuid-of-the-end-user"
     And I should be on the end user "uuid-of-the-end-user" of service "API" page of provider "foo.example.com"

  Scenario: Search for End User
   Given provider "foo.example.com" has end user "uuid-of-the-end-user" on service "API"
     And I am logged in as provider "foo.example.com"
    When I am on the end users of service "API" page of provider "foo.example.com"
     And I fill in "End User Name" with "uuid-of-the-end-user"
     And I press "Search"
    Then I should see "uuid-of-the-end-user"
     And I should see "change plan"
     And I should see "Delete"
     And I should be on the end user "uuid-of-the-end-user" of service "API" page of provider "foo.example.com"

  @javascript
  Scenario: Delete End User
    Given provider "foo.example.com" has end user "uuid-of-the-end-user" on service "API"
      And I am logged in as provider "foo.example.com"
    When I am on the end user "uuid-of-the-end-user" of service "API" page of provider "foo.example.com"
     And I follow "Delete" and I confirm dialog box
    Then I should see "End user deleted successfully"
     And I should be on the end users of service "API" page of provider "foo.example.com"

  Scenario: Change plan of End User
    Given provider "foo.example.com" has end user "uuid-of-the-end-user" on service "API"
      And an end user plan "Second" of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I am on the end user "uuid-of-the-end-user" of service "API" page of provider "foo.example.com"
     And I follow "change plan"
     And I select "Second" from "Plan"
     And I press "Change plan"
    Then I should see "Plan changed successfully"
     And I should be on the end user "uuid-of-the-end-user" of service "API" page of provider "foo.example.com"
