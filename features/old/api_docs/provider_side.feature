Feature: API Docs Management
  In order to enlighten our developers
  I want to provide interactive API documentation

  Background:
    Given a provider "foo.example.com"
    And provider "foo.example.com" has multiple applications enabled
    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

    When I go to the provider dashboard
    And I follow "API" within the main menu
    And I follow "ActiveDocs" within "#second_nav"

  Scenario: CRUD a JSON description of your API service
    When I follow "Create your first spec"
    Then I should see "ActiveDocs: New Service Spec"

    When I fill in "Name" with "Magic Bean Maker"
    And I fill in "API JSON Spec" with:
    """
    {"name":"Magic Bean Maker", "basePath":"http://magicbeans.com/api", "apis":[]}
    """
    And I press "Create Service"
    Then I should see "ActiveDocs Spec was successfully saved."

    When I follow "Edit"
    Then I should see "ActiveDocs: Edit Service Spec"

    And I fill in "API JSON Spec" with:
    """
    {"name":"The Magic Maker of Beans", "basePath":"http://magicbeans.com/api", "apis":[]}
    """
    And I press "Update Service"
    Then I should see "ActiveDocs Spec was successfully updated."
