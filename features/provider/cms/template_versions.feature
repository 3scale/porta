@javascript
Feature: CMS Template versions

  Background:
    Given a provider is logged in
    And the time flies to 2012-12-24 12:00:00
    And the provider has cms page "/my-page" with:
      """
      <div>Original Prankster</div>
      """
    And they go to the CMS Page "/my-page" page

  Scenario: Save as version
    Given they fill the template draft with "version 1"
    And save it as version
    And they fill the template draft with "version 2"
    And save it as version
    When they follow "Versions"
    Then the table should contain the following:
      | Created On               | Type of Version | Changes |
      | 24 Dec 2012 12:00:00 UTC | draft           | +1-1    |
      | 24 Dec 2012 12:00:00 UTC | draft           | +1-1    |
      | 24 Dec 2012 12:00:00 UTC | draft           | +1-0    |

  Scenario: Revert to version from the list of versions
    Given they fill the template draft with "<div>Dammit, I Changed Again</div>"
    And press "Save"
    And they go to the CMS Page "/my-page" page
    And the draft template should contain "Dammit, I Changed Again"
    When they follow "Versions"
    And follow "Revert"
    And confirm the dialog
    Then a success toast alert is displayed with text "Reverted to version from 24 Dec 2012 12:00:00 UTC"
    Then the draft template should contain "Original Prankster"

  Scenario: Revert to version from the version itself
    Given they fill the template draft with "<div>Dammit, I Changed Again</div>"
    And press "Save"
    When they follow "Versions"
    And follow "24 Dec 2012 12:00:00 UTC"
    And the version template should contain "Original Prankster"
    When they follow "Revert"
    And confirm the dialog
    Then a success toast alert is displayed with text "Reverted to version from 24 Dec 2012 12:00:00 UTC"
    Then the draft template should contain "Original Prankster"
