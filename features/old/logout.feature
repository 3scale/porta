Feature: Logout feature

  Background:
    Given a provider "foo.example.com"
    And a buyer "bob" signed up to provider "foo.example.com"

  # Probably better to rewrite it as a functional test, otherwise
  # you have to deal with iframes in Capybara.
  @wip
  Scenario: Provider go to site and logout as buyer should keep the topbar
    When I log in as "foo.example.com" on the admin domain of provider "foo.example.com"
    And I follow "Site"
    And I follow "Sign in"
    And I fill in "Username or Email" with "bob"
    And I fill in "password" with "supersecret"
    And I press "Sign in" within ".commit"
    And I follow "Logout"
    Then I should see "edit" within "#cms-toolbar"
