@emails
Feature: Billing Reporting Without Charging
  In order to pay by cash
  As a buyer of a provider that is billing but not charging
  I don't want to receive emails about charging

  # General rule:
  # - IF the bill in a given month is Zero (for whatever reason) no email is sent.

  Background:
      Given a provider "not.charging"
        And all the rolling updates features are off
        And provider "not.charging" is not charging
        And an application plan "ToRuleTheWorld" of provider "not.charging" for 42000 monthly
        And admin of account "not.charging" has email "admin@not.charging"

  Scenario: I don't want to get email if my provider is not charging
       When the time is 27th May 2009
        And a buyer "nixon" signed up to application plan "ToRuleTheWorld"
        And I act as "nixon"
        And no emails have been sent

       When the time flies to 1st June 2009
       Then I should receive 0 emails
        And "admin@not.charging" should receive 1 emails
        And "admin@not.charging" should receive an email with subject "Invoices to review"
