Feature: Check there is no Internet access

  @javascript
  Scenario: Browser has no Internet access
    Given URL is inaccessible in browser: "https://status.redhat.com:443"
    And URL is inaccessible in browser: "https://www.google.com:443"

  Scenario: No internet in Ruby
    Given URL is inaccessible in ruby: "https://status.redhat.com"
    And URL is inaccessible in ruby: "https://www.google.com"
    And hostname is not resolvable: "www.google.com"
    And hostname is not resolvable: "status.redhat.com"
