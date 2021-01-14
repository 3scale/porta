Feature: Dashboards
  In order to have some rough idea about my stuff
  As a logged in user
  I want to see overview information in the dashboard

  Background:
    Given a provider "foo.3scale.localhost"

  @javascript
  Scenario: Provider dashboard
    Given current domain is the admin domain of provider "foo.3scale.localhost"
    And the service of provider "foo.3scale.localhost" has traffic
    When I log in as provider "foo.3scale.localhost"
    Then I should be on the provider dashboard
    And I should see "Last 30 Days"
    And I should see a sparkline for "hits"

  #FIXME this buyer sees a provider submenu, which is not what happens in the app
  # CHECK THIS OUT!
  Scenario: Buyer dashboard in multiple application mode
    Given provider "foo.3scale.localhost" has multiple applications enabled
    And a buyer "bob" signed up to provider "foo.3scale.localhost"
    When I log in as "bob" on "foo.3scale.localhost"
    And I go to the dashboard page
    Then I should be on the dashboard
    # TODO: And I should see stuff

  Scenario: '/admin' on buyer domain sees buyer dashboard
    Given provider "foo.3scale.localhost" has multiple applications enabled
    When the current domain is "foo.3scale.localhost"
      And a buyer "bob" signed up to provider "foo.3scale.localhost"
      And I log in as "bob" on "foo.3scale.localhost"
      And I request the url "/admin"
    Then I should be on the dashboard

  Scenario: '/admin' on provider domain redirects to '/p/admin'
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost"
    When I request the url "/admin"
    Then I should be on the provider dashboard

  Scenario: '/p/admin' on provider domain sees provider dashboard
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost"
    When I request the url "/admin"
    Then I should be on the provider dashboard
