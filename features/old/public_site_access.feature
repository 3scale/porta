Feature: Public site access
  In order to see how the public/buyer side of my site looks like
  As a provider
  I want to get there while logged in in the provider side

  Background:
    Given a provider "foo.example.com"

  @wip @3D
  Scenario: Provider dashboard link takes to the admin side
    Given the current domain is foo.example.com
      And I log in as provider "foo.example.com"
      And I follow "Admin" in the user widget
    Then the current domain should be the master domain

  @wip @3D
  Scenario: Provider admin link takes to the admin side
    Given the current domain is foo.example.com
      And I log in as provider "foo.example.com"
    When I follow "Admin" in the user widget
    Then the current domain should be the master domain

  @wip
  Scenario: View site on a non-standard port
    Given current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"
    Then the current port should not be 80
    When I follow "Site" in the user widget
    Then the current domain should be foo.example.com
      And the current port should not be 80

  @javascript
  Scenario: View site when site access code is set
    Given provider "foo.example.com" has site access code "foobar"
      And current domain is the admin domain of provider "foo.example.com"
     When I log in as provider "foo.example.com"
      And I follow "Developer Portal"
      And I follow "Visit Portal"
     Then the current domain should be foo.example.com
      And I should not see field "Access code"

  # Scenario: Master account has neither "view site" nor "admin" links
  #    Given current domain is the admin domain of provider "foo.example.com"
  #     When I log in as "superadmin"
  #      And I go to the dashboard
  #     Then I should not see link "Site" in the user widget
  #     And I should not see link "Admin" in the user widget
