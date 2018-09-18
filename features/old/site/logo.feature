Feature: Logo
  In order to present my company identity on my admin portal
  As a provider
  I want to upload my logo

  Background:
    Given a provider "foo.example.com"
    And the provider has "branding" switch allowed

  @javascript
  Scenario: Upload logo
    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
    When I follow "Account and Personal Settings"
      And I follow "Account"
      And I follow "Logo"
      And I attach the file "test/fixtures/hypnotoad.jpg" to "profile_logo"
      And I press "Upload"
    Then I should be on the edit provider logo page
      And I should see image "hypnotoad.jpg"
      And provider "foo.example.com" should have logo "hypnotoad.jpg"


  Scenario: Delete logo
    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
    Given provider "foo.example.com" has logo "test/fixtures/hypnotoad.jpg"
    When I follow "Account"
      And I follow "Logo"
    Then I should see image "hypnotoad.jpg"

    When I follow "Delete"
    Then I should be on the edit provider logo page
      And I should not see image "hypnotoad.jpg"
      And provider "foo.example.com" should have no logo
