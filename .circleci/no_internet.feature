Feature: Check there is no Internet access

  @javascript
  Scenario: Browser has no Internet access
    Given URL is inaccessible in browser: "https://status.redhat.com:443"
