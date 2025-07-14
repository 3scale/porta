@javascript
Feature: Legal terms settings
  In order to control the legal terms content comfortably
  As a provider
  I want manage them on a separate settings page

  Background:
    Given a provider is logged in

  Scenario: Signup Licence
    When I go to the legal terms settings page
    And I fill in the draft with:
      """
      <b>Ich war hier, Fantomas.</b>
      """
    And I press "Update"
    Then I should see "Legal terms saved"
    When the current domain is "foo.3scale.localhost"
    And I go to the signup page
    Then I should see "Ich war hier, Fantomas"

  Scenario: Legal Terms settings
    Given provider "foo.3scale.localhost" has "multiple_services" switch allowed
    And I go to the legal terms settings page
    And I fill in the draft with:
      """
      <b>Ich war hier, Fantomas.</b>
      """
    And I press "Update"
    Then I should see "Legal terms saved"
