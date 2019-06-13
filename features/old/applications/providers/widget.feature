@fakeweb
Feature: Applications widget
  In order to see quick overview of my buyer's application
  As a provider
  I want to see it in a widget on the buyer account detail page

  Background:
    Given a provider "foo.example.com"
    And a default application plan "Basic" of provider "foo.example.com"

  Scenario: Backend v1
    Given provider "foo.example.com" uses backend v1 in his default service
    And a buyer "bob" signed up to application plan "Basic"
    And buyer "bob" has user key "userkey1234"
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I navigate to the accounts page
    And I follow "bob"
    Then I should see "Application" in a header in the applications widget
    And I should see the following table in the applications widget:
       | Name        | bob's App   |
       | Service     | API         |
       | Plan        | Basic       |
       | State       | Live        |
    And I should see link "bob's App" in the applications widget
    And I should not see "Create new key"

  Scenario: Backend v2, one application allowed
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications disabled
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has application "SuperWidget" with ID "id1234"
    And the application of buyer "bob" has the following keys:
      | key2345 |
      | key2346 |
      | key2347 |

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I navigate to the accounts page
    And I follow "bob"
    Then I should see "1 Application"

    Then I should see "Application" in a header in the applications widget
    And I should see the following table in the applications widget:
       | Name        | SuperWidget |
       | Service     | API         |
       | Plan        | Basic       |
       | State       | Live        |
    And I should see link "SuperWidget" in the applications widget

    When I follow "SuperWidget"
    Then I should see "API Credentials"
    And I should see "key2345"
    And I should see "key2346"
    And I should see "key2347"

  Scenario: Backend v2, multiple applications allowed but none created
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has no applications

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I navigate to the accounts page
    And I follow "bob"
    Then I should see "0 Applications"

  Scenario: Backend v2, multiple applications allowed, one created
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has application "SuperWidget" with ID "id1234"
    And application "SuperWidget" has the following keys:
      | key1234 |
      | key1235 |
      | key1236 |

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I navigate to the accounts page
    And I follow "bob"
    Then I should see "1 Application"

    Then I should see "Application" in a header in the applications widget
    And I should see the following table in the applications widget:
       | Name        | SuperWidget |
       | Service     | API         |
       | Plan        | Basic       |
       | State       | Live        |
    And I should see link "SuperWidget" in the applications widget

    When I follow "SuperWidget"
    Then I should see "API Credentials"
    And I should see "key1234"
    And I should see "key1235"
    And I should see "key1236"

  Scenario: Backend v2, multiple applications allowed and multiple created
    Given provider "foo.example.com" uses backend v2 in his default service
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"
    And buyer "bob" has application "AppOne"
    And buyer "bob" has application "AppTwo"
    And I don't care about application keys

    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"

    And I navigate to the accounts page
    And I follow "bob"

    Then I should see "2 Applications"
    Then I should not see the ID of application "AppOne"
    And I should not see any key of application "AppOne"
    And I should not see link "AppOne"
    And I should not see link "AppTwo"

    When I follow "2 Applications"
    Then I should see link "AppOne"
    Then I should see link "AppTwo"
