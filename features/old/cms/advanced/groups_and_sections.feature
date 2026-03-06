Feature: Groups and Sections
  As a provider I want to give
  some buyers access to some sections of the site

  Background:
    Given a provider "foo.3scale.localhost"
      And provider "foo.3scale.localhost" has "groups" switch allowed
      And provider "foo.3scale.localhost" has "multiple_applications" visible
      And an approved buyer "alice" signed up to provider "foo.3scale.localhost"

    And the provider has the following section:
      | Title  | Partial path | Public |
      | Docs   | /docs        | True   |
      | Secret | /secret      | False  |
    And the provider has the following page:
      | Title | Section | Path          | System name   | Published |
      | First | Docs    | /docs/first   | first_public  | First     |
      | First | Secret  | /secret/first | first_private | First     |

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
    And I uncheck "Public"
    And I press "Update"
    Then the "Public" checkbox should not be checked
    And the section "Docs" of provider "foo.3scale.localhost" should be access restricted

  @allow-rescue
  Scenario: Access restricted sections are access denied for not logged in users
    Given the current domain is "foo.3scale.localhost"
     When I request the url "/secret/first"
     Then I should see "Not found"


  @allow-rescue
  Scenario: Access restricted sections are access denied to not-allowed users
      And I am logged in as "alice" on foo.3scale.localhost
     When I request the url "/secret/first"
     Then I should see "Not found"

  Scenario: Access restricted sections are access granted to allowed users
    And buyer "alice" has access to section "Secret" of the provider
    Given I am logged in as "alice" on foo.3scale.localhost
     When I request the url "/secret/first"
    Then I should see "First"
