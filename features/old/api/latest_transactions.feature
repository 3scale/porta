@fakeweb
Feature: Latest transactions
  In order to see my API traffic flowing
  As a provider
  I want to see live transaction feed

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" uses backend v2 in his default service
    And an application plan "Basic" of provider "foo.example.com"
    And a metric "foos" with friendly name "Number of Foos" of provider "foo.example.com"
    And a metric "bars" with friendly name "Number of Bars" of provider "foo.example.com"
    And a buyer "alice" signed up to application plan "Basic"
    And a buyer "bob" signed up to application plan "Basic"

    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

  Scenario: Latest transactions
    Given provider "foo.example.com" has the following latest transactions:
      | Buyer | Timestamp           | Usage            |
      | alice | 2010-09-13 12:25:00 | foos: 1, bars: 2 |
      | bob   | 2010-09-13 12:24:00 | foos: 1, bars: 7 |
    When I go to the latest transactions page
    Then I should see the following transactions:
      | Buyer | Timestamp             | Usage                                |
      | alice | 13. Sep 2010 12:25:00 | Number of Foos: 1, Number of Bars: 2 |
      | bob   | 13. Sep 2010 12:24:00 | Number of Foos: 1, Number of Bars: 7 |

  Scenario: Latest transactions in 2 services
    Given a service "Awesome" of provider "foo.example.com"
    Given provider "foo.example.com" has the following latest transactions in service "API":
      | Buyer | Timestamp           | Usage            |
      | bob   | 2011-09-13 12:25:00 | foos: 1, bars: 2 |
    Given provider "foo.example.com" has the following latest transactions in service "Awesome":
      | Buyer | Timestamp           | Usage            |
      | alice | 2010-09-13 12:25:00 | hits: 2 |
    When I go to the latest transactions page
    Then I should see the following transactions:
      | Buyer | Timestamp             | Usage                                |
      | alice | 13. Sep 2010 12:25:00 | Number of Hits: 2                    |
      | bob   | 13. Sep 2011 12:24:00 | Number of Foos: 1, Number of Bars: 2 |

  Scenario: Invalid application id
    Given provider "foo.example.com" has the following latest transactions:
      | Buyer   | Timestamp           | Usage   |
      | INVALID | 2010-09-13 15:59:00 | foos: 1 |
    When I go to the latest transactions page
    Then I should see the following transactions:
      | Buyer   | Timestamp             | Usage             |
      | missing | 13. Sep 2010 15:59:00 | Number of Foos: 1 |

  Scenario: Invalid metric id
    Given provider "foo.example.com" has the following latest transactions:
      | Buyer   | Timestamp           | Usage      |
      | alice   | 2010-09-13 15:59:00 | INVALID: 1 |
    When I go to the latest transactions page
    Then I should see the following transactions:
      | Buyer   | Timestamp             | Usage      |
      | alice   | 13. Sep 2010 15:59:00 | missing: 1 |

  Scenario: Transaction with no usage
    Given provider "foo.example.com" has the following latest transactions:
      | Buyer | Timestamp          | Usage |
      | alice | 2010-11-8 16:49:00 |       |
    When I go to the latest transactions page
    Then I should see the following transactions:
      | Buyer | Timestamp            | Usage   |
      | alice | 8. Nov 2010 16:49:00 | missing |

  Scenario: Latest transactions are only available on the v2 backend
    Given provider "foo.example.com" uses backend v1 in his default service
    When I go to the provider dashboard
    And I follow "Overview"
    Then I should not see link "Traffic"

  # TODO: Multiple invalid metric ids
  # TODO: Backend down
  # TODO: Timezone aware timestamps
