@javascript
Feature: Provider stats
  In order to know the usage of my service
  As an admin of provider account
  I want to see the stats

  # TODO: Find a way to test the charts

  Background:
    Given a provider is logged in
    And the provider has "multiple_applications" visible
    And all the rolling updates features are off
    And All Dashboard widgets are loaded

  Scenario: Stats access
    And I follow "API"
    And I follow "Analytics"
    And I follow "Traffic"
    Then I should be on the provider stats usage page

  Scenario: Usage stats
    And I follow "API"
    And I follow "Analytics"
    Then I should see "Traffic"

  Scenario: Top applications (multiple applications mode)
    Given a buyer "bob" signed up to provider "foo.3scale.localhost"
    And I follow "API"
    And I follow "Analytics"
    And I go to the provider stats apps page
    Then I should see "Top Applications" in a header
    And I should see a chart called "chart"

  Scenario: Top users (single application mode)
    Given the provider has "multiple_applications" denied
    And the following application plan:
      | Product | Name    | Default |
      | API     | Default | true    |
    And a buyer "bob" signed up to application plan "Default"
    And I follow "API"
    And I follow "Analytics"
    And I follow "Top Applications"
    Then I should see "Top Applications" in a header

  # Regression: https://issues.redhat.com/browse/THREESCALE-8719
  Scenario: Default metric when creating a backend after product
    Given a service "My API" of the provider
    And a backend
    And the backend is used by the product
    When I go to the overview page of product "My API"
    And I follow "Analytics"
    And I follow "Traffic"
    Then I should see "Hits (hits)"

  # Regression: https://issues.redhat.com/browse/THREESCALE-8719
  Scenario: Default metric when creating a backend before product
    Given a backend
    And a service "My API" of the provider
    And the backend is used by the product
    When I go to the overview page of product "My API"
    And I follow "Analytics"
    And I follow "Traffic"
    Then I should see "Hits (hits)"

  @wip
  Scenario: Signups (single application mode)
    Given provider "foo.3scale.localhost" has "multiple_applications" denied
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
    Given provider "foo.3scale.localhost" has "multiple_applications" visible
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
