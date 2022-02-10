Feature: Provider's payment gateway
  In order to accept payments from my users
  As a provider
  I want to set up my payment gateway

  Background:
    Given a provider "foo.3scale.localhost"

  Scenario: Credit card gateway shown for admins with finance and charging
    Given provider "foo.3scale.localhost" is charging
    And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the finance settings page
    Then I should see "Credit card gateway"

  @javascript
  Scenario: Use Stripe as payment gateway
    Given provider "foo.3scale.localhost" is charging
    And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost"
    And I go to the finance settings page
    And I select "Stripe" from "Gateway"
    And I fill in "Secret Key" with "secret"
    And I fill in "Publishable Key" with "publishable"
    And I fill in "Webhook Signing Secret" with "webhook"
    And I press "Save changes" and I confirm dialog box twice
    Then I should see "Payment gateway details were successfully saved."

  Scenario: Credit card gateway not shown for admins with finance without charging
    Given provider "foo.3scale.localhost" is not charging
      And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
    And I go to the finance settings page
    Then I should not see "Credit card gateway"

  Scenario: Credit card gateway not shown for admins without finance switch
    Given provider "foo.3scale.localhost" is not charging
      And provider "foo.3scale.localhost" has "finance" switch denied
    And current domain is the admin domain of provider "foo.3scale.localhost"
    When I log in as provider "foo.3scale.localhost"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway shown for members with permission with finance and charging
    Given provider "foo.3scale.localhost" is charging
      And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" has access to the admin section "finance"
    When I log in as provider "member"
    And I go to the finance settings page
    Then I should see "Credit card gateway"

  Scenario: Credit card gateway not shown for members with permission with finance without charging
    Given provider "foo.3scale.localhost" is not charging
      And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" has access to the admin section "finance"
    When I log in as provider "member"
    And I go to the finance settings page
    Then I should not see "Credit card gateway"

  Scenario: Credit card gateway not shown for members with permission without finance switch
    Given provider "foo.3scale.localhost" is not charging
      And provider "foo.3scale.localhost" has "finance" switch denied
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" has access to the admin section "finance"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway shown for members without permission with finance and charging
    Given provider "foo.3scale.localhost" is charging
      And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" does not belong to the admin group "finance" of provider "foo.3scale.localhost"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway not shown for members without permission with finance without charging
    Given provider "foo.3scale.localhost" is not charging
      And provider "foo.3scale.localhost" has "finance" switch allowed
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" does not belong to the admin group "finance" of provider "foo.3scale.localhost"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception

  Scenario: Credit card gateway not shown for members without permission without finance switch
    Given provider "foo.3scale.localhost" is not charging
      And provider "foo.3scale.localhost" has "finance" switch denied
    And current domain is the admin domain of provider "foo.3scale.localhost"
    Given an active user "member" of account "foo.3scale.localhost"
      And user "member" does not belong to the admin group "finance" of provider "foo.3scale.localhost"
    When I log in as provider "member"
     And I request the url of the 'finance settings' page then I should see an exception
