@javascript
Feature: Provider stats
  In order to know the usage of my service
  As an admin of provider account
  I want to see the stats

  # TODO: Find a way to test the charts

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has multiple applications enabled
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And all the rolling updates features are off
    And All Dashboard widgets are loaded

  @javascript
  Scenario: Stats access
    When I log in as provider "foo.3scale.localhost"
    And I follow "API"
    And I follow "Analytics"
    And I follow "Traffic"
    Then I should be on the provider stats usage page

  Scenario: Usage stats
    When I log in as provider "foo.3scale.localhost"
    And I follow "API"
    And I follow "Analytics"
    Then I should see "Traffic"

  Scenario: Top applications (multiple applications mode)
    Given a buyer "bob" signed up to provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I follow "API"
    And I follow "Analytics"
    And I go to the provider stats apps page
    Then I should see "Top Applications" in a header
    And I should see a chart called "chart"

  Scenario: Top users (single application mode)
    Given provider "foo.3scale.localhost" has multiple applications disabled
    And an application plan "Default" of provider "foo.3scale.localhost"
    And a buyer "bob" signed up to application plan "Default"

    When I log in as provider "foo.3scale.localhost"
    And I follow "API"
    And I follow "Analytics"
    And I follow "Top Applications"
    Then I should see "Top Applications" in a header

  Scenario: Default metric is product metric
    Given provider "foo.3scale.localhost" has multiple applications disabled
    When I log in as provider "foo.3scale.localhost"
    Given a product
    And a backend
    And the backend is used by this product
    When I go to the overview page of product "API"
      And I follow "Analytics"
      And I follow "Traffic"
    Then I should see "hits"

  @wip
  Scenario: Signups (single application mode)
    Given provider "foo.3scale.localhost" has multiple applications disabled
    And an application plan "Basic" of provider "foo.3scale.localhost"
    Given these buyers signed up to plan "Basic"
      | Name     | Signed on      |
      | alice    | May 22th 2009  |
      | bob      | May 27th 2009  |
      | carl     | June 5th 2009  |
      | danielle | June 7th 2009  |
      | eric     | June 11th 2009 |
      | fiona    | June 18th 2009 |
    When I log in as provider "foo.3scale.localhost"
    And I follow "API"
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
    Given provider "foo.3scale.localhost" has multiple applications enabled
    And a default application plan of provider "foo.3scale.localhost"
    And a buyer "alice" signed up to provider "foo.3scale.localhost"
    And buyer "alice" has the following applications:
      | Name            | Created at    |
      | AwesomeWidget   | Oct 1st 2010  |
      | BestWidget      | Oct 2nd 2010  |
      | CoolWidget      | Oct 5th 2010  |
      | DemonicWidget   | Oct 7th 2010  |
      | ExplosiveWidget | Oct 11th 2010 |
      | FancyWidget     | Oct 18th 2010 |
    When I log in as provider "foo.3scale.localhost"
    And I follow "API"
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
    When I log in as "lol.3scale.localhost"
    And I go to the provider days stats page
    Then I should see "Stats: Days of week"
    # # This should really be "I click on ...", but the link is inside flash and
    # # webrat can't handle that as far as i know...
    # When I am on the provider day stats page for day "monday" and metric "hits"
    # Then I should see "Stats: Monday"
