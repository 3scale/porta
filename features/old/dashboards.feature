Feature: Dashboards
  In order to have some rough idea about my stuff
  As a logged in user
  I want to see overview information in the dashboard

  Background:
    Given a provider "foo.example.com"

  @javascript
  Scenario: Provider dashboard
    Given current domain is the admin domain of provider "foo.example.com"
    And the service of provider "foo.example.com" has traffic
    When I log in as provider "foo.example.com"
    Then I should be on the provider dashboard
    And I should see "Last 30 Days"
    And I should see a sparkline for "hits"

  #FIXME this buyer sees a provider submenu, which is not what happens in the app
  # CHECK THIS OUT!
  Scenario: Buyer dashboard in multiple application mode
    Given provider "foo.example.com" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.example.com"
    When I log in as "bob" on foo.example.com
    And I go to the dashboard
    Then I should be on the dashboard
    # TODO: And I should see stuff

  Scenario: '/admin' on buyer domain sees buyer dashboard
    Given provider "foo.example.com" has multiple applications enabled
    When the current domain is foo.example.com
      And a buyer "bob" signed up to provider "foo.example.com"
      And I log in as "bob" on foo.example.com
      And I request the url "/admin"
    Then I should be on the dashboard

  Scenario: '/admin' on provider domain redirects to '/p/admin'
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I request the url "/admin"
    Then I should be on the provider dashboard

  Scenario: '/p/admin' on provider domain sees provider dashboard
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
    When I request the url "/admin"
    Then I should be on the provider dashboard
