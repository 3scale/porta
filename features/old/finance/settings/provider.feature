Feature: Billing settings
  In order to have control over the billing settings
  As a provider or master
  I want to edit billing settings

Background:
  Given a provider "foo.example.com" with billing enabled
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

Scenario: Finance settings do no show if finance switch is denied
  Given provider "foo.example.com" has "finance" switch denied
  When I go to the settings page
  Then I should not see link to the finance settings page

Scenario: Turning charging on/off
  Given provider "foo.example.com" has "finance" switch allowed
  When I go to the finance settings page
   And I check "Charging enabled"
   And I press "Save"
  Then I should see "Finance settings updated."
   And the "Charging enabled" checkbox should be checked

Scenario: Switch postpaid/prepaid mode


Scenario: Setting a currency
  Given provider "foo.example.com" has "finance" switch allowed
  When I go to the finance settings page
   And I select "USD - American Dollar" from "Currency"
   And I press "Save"
  Then I should see "Finance settings updated."

  When a buyer "zoidberg" of provider "foo.example.com"
   And an invoice of buyer "zoidberg" for February, 1984
   And I go to the invoices by months page
  Then I should see "USD"
