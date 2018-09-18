@javascript @ajax
Feature: Usage limits
  In order to prevent my users to send uncontrolable amount of traffic to my API
  As a provider
  I want to define usage limits

  Background:
    Given a provider "foo.example.com"
      And an application plan "Basic" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
    Given I log in as provider "foo.example.com"

  Scenario: Create a limit
    When I go to the edit page for plan "Basic"
     And I follow "Limits" for metric "hits" on application plan "Basic"
     And I follow "New usage limit"
     And I select "hour" from "Period"
     And I fill in "Max. value" with "1000"
     And I press "Create usage limit"
    Then I should see a usage limit of 1000 for metric "hits" on application plan "Basic" per "1 hour"
    Then plan "Basic" should have a usage limit of 1000 for metric "hits" per "hour"

  Scenario: 0 is a valid value
    When I go to the edit page for plan "Basic"
    And I follow "Limits" for metric "hits" on application plan "Basic"
    And I follow "New usage limit"
    And I select "hour" from "Period"
    And I select "hour" from "Period"
    And I fill in "Max. value" with "0"
    And I press "Create usage limit"
    Then I should see a usage limit of 0 for metric "hits" on application plan "Basic" per "1 hour"
    And plan "Basic" should have a usage limit of 0 for metric "hits" per "hour"
    And I should see the edit limit link

  Scenario: Edit max value limit
    Given an usage limit on plan "Basic" for metric "hits" with period hour and value 2000
    When I go to the edit page for plan "Basic"
     And I follow "Limits" for metric "hits" on application plan "Basic"
     And I follow "Edit" for the hourly usage limit for metric "hits" on application plan "Basic"
     And I fill in "Max. value" with "3000"
     And I press "Update usage limit"
    Then I should see a usage limit of 3000 for metric "hits" on application plan "Basic" per "1 hour"
     And plan "Basic" should have a usage limit of 3000 for metric "hits" per "hour"

  Scenario: Edit Period of limit
    Given an usage limit on plan "Basic" for metric "hits" with period hour and value 2000
    When I go to the edit page for plan "Basic"
     And I follow "Limits" for metric "hits" on application plan "Basic"
     And I follow "Edit" for the hourly usage limit for metric "hits" on application plan "Basic"
     And I select "day" from "Period"
     And I press "Update usage limit"
    Then I should see a usage limit of 2000 for metric "hits" on application plan "Basic" per "1 day"
     And plan "Basic" should have a usage limit of 2000 for metric "hits" per "day"

  Scenario: Delete a limit
    Given an usage limit on plan "Basic" for metric "hits" with period hour and value 1500
    When I go to the edit page for plan "Basic"
     And I follow "Limits" for metric "hits" on application plan "Basic"
     And I press "Delete" for the hourly usage limit for metric "hits" on application plan "Basic"
    Then I should not see hourly usage limit for metric "hits"
     And plan "Basic" should not have hourly usage limit for metric "hits"

  Scenario: Limits panel
    Given an usage limit on plan "Basic" for metric "hits" with period hour and value 800
     And I go to the edit page for plan "Basic"
    Then I should not see hourly usage limit for metric "hits"
    When I follow "Limits"
    Then I should see hourly usage limit for metric "hits" on application plan "Basic"
    When I follow "Close" within usage limits panel for metric "hits" on application plan "Basic"
    Then I should not see hourly usage limit for metric "hits" on application plan "Basic"

  Scenario: Create a limit for end user plan
   Given provider "foo.example.com" has "end_users" switch allowed
     And a metric "my-metric" of provider "foo.example.com"
     And an end user plan "Basic" of provider "foo.example.com"
    When I am on the edit page for end user plan "Basic"
     And I follow "Limits" for metric "my-metric"
     And I follow "New usage limit"
     And I select "hour" from "Period"
     And I fill in "Max. value" with "1000"
     And I press "Create usage limit"
    Then I should see hourly usage limit of 1000 for metric "my-metric"
     And end user plan "Basic" should have a usage limit of 1000 for metric "my-metric" per "hour"

  Scenario: Edit a limit for end user plan
   Given provider "foo.example.com" has "end_users" switch allowed
     And a metric "my-metric" of provider "foo.example.com"
     And an end user plan "Basic" of provider "foo.example.com"
     And an usage limit on end user plan "Basic" for metric "my-metric" with period hour and value 2000
    When I am on the edit page for end user plan "Basic"
     And I follow "Limits" for metric "my-metric" on application plan "Basic"
     And I follow "Edit" for the hourly usage limit for metric "my-metric"
     And I fill in "Max. value" with "3000"
     And I press "Update usage limit"
    Then I should see hourly usage limit of 3000 for metric "my-metric"
     And end user plan "Basic" should have a usage limit of 3000 for metric "my-metric" per "hour"

  Scenario: Delete a limit for end user plan
   Given provider "foo.example.com" has "end_users" switch allowed
     And a metric "my-metric" of provider "foo.example.com"
     And an end user plan "Basic" of provider "foo.example.com"
     And an usage limit on end user plan "Basic" for metric "my-metric" with period hour and value 1500
    When I am on the edit page for end user plan "Basic"
     And I follow "Limits" for metric "my-metric" on application plan "Basic"
     And I press "Delete" for the hourly usage limit for metric "my-metric"
    Then I should not see hourly usage limit for metric "my-metric"
     And end user plan "Basic" should not have hourly usage limit for metric "my-metric"
