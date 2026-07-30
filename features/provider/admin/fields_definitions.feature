@javascript
Feature: Fields definitions form
  As a provider
  The fields definitions form allows creating and editing custom fields

  Background:
    Given a provider is logged in

  Scenario: Selecting a new field enables name input and checkboxes
    When they go to the fields definitions index page
    And they follow any "Create"
    And they select "[new field]" from "fields_definition_fieldname"
    Then the "fields_definition_name" field should not be readonly
    And the "fields_definition_required" checkbox should not be disabled
    And the "fields_definition_hidden" checkbox should not be disabled
    And the "fields_definition_read_only" checkbox should not be disabled

  Scenario: Selecting an existing field disables name input
    When they go to the fields definitions index page
    And they follow any "Create"
    And they select "[new field]" from "fields_definition_fieldname"
    Then the "fields_definition_name" field should not be readonly
    When they select the first non-new-field option from "fields_definition_fieldname"
    Then the "fields_definition_name" field should be readonly

  Scenario: Checking required disables hidden and read_only
    When they go to the fields definitions index page
    And they follow any "Create"
    And they select "[new field]" from "fields_definition_fieldname"
    And they switch "Required" on
    Then the "fields_definition_hidden" checkbox should be disabled
    And the "fields_definition_read_only" checkbox should be disabled

  Scenario: Unchecking required re-enables hidden and read_only
    When they go to the fields definitions index page
    And they follow any "Create"
    And they select "[new field]" from "fields_definition_fieldname"
    And they switch "Required" on
    Then the "fields_definition_hidden" checkbox should be disabled
    When they switch "Required" off
    Then the "fields_definition_hidden" checkbox should not be disabled
    And the "fields_definition_read_only" checkbox should not be disabled
