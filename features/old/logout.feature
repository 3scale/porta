Feature: Logout feature

  Background:
    Given a provider "foo.3scale.localhost"
    And a buyer "bob" signed up to provider "foo.3scale.localhost"

  # Probably better to rewrite it as a functional test, otherwise
  # you have to deal with iframes in Capybara.
  @wip
  Scenario: Provider go to site and logout as buyer should keep the topbar
    When I log in as "foo.3scale.localhost" on the admin domain of provider "foo.3scale.localhost"
    And I follow "Site"
    And I follow "Sign in"
    And I fill in "Email or Username" with "bob"
    And I fill in "password" with "supersecret"
    And I press "Sign in" within ".commit"
    And I follow "Logout"
    Then I should see "edit" within "#cms-toolbar"
