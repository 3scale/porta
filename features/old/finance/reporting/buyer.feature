Feature: Billing Reporting
  In order to be informed about my spendings
  As a buyer of a provider that has billing enabled
  I want to see receive email notifications about non-zero invoices issued for me

  # General rule:
  # - IF the bill in a given month is Zero (for whatever reason) no email is sent.

  Background:
    Given a provider "foo.3scale.localhost" on 1st May 2009
      And the provider is charging its buyers
      And all the rolling updates features are off
      And the provider is charging its buyers
      And admin of account "foo.3scale.localhost" has email "admin@foo.3scale.localhost"
    And admin of account "foo.3scale.localhost" has notification "unsuccessfully_charged_invoice_provider" enabled
      And the default service of the provider has name "My API"
      And the following application plans:
        | Product | Name          | Cost per month |
        | My API  | FreeAsInBeer  | 0              |
        | My API  | PaidAsInLunch | 31             |

  Scenario: I don't want to get email if I am on free plan
      Given the time is 29th May 2009
        And a buyer "stallman" signed up to application plan "FreeAsInBeer"
        And I act as "stallman"
        And no emails have been sent

       When the time flies to 1st June 2009
       Then I should receive no email

       When the time flies to 30th June 2009
       Then I should receive no email

  Scenario: I don't want to get email if I am excused from charging
      Given the time is 29th May 2009
        And a buyer "evader" signed up to application plan "PaidAsInLunch"
        And buyer "evader" is not charged monthly
        And I act as "evader"
        And no emails have been sent

       When the time flies to 30th June 2009
       Then I should receive no email

  Scenario: On paid plan, I WANT to get just 1 email: report about upcoming transaction
      Given the time is 27th May 2009
        And a buyer "rich" signed up to application plan "PaidAsInLunch"
        And buyer "rich" has a valid credit card
        And I act as "rich"
        And no emails have been sent

        When the time flies to 3rd June 2009
        Then I should receive an email with subject "Monthly statement"

  @commit-transactions
  Scenario: Me and my provider should be alarmed about failed payments
      Given the time is 27th May 2009
        And a buyer "broke" signed up to application plan "PaidAsInLunch"
        And buyer "broke" has a valid credit card with no money
        And I act as "broke"

        When the time flies to 3rd June 2009
        Then I should receive an email with subject "Monthly statement"

      # TODO: dry following steps by table or something because this is not good
      Then on 5th June 2009, me and "admin@foo.3scale.localhost" should get email about payment problem
       And on 8th June 2009, me and "admin@foo.3scale.localhost" should get email about payment problem
       And on 11th June 2009, me and "admin@foo.3scale.localhost" should get email about payment problem

  @commit-transactions
  Scenario: I should be warned 10 days before my credit card expires and never ever after
      Given the time is 16th May 2009
        And a buyer "broke" signed up to application plan "FreeAsInBeer"
        And buyer "broke" has a valid credit card with no money that expires on May 27, 2009

       When the time flies to 17th May 2009
        And I act as "broke"
       Then I should receive an email with subject "Credit card expiry"
        And "admin@foo.3scale.localhost" should receive an email with subject "broke’s credit card is due to expire"

       Given a clear email queue
       And the time flies to 27th May 2009
       Then I should receive no email with subject "Credit card expiry"
