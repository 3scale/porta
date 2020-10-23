Feature: Top applications stats
  In order to know the usage of my service
  As an admin of provider account
  I want to see which applications are most popular

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" uses backend v1 in his default service
    And provider "foo.3scale.localhost" has multiple applications enabled

    And an application plan "Default" of provider "foo.3scale.localhost"
    And a metric "foos" with friendly name "Number of Foos" of provider "foo.3scale.localhost"
    And a metric "bars" with friendly name "Number of Bars" of provider "foo.3scale.localhost"
    And a buyer "alice" signed up to provider "foo.3scale.localhost"
    And buyer "alice" has application "alice widget"

    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    And buyer "bob" has application "bob widget"

    And all the rolling updates features are off

  @javascript
  Scenario: With transactions
    And buyer "alice" makes 2 service transactions with:
      | Metric   | Value |
      | hits     |    20 |
      | foos     |    10 |
      | bars     |     5 |

    And buyer "bob" makes 1 service transactions with:
      | Metric   | Value |
      | hits     |    20 |
      | foos     |    10 |
      | bars     |     5 |

    When current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And I go to the provider stats apps page

    Then I should see a list of metrics:
    | Buyer                |
    | Hits                 |
    | Number of Foos       |
    | Number of Bars       |

    When I select today from the stats menu

    Then there should be a c3 chart with the following data:
    | name                  | total|
    | alice widget by alice | 40   |
    | bob widget by bob     | 20   |
