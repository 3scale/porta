Feature: XSS Protection
  In order to protect providers as much as we can
  We need automatic XSS protection in liquid

  Background:
    Given a provider "foo.example.com"
    And the current provider is foo.example.com
    And the provider has cms page "/some-page" with:
    """
      Hello {{ current_account.name }}
      Value {{ current_account.fields.org_name }}
    """
    And I'm logged in as a malicious buyer

  Scenario: XSS Protection is enabled
    When provider has xss protection enabled
    And I visit "/some-page"
    Then I should see "Hello malicious <script></script>buyer"
    Then I should see "Value malicious <script></script>buyer"

  Scenario: XSS Protection is disabled

    When provider has xss protection disabled
    And I visit "/some-page"
    Then I should see "Hello malicious buyer"
    Then I should see "Value malicious buyer"