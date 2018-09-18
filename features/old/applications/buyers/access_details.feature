@fakeweb
Feature: Buyer's API Access Details
  In order to use a service provided by a 3scale client
  As a buyer
  I want to see my API access details

  Background:
    Given a provider "foo.example.com"
    And a default application plan "Pro" of provider "foo.example.com"

  Scenario: Backend v1
    Given provider "foo.example.com" uses backend v1 in his default service
    And provider "foo.example.com" has multiple applications disabled
    And a buyer "alice" signed up to application plan "Pro"
    When I log in as "alice" on foo.example.com
    And I go to the dashboard
    And I follow "API Credentials"
    Then I should see the user key of buyer "alice"
    And I should not see button to "Create new key"

  Scenario: Backend v1, multiple application mode
    Given provider "foo.example.com" uses backend v1 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a service plan "Gold Star L" of provider "foo.example.com"
    And a buyer "alice" signed up to service plan "Gold Star L"
    And buyer "alice" has application "CuteWidget"
    When I log in as "alice" on foo.example.com
    And I go to the dashboard
    Then I should not see link "API Credentials"
    When I follow "Applications"
    And I follow "CuteWidget" for application "CuteWidget"
    Then I should see the user key of buyer "alice"

  Scenario: Backend v2, single application mode
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications disabled
    And a buyer "alice" signed up to application plan "Pro"
    And the application of buyer "alice" has 3 keys

    When I log in as "alice" on foo.example.com
    And I go to the dashboard
    And I follow "API Credentials"
    Then I should see the ID of the application of buyer "alice"
    And I should see all keys of the application of buyer "alice"
    And I should see button to "Create new key"

  Scenario: Backend v2, multiple applications mode
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a service plan "Goldeanu" of provider "foo.example.com"
    And a buyer "alice" signed up to service plan "Goldeanu"
    # And a buyer "alice" signed up to provider "foo.example.com"
    And buyer "alice" has application "CuteWidget"
    And application "CuteWidget" has 2 keys

    When I log in as "alice" on foo.example.com
    And I go to the dashboard
    Then I should not see link "API Access Details"
    When I follow "Applications"
    And I follow "CuteWidget" for application "CuteWidget"
    Then I should see the ID of application "CuteWidget"
    And I should see all keys of application "CuteWidget"
    And I should see button to "Create new key"

  @backend
  Scenario: Backend oauth, multiple applications mode
    Given provider "foo.example.com" uses backend oauth in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a service plan "Gold" of provider "foo.example.com"
    And a buyer "alice" signed up to service plan "Gold"

    When I log in as "alice" on foo.example.com
    And I go to the dashboard
    And the backend will create key "key-one" for an application
    Then I should not see link "API Access Details"
    When I follow "Applications"
    And I follow "Create new application"
    And I fill in "Name" with "UltimateWidget"
    And I fill in "Description" with "Awesome ultimate super widget"
    And I press "Create"
    Then I should see "Application was successfully created"
    And I should be on the "UltimateWidget" application page
    And I should see "Name UltimateWidget"
    And I should see the ID of application "UltimateWidget"

  @wip
  Scenario: Backend v1 and paid plan with postpaid billing
    Given the year is 2010
    And provider "foo.example.com" uses backend v1 in his default service
    And provider "foo.example.com" has billing enabled
    And plan "Pro" has monthly fee of 200
    And a buyer "alice" signed up to application plan "Pro"
    When the current domain is foo.example.com
    When I log in as "alice"
    And I follow "API Access Details"
    Then I should see "Payment details required"
    And I should not see "Not enough credit"
    When I follow "credit card details"
    When I follow "Add Details"
    And I fill in "First name" with "Alice"
    And I fill in "Last name" with "From wonderland"
    And I fill in "Card number" with "1"
    And I fill in "Card verification value" with "999"
    And I select "2015" from "account_credit_card_year"
    And I select "1 - January" from "account_credit_card_month"
    And I fill in "Address" with "C/Llacuna 162"
    And I fill in "City" with "Barcelona"
    And I press "Save"
    And I follow "Dashboard"
    And I follow "API Access Details"
    Then I should not see "Payment details required"
    And I should not see "Not enough credit"

  @wip
  Scenario: Backend v1 and paid plan with prepaid billing
    Given provider "foo.example.com" uses backend v1 in his default service
    And provider "foo.example.com" has prepaid billing enabled
    And plan "Pro" has monthly fee of 200
    And a buyer "alice" signed up to application plan "Pro"
    When the current domain is foo.example.com
    When I log in as "alice"
    And I follow "API Access Details"
    Then I should see "Not enough credit"
    And I should not see "Payment details required"
    # TODO: upload credit, then check that the warning dissapears

  @wip
  Scenario: Provider verification key disabled
    Given provider "foo.example.com" uses backend v1 in his default service
    And a buyer "alice" signed up to application plan "Pro"

    When I log in as "alice" on foo.example.com
    And I follow "API Access Details"
    Then I should not see "Provider Verification Key"
