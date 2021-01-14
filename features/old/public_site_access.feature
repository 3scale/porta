Feature: Public site access
  In order to see how the public/buyer side of my site looks like
  As a provider
  I want to get there while logged in in the provider side

  Background:
    Given a provider "foo.3scale.localhost"

  @wip @3D
  Scenario: Provider dashboard link takes to the admin side
    Given the current domain is "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"
      And I follow "Admin" in the user widget
    Then the current domain should be the master domain

  @wip @3D
  Scenario: Provider admin link takes to the admin side
    Given the current domain is "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"
    When I follow "Admin" in the user widget
    Then the current domain should be the master domain

  @wip
  Scenario: View site on a non-standard port
    Given current domain is the admin domain of provider "foo.3scale.localhost"
      And I log in as provider "foo.3scale.localhost"
    Then the current port should not be 80
    When I follow "Site" in the user widget
    Then the current domain should be "foo.3scale.localhost"
      And the current port should not be 80

  @javascript
  Scenario: View site when site access code is set
    Given provider "foo.3scale.localhost" has site access code "foobar"
      And current domain is the admin domain of provider "foo.3scale.localhost"
     When I log in as provider "foo.3scale.localhost"
      And I follow "Developer Portal"
      And I follow "Visit Portal"
     Then the current domain in a new window should be "foo.3scale.localhost"
      And I should not see field "Access code"

  # Scenario: Master account has neither "view site" nor "admin" links
  #    Given current domain is the admin domain of provider "foo.3scale.localhost"
  #     When I log in as "superadmin"
  #      And I go to the dashboard page
  #     Then I should not see link "Site" in the user widget
  #     And I should not see link "Admin" in the user widget
