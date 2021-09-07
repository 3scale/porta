Feature: Billing settings
  In order to have control over the billing settings
  As a provider or master
  I want to edit billing settings

Background:
  Given a provider "foo.3scale.localhost" with billing enabled
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"

Scenario: Turning charging on/off
  Given provider "foo.3scale.localhost" has "finance" switch allowed
  When I go to the finance settings page
   And I check "Charging enabled"
   And I press "Save"
  Then I should see "Finance settings updated."
   And the "Charging enabled" checkbox should be checked

Scenario: Setting a currency
  Given provider "foo.3scale.localhost" has "finance" switch allowed
  When I go to the finance settings page
   And I select "USD - American Dollar" from "Currency"
   And I press "Save"
  Then I should see "Finance settings updated."

  When a buyer "zoidberg" of provider "foo.3scale.localhost"
   And an invoice of buyer "zoidberg" for February, 1984
   And I go to the invoices by months page
  Then I should see "USD"
