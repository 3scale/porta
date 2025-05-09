@emails
Feature: Billing Reporting Without Charging
  In order to pay by cash
  As a buyer of a provider that is billing but not charging
  I don't want to receive emails about charging

  # General rule:
  # - IF the bill in a given month is Zero (for whatever reason) no email is sent.

  Background:
      Given a provider "not.charging" on 1st May 2009
        And all the rolling updates features are off
        And provider "not.charging" is billing but not charging
    And the default service of the provider has name "My API"
    And the following application plans:
      | Product | Name           | Cost per month |
      | My API  | ToRuleTheWorld | 42000          |
        And admin of account "not.charging" has email "admin@not.charging"

  Scenario: I don't want to get email if my provider is not charging
       When the time is 27th May 2009
        And a buyer "nixon" signed up to application plan "ToRuleTheWorld"
        And I act as "nixon"
        And no emails have been sent

       When the time flies to 1st June 2009
       Then I should receive 0 emails
        And "admin@not.charging" should receive 1 emails
        And "admin@not.charging" should receive an email with subject "Action needed: review invoices"
