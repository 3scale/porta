Feature: Public site access
  In order to see how the public/buyer side of my site looks like
  As a provider
  I want to get there while logged in in the admin portal

  Background:
    Given a provider is logged in

  @javascript
  Scenario: View site when site access code is set
    When I follow "Developer Portal"
    And I follow "Visit Portal"
    Then the current domain in a new window should be foo.3scale.localhost
    And I should not see field "Access code"
