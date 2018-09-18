Feature: Log Entries
  In order to know happened with my billing system
  As a provider or master
  I want to see traces of what happened to billing strategy

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" is charging
      And provider "foo.example.com" has "finance" switch visible
    Given an application plan "FreeAsInBeer" of provider "foo.example.com" for 0 monthly
      And an application plan "PaidAsInLunch" of provider "foo.example.com" for 31 monthly
      And an application plan "PaidAsInDiplomat" of provider "foo.example.com" for 3100 monthly
    Given the current domain is foo.example.com

@wip
  Scenario: Log Entry is created when invoice is issued
    Given the time is 25th April 2009
      And provider "foo.example.com" is charging
      And a buyer "stallman" signed up to application plan "PaidAsInLunch"

    When time flies to 15th May 2009
      And current domain is the admin domain of provider "foo.example.com"
    When I log in as provider "foo.example.com"
    When I go to the log entries page
     And I wait for 3 seconds
    Then I should see the following log entries:
    | level |       time | text                                                                                     |
    | INFO  | 2009-04-26 | Billing account stallman for plan PaidAsInLunch (just signed up or trial period expired) |
    | INFO  | 2009-04-26 | Billing account stallman for plan plan1 (just signed up or trial period expired)         |
    | INFO  | 2009-04-26 | Invoice created for stallman for period April  1, 2009 - April 30, 2009                  |
    | INFO  | 2009-05-01 | Billing variable cost of stallman                                                        |
    | INFO  | 2009-05-01 | Issuing invoice for stallman for period April  1, 2009 - April 30, 2009                  |
    | INFO  | 2009-05-01 | Billing fixed cost of account stallman                                                   |
    | INFO  | 2009-05-01 | Invoice created for stallman for period May  1, 2009 - May 31, 2009                      |

@wip
    Scenario: Log entry warning is created on provider's billing strategy change
      Given the time is 2nd May 2009
      And provider "foo.example.com" is charging
      And a buyer "stallman" signed up to application plan "PaidAsInLunch"
      When time flies to 15th May 2009
      And provider "foo.example.com" changes billing to prepaid
      When time flies to 17th May 2009
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
      And I go to the log entries page
      Then I should see log entry "Changed Billing Strategy to prepaid" with level "WARNING" on "2009-05-15"
