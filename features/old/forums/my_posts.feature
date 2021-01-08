@saas-only
Feature: My posts
  In order to easily follow a discussion in which I'm participating
  As an user
  I want to see only those topics where I have posted

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "forum" enabled
    And provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "alice" signed up to provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

  Scenario: My posts
    Given the forum of "foo.3scale.localhost" has topics "Security", "Troubleshooting" and "Hacking"
    And the forum of "foo.3scale.localhost" has the following posts:
      | User  | Topic           | Body                                 |
      | alice | Security        | Alice is posting about security      |
      | alice | Hacking         | Alice is posting about hacking       |
      | bob   | Security        | Bob is posting about security        |
      | bob   | Troubleshooting | Bob is posting about troubleshooting |

    When I log in as "alice" on "foo.3scale.localhost"
    And I go to the forum page
    And I follow "My threads"
    Then I should see topic "Security"
    And I should see topic "Hacking"
    But I should not see topic "Troubleshooting"
