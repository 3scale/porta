@javascript
Feature: Legal terms settings
  In order to control the legal terms content comfortably
  As a provider
  I want manage them on a separate settings page

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

  Scenario: Signup Licence
    When I go to the legal terms settings page
     And I follow "Portal" in the main menu
     And I follow "Sign-up" in the subsubmenu
     And I fill in draft with:
        """
        <b>Ich war hier, Fantomas.</b>
        """
    And I press "Update"
    When the current domain is "foo.example.com"
     And I go to the signup page
     Then I should see "Ich war hier, Fantomas."


  Scenario Outline: Legal Terms settings
   Given provider "foo.example.com" has "multiple_services" switch allowed
     And I go to the legal terms settings page
     And I follow "Portal" in the main menu
     And I choose "<legal_term>" in the subsubmenu
     And I fill in draft with:
        """
        <b>Ich war hier, Fantomas.</b>
        """
    And I press "Update"
    Then I should see "Legal terms saved"
    # TODO: view the right pages to see they are included

    Examples:
    | legal_term   |
    | Application  |
    | Subscription |
