Feature: Master finance settings
  In order to manage provider accounts
  As a master
  I want to be able turn on/off the billing

  @javascript @wip @evil
  Scenario: Enable finance module
    Given a provider "foo.3scale.localhost" with billing disabled
      And current domain is the admin domain of provider "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"

      # TODO: DRY?
      When I follow "Accounts"
       And I follow "foo.3scale.localhost"
       And I follow "Configuration"
       And I check config value "Billing mode"
    When I log out
     And current domain is the admin domain of provider "foo.3scale.localhost"
     And I log in as provider "foo.3scale.localhost"
    Then I should see "Billing"

