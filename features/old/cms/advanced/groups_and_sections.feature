Feature: Groups and Sections
  As a provider I want to give
  some buyers access to some sections of the site

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has "groups" switch allowed
      And provider "foo.example.com" has multiple applications enabled
      And an approved buyer "alice" signed up to provider "foo.example.com"

      And provider "foo.example.com" has a public section "Docs" with path "/docs"
      And provider "foo.example.com" has a published page with the title "First" of section "Docs"

  Scenario: Public sections can be visited without being logged in
    Given the current domain is "foo.example.com"
    When I request the url "/docs/first"
    Then I should see "First"

  @javascript
  Scenario: Mark a section as Access Restricted
    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com" on its admin domain
    When I go to the cms page
      And I follow "Docs"
    When I uncheck "Public"
      And I press "Update"
    Then the section "Docs" of provider "foo.example.com" should be access restricted

  @allow-rescue
  Scenario: Access restricted sections are access denied for not logged in users
    Given the current domain is "foo.example.com"
      And the section "Docs" of provider "foo.example.com" is access restricted
     When I request the url "/docs/first"
     Then I should see "Not found"


  @allow-rescue
  Scenario: Access restricted sections are access denied to not-allowed users
    Given the section "Docs" of provider "foo.example.com" is access restricted
      And I am logged in as "alice" on "foo.example.com"
     When I request the url "/docs/first"
     Then I should see "Not found"

  Scenario: Access restricted sections are access granted to allowed users
    Given the section "Docs" of provider "foo.example.com" is access restricted
      And the buyer "alice" has access to the section "Docs" of provider "foo.example.com"
    Given I am logged in as "alice" on "foo.example.com"
     When I request the url "/docs/first"
    Then I should see "First"
