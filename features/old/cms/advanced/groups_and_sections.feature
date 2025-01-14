Feature: Groups and Sections
  As a provider I want to give
  some buyers access to some sections of the site

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "groups" switch allowed
      And provider "foo.3scale.localhost" has "multiple_applications" visible
      And an approved buyer "alice" signed up to provider "foo.3scale.localhost"

      And provider "foo.3scale.localhost" has a public section "Docs" with path "/docs"
      And provider "foo.3scale.localhost" has a published page with the title "First" of section "Docs"

  Scenario: Public sections can be visited without being logged in
    Given the current domain is "foo.3scale.localhost"
    When I request the url "/docs/first"
    Then I should see "First"

  @javascript
  Scenario: Mark a section as Access Restricted
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I am logged in as provider "foo.3scale.localhost" on its admin domain
    When I go to the cms page
      And I follow "Docs"
    When I uncheck "Public"
      And I press "Update"
    Then the section "Docs" of provider "foo.3scale.localhost" should be access restricted

  @allow-rescue
  Scenario: Access restricted sections are access denied for not logged in users
    Given the current domain is "foo.3scale.localhost"
      And the section "Docs" of provider "foo.3scale.localhost" is access restricted
     When I request the url "/docs/first"
     Then I should see "Not found"


  @allow-rescue
  Scenario: Access restricted sections are access denied to not-allowed users
    Given the section "Docs" of provider "foo.3scale.localhost" is access restricted
      And I am logged in as "alice" on foo.3scale.localhost
     When I request the url "/docs/first"
     Then I should see "Not found"

  Scenario: Access restricted sections are access granted to allowed users
    Given the section "Docs" of provider "foo.3scale.localhost" is access restricted
      And the buyer "alice" has access to the section "Docs" of provider "foo.3scale.localhost"
    Given I am logged in as "alice" on foo.3scale.localhost
     When I request the url "/docs/first"
    Then I should see "First"
