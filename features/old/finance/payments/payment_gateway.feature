Feature: Provider's payment gateway
  In order to accept payments from my users
  As a provider
  I want to set up my payment gateway

  Background:
    Given a provider "foo.example.com"

  Scenario: Credit card gateway shown for admins with finance and charging
    Given provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the finance settings page
    Then I should see "Credit card gateway"

  Scenario: Credit card gateway not shown for admins with finance without charging
    Given provider "foo.example.com" is not charging
      And provider "foo.example.com" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    And I go to the finance settings page
    Then I should not see "Credit card gateway"

  Scenario: Credit card gateway not shown for admins without finance switch
    Given provider "foo.example.com" is not charging
      And provider "foo.example.com" has "finance" switch denied
    And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway shown for members with permission with finance and charging
    Given provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "finance"
    When I log in as provider "member"
    And I go to the finance settings page
    Then I should see "Credit card gateway"

  Scenario: Credit card gateway not shown for members with permission with finance without charging
    Given provider "foo.example.com" is not charging
      And provider "foo.example.com" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "finance"
    When I log in as provider "member"
    And I go to the finance settings page
    Then I should not see "Credit card gateway"

  Scenario: Credit card gateway not shown for members with permission without finance switch
    Given provider "foo.example.com" is not charging
      And provider "foo.example.com" has "finance" switch denied
    And current domain is the admin domain of provider "foo.example.com"
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "finance"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway shown for members without permission with finance and charging
    Given provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "finance" of provider "foo.example.com"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway not shown for members without permission with finance without charging
    Given provider "foo.example.com" is not charging
      And provider "foo.example.com" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.example.com"
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "finance" of provider "foo.example.com"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway not shown for members without permission without finance switch
    Given provider "foo.example.com" is not charging
      And provider "foo.example.com" has "finance" switch denied
    And current domain is the admin domain of provider "foo.example.com"
    Given an active user "member" of account "foo.example.com"
      And user "member" does not belong to the admin group "finance" of provider "foo.example.com"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

    # All these depend on javascript being enabled. Don't know how to simulate that...
    #
    # When I select "Authorize.Net" from "Gateway"
    # And I fill in "LoginID" with "foo"
    # And I fill in "Transaction Key" with "1234"
    # And I press "Save changes"
    # Then I should see "Credit card gateway details were successfully saved"
    # And the "LoginID" field should contain "foo"
    # And the "Transaction Key" field should contain "1234"
