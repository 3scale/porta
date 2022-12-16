Feature: Billing Reporting for Provider
  In order to be informed about my buyers billing
  As a provider that has finance enabled
  I want to receive email notifications about non-zero invoices

  # General rule:
  # - IF the bill in a given month is Zero (for whatever reason) no email is sent.

  Background:
    Given a provider "foo.3scale.localhost"
      And all the rolling updates features are off
      And provider "foo.3scale.localhost" is charging its buyers
      And provider "foo.3scale.localhost" has valid payment gateway
      And admin of account "foo.3scale.localhost" has email "admin@foo.3scale.localhost"
      And an application plan "FreeAsInBeer" of provider "foo.3scale.localhost" for 0 monthly
      And an application plan "PaidAsInLunch" of provider "foo.3scale.localhost" for 31 monthly

  Scenario: I should be notified about upcoming issue of non-zero invoices
    Given the time is 27th May 2009
      And a buyer "jason" signed up to application plan "PaidAsInLunch"
      And a buyer "lorreta" signed up to application plan "PaidAsInLunch"

     When the time flies to 1st June 2009
      And I act as "foo.3scale.localhost"
     Then I should receive an email with subject "Invoices to review"
