@saas-only
Feature: My posts
  In order to easily follow a discussion in which I'm participating
  As an user
  I want to see only those topics where I have posted

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has "forum" enabled
    And provider "foo.example.com" has multiple applications enabled
    And a buyer "alice" signed up to provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"

  Scenario: My posts
    Given the forum of "foo.example.com" has topics "Security", "Troubleshooting" and "Hacking"
    And the forum of "foo.example.com" has the following posts:
      | User  | Topic           | Body                                 |
      | alice | Security        | Alice is posting about security      |
      | alice | Hacking         | Alice is posting about hacking       |
      | bob   | Security        | Bob is posting about security        |
      | bob   | Troubleshooting | Bob is posting about troubleshooting |

    When I log in as "alice" on foo.example.com
    And I go to the forum page
    And I follow "My threads"
    Then I should see topic "Security"
    And I should see topic "Hacking"
    But I should not see topic "Troubleshooting"
