@stats
Feature: Buyer stats
  In order to know my API usage
  As an buyer
  I want to see my stats


  Scenario: No access to stats if no app plan subscription
    Given a provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And a buyer "alice" signed up to provider "foo.example.com"
    When I log in as "alice" on foo.example.com
      And I go to the dashboard
    Then I should not see the link "Statistics"

  @selenium @javascript
  Scenario: Access stats page
    Given a provider "foo.example.com"
      And an application plan "Pro" of provider "foo.example.com"
      And a buyer "alice" signed up to application plan "Pro"
      And buyer "alice" made 2 service transactions 12 hours ago:
        | Metric   | Value |
        | hits     |    20 |

    When I log in as "alice" on foo.example.com
      And I go to the dashboard
    Then I should see "Statistics"
    When I follow "Statistics"
    Then there should be a c3 chart with the following data:
      | name          | total  |
      | Hits          | 40   |
