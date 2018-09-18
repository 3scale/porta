Feature: Access code
  In order to prevent random people from seeing my site while it's in a private beta phase
  As a provider
  I want to protect the access with access code

  Scenario: No access code
    Given a provider "foo.example.com"
    And provider "foo.example.com" has no site access code
    When the current domain is foo.example.com
    And I go to the homepage
    Then I should not see "Access code"

  Scenario: Invalid access code
    Given a provider "foo.example.com"
    And provider "foo.example.com" has site access code "foobar"
    When the current domain is foo.example.com
    And I go to the homepage
    And I fill in "Access code" with "random"
    And I press "Enter"
    Then I should see "Access code"

  Scenario: Valid access code
    Given a provider "foo.example.com"
    And provider "foo.example.com" has site access code "foobar"
    When the current domain is foo.example.com
    And I go to the homepage
    And I fill in "Access code" with "foobar"
    And I press "Enter"
    Then I should not see "Access code"

  Scenario: Valid access code in any page not being homepage
    Given a provider "foo.example.com"
      And provider "foo.example.com" has site access code "foobar"
    When the current domain is foo.example.com
      And I go to the dashboard page
      And I enter "foobar" as access code
    Then I should not be in the access code page

  #TODO add test cases to assert we land in the page desired in the first place

  Scenario: Several invalid access code should not loose url
    Given a provider "foo.example.com"
      And provider "foo.example.com" has site access code "foobar"
    When the current domain is foo.example.com
      And I go to the dashboard page
      And I enter "a wrongcode" as access code
      And I enter "a wrongcode" as access code
      And I enter "foobar" as access code
    Then I should not be in the access code page

  @wip
  Scenario: Access code on domain that supports SSL
    Given a provider "foo.example.com"
    And provider "foo.example.com" has site access code "foobar"
    And domain "foo.example.com" supports SSL
    When the current domain is foo.example.com
    And I go to the homepage
    Then I should feel secure
    When I fill in "Access code" with "foobar"
    And I press "Enter"
    Then I should not see "Access code"
