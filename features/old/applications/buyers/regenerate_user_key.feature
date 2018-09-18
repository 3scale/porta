Feature: Refresh User Key
  In order to keep my API secure
  As a buyer MacGyver
  I might need to regenerate my user key from time to time

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" uses backend v1 in his default service
    And provider "foo.example.com" has multiple applications disabled
    And an application plan "Default" of provider "foo.example.com"
    Given a buyer "fred" signed up to application plan "Default"

  Scenario: Regenerate user key
    Given the service of provider "foo.example.com" has "buyer key regenerate" enabled
    When I log in as "fred" on foo.example.com
    And I go to the API access details page
    And I remember the user key I see
    And I press "Regenerate"
    Then I should see "The user key was regenerated"
    And I should see user key is different from what it was

  Scenario: Buyer Key Refresh disabled
    Given the service of provider "foo.example.com" has "buyer key regenerate" disabled
    When I log in as "fred" on foo.example.com
    And I go to the API access details page
    Then I should not see button "Regenerate"

  Scenario: Buyer Key Refresh enabled
    Given the service of provider "foo.example.com" has "buyer key regenerate" enabled
    When I log in as "fred" on foo.example.com
    And I go to the API access details page
    Then I should see button "Regenerate"
