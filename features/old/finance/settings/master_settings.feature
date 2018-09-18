Feature: Master finance settings
  In order to manage provider accounts
  As a master
  I want to be able turn on/off the billing

  @javascript @wip @evil
  Scenario: Enable finance module
    Given a provider "foo.example.com" with billing disabled
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

      # TODO: DRY?
      When I follow "Accounts"
       And I follow "foo.example.com"
       And I follow "Configuration"
       And I check config value "Billing mode"
    When I log out
     And current domain is the admin domain of provider "foo.example.com"
     And I log in as provider "foo.example.com"
    Then I should see "Billing"

