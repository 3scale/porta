Feature: Access code
  In order to prevent random people from seeing my site while it's in a private beta phase
  As a provider
  I want to protect the access with access code

  Background:
    Given a provider

  Scenario: No access code
    Given the provider has no site access code
    When the current domain is foo.3scale.localhost
    And they go to the homepage
    Then they should not see "Access code"

  Scenario: Invalid access code
    Given the provider has site access code "foobar"
    When the current domain is foo.3scale.localhost
    And I go to the homepage
    And I fill in "Access code" with "random"
    And I press "Enter"
    Then I should see "Access code"

  Scenario: Valid access code
    Given the provider has site access code "foobar"
    When the current domain is foo.3scale.localhost
    And I go to the homepage
    And I fill in "Access code" with "foobar"
    And I press "Enter"
    Then I should not see "Access code"

  Scenario: Valid access code in any page not being homepage
    Given the provider has site access code "foobar"
    When the current domain is foo.3scale.localhost
      And I go to the dashboard page
      And I enter "foobar" as access code
    Then I should not be in the access code page

  #TODO add test cases to assert we land in the page desired in the first place

  Scenario: Several invalid access code should not loose url
    Given the provider has site access code "foobar"
    When the current domain is foo.3scale.localhost
      And I go to the dashboard page
      And I enter "a wrongcode" as access code
      And I enter "a wrongcode" as access code
      And I enter "foobar" as access code
    Then I should not be in the access code page

  @javascript
  Scenario: Navigate from admin portal when access code is set
    Given the provider logs in
    And they follow any "Developer Portal"
    When they follow "Visit Portal"
    Then the current domain in a new window should be foo.3scale.localhost
    And they should not see field "Access code"

  @wip
  Scenario: Access code on domain that supports SSL
    Given the provider has site access code "foobar"
    And domain "foo.3scale.localhost" supports SSL
    When the current domain is foo.3scale.localhost
    And I go to the homepage
    Then I should feel secure
    When I fill in "Access code" with "foobar"
    And I press "Enter"
    Then I should not see "Access code"
