@javascript
Feature: Application plans index page

  In order to manage Application plans from the index page, I want to perform the following
  actions: create, copy, edit, delete, publish and hide. Moreover, I want to sort the table
  by name, no. of apps and state.

  Background:
    Given a provider is logged in
    And an application plan "Basic" of provider "foo.3scale.localhost"
    And plan "Basic" has applications
    And an application plan that is not default
    And I go to the application plans admin page

  Scenario: Create a simple Application plan
    When I follow "Create Application plan"
    And I fill in "Name" with "Basic"
    And I press "Create Application Plan"
    Then I should be at url for the application plans admin page
    And I should see "Created application plan Basic"

  Scenario: Copy an Application plan
    When I select option "Copy" from the actions menu for plan "Basic"
    Then I should see "Plan copied."
    And I should see "Basic (copy)"

  Scenario: Edit an Application plan
    Given an application plan "Pro" of provider "foo.3scale.localhost"
    And I go to the application plans admin page
    And I follow "Pro"
    And I fill in "Name" with "Enterprise"
    And I press "Update Application plan"
    Then I should be at url for the application plans admin page
    And I should see plan "Enterprise"
    But I should not see plan "Pro"

  Scenario: Delete an Application plan
    Given an application plan "Deleteme" of provider "foo.3scale.localhost"
    When I go to the application plans admin page
    And I select option "Delete" from the actions menu for plan "Deleteme" and I confirm dialog box
    Then the application plan "Deleteme" should be deleted

  Scenario: Delete an Application plan is not allowed if subscribed to any application
    Then I should not see option "Delete" from the actions menu for plan "Basic"

  Scenario: Hide an Application plan
    Given a published plan "Public Plan" of provider "foo.3scale.localhost"
    When I go to the application plans admin page
    And I select option "Hide" from the actions menu for plan "Public Plan"
    Then I should see "Plan Public Plan was hidden."
    And I should see a hidden plan "Public Plan"
    And plan "Public Plan" should be hidden
    And I should not see option "Hide" from the actions menu for plan "Public Plan"

  Scenario: Publish an Application plan
    Given a hidden plan "Secret Plan" of provider "foo.3scale.localhost"
    When I go to the application plans admin page
    And I select option "Publish" from the actions menu for plan "Secret Plan"
    Then I should see "Plan Secret Plan was published."
    And I should see a published plan "Secret Plan"
    And plan "Secret Plan" should be published
    And I should not see option "Publish" from the actions menu for plan "Secret Plan"

  @wip
  Scenario: Sorting Application plans
    Given a published application plan "Plan B" of provider "foo.3scale.localhost"
    And a published application plan "Plan C" of provider "foo.3scale.localhost"
    And a buyer "foo" signed up to application plan "Basic"
    And a buyer "bar" signed up to application plan "Plan B"
    And I am on the application plans admin page
    Then I should see the following table:
      | Name    | Applications | State     |
      | Basic   | 2            | hidden    |
      | Plan B  | 1            | published |
      | Plan C  | 0            | published |

    # TODO: Column sorting not yet implemented
    # And I press on "Name" within the table header
    # Then I should see following table:
    #   | Name    | Applications | State     |
    #   | Plan A  | 2            | hidden    |
    #   | Plan B  | 1            | published |
    #   | Plan C  | 0            | published |

    # And I press on "Name" within the table header
    # Then I should see following table:
    #   | Name    | Applications | State     |
    #   | Plan C  | 0            | published |
    #   | Plan B  | 1            | published |
    #   | Plan A  | 2            | hidden    |

    # And I press on "Applications" within the table header
    # Then I should see following table:
    #   | Name    | Applications | State     |
    #   | Plan A  | 2            | hidden    |
    #   | Plan B  | 1            | published |
    #   | Plan C  | 0            | published |

    # And I press on "Applications" within the table header
    # Then I should see following table:
    #   | Name    | Applications | State     |
    #   | Plan C  | 0            | published |
    #   | Plan B  | 1            | published |
    #   | Plan A  | 2            | hidden    |

    # And I press on "State" within the table header
    # Then I should see following table:
    #   | Name    | Applications | State     |
    #   | Plan A  | 2            | hidden    |
    #   | Plan C  | 0            | published |
    #   | Plan B  | 1            | published |

    # And I press on "State" within the table header
    # Then I should see following table:
    #   | Name    | Applications | State     |
    #   | Plan C  | 0            | published |
    #   | Plan B  | 1            | published |
    #   | Plan A  | 2            | hidden    |

  Scenario: Marking a published plan as default
    Given the application plan is published
    Then an admin can select the application plan as default

  Scenario: Marking a Hidden plan as default
    Given the application plan is hidden
    Then an admin can select the application plan as default
  
  Scenario: Selected plan doesn't exist
    Given the application plan has been deleted
    Then an admin can't select the application plan as default
