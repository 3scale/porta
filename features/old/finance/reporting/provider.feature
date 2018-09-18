Feature: Billing Reporting for Provider
  In order to be informed about my buyers billing
  As a provider that has finance enabled
  I want to receive email notifications about non-zero invoices

  # General rule:
  # - IF the bill in a given month is Zero (for whatever reason) no email is sent.

  Background:
    Given a provider "foo.example.com"
      And all the rolling updates features are off
      And provider "foo.example.com" is fake charging
      And provider "foo.example.com" has valid payment gateway
      And admin of account "foo.example.com" has email "admin@foo.example.com"
      And an application plan "FreeAsInBeer" of provider "foo.example.com" for 0 monthly
      And an application plan "PaidAsInLunch" of provider "foo.example.com" for 31 monthly

  Scenario: I should be notified about upcoming issue of non-zero invoices
    Given the time is 27th May 2009
      And a buyer "jason" signed up to application plan "PaidAsInLunch"
      And a buyer "lorreta" signed up to application plan "PaidAsInLunch"

     When the time flies to 1st June 2009
      And I act as "foo.example.com"
     Then I should receive an email with subject "Invoices to review"
