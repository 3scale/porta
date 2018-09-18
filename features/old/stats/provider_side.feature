Feature: Provider stats
  In order to know the usage of my service
  As an admin of provider account
  I want to see the stats

  # TODO: Find a way to test the charts

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And current domain is the admin domain of provider "foo.example.com"
    And all the rolling updates features are off

  Scenario: Stats access
    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    Then I should be on the provider stats usage page

  Scenario: Stats access for multiservices
    Given a service "Another one" of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    Then I should be on the provider stats overview

  Scenario: Usage stats
    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    Then I should see "Usage"

  @javascript @selenium
  Scenario: Top applications (multiple applications mode)
    Given a buyer "bob" signed up to provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    And I follow "Top Applications"
    Then I should see "Top Applications" in a header
    And I should see a chart called "chart"

  Scenario: Top users (single application mode)
    Given provider "foo.example.com" has multiple applications disabled
    And an application plan "Default" of provider "foo.example.com"
    And a buyer "bob" signed up to application plan "Default"

    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    And I follow "Top Applications"
    Then I should see "Top Applications" in a header



  @wip
  Scenario: Signups (single application mode)
    Given provider "foo.example.com" has multiple applications disabled
    And an application plan "Basic" of provider "foo.example.com"
    Given these buyers signed up to plan "Basic"
      | Name     | Signed on      |
      | alice    | May 22th 2009  |
      | bob      | May 27th 2009  |
      | carl     | June 5th 2009  |
      | danielle | June 7th 2009  |
      | eric     | June 11th 2009 |
      | fiona    | June 18th 2009 |
    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    And I follow "Signups"
    Then I should see these buyers in the latest signups table:
      | fiona    |
      | eric     |
      | danielle |
      | carl     |
      | bob      |
    But I should not see "alice"

  @wip
  Scenario: Signups (multiple application mode)
    Given provider "foo.example.com" has multiple applications enabled
    And a default application plan of provider "foo.example.com"
    And a buyer "alice" signed up to provider "foo.example.com"
    And buyer "alice" has the following applications:
      | Name            | Created at    |
      | AwesomeWidget   | Oct 1st 2010  |
      | BestWidget      | Oct 2nd 2010  |
      | CoolWidget      | Oct 5th 2010  |
      | DemonicWidget   | Oct 7th 2010  |
      | ExplosiveWidget | Oct 11th 2010 |
      | FancyWidget     | Oct 18th 2010 |
    When I log in as provider "foo.example.com"
    And I follow "Analytics"
    And I follow "Signups"
    Then I should see these applications in the latest signups table:
      | FancyWidget     |
      | ExplosiveWidget |
      | DemonicWidget   |
      | CoolWidget      |
      | BestWidget      |
    But I should not see "AwesomeWidget"

  @wip
  Scenario: Days
    Given a buyer "kitty_one" signed up to application plan "Basic"
    When I log in as "lol.example.com"
    And I go to the provider days stats page
    Then I should see "Stats: Days of week"
    # # This should really be "I click on ...", but the link is inside flash and
    # # webrat can't handle that as far as i know...
    # When I am on the provider day stats page for day "monday" and metric "hits"
    # Then I should see "Stats: Monday"
