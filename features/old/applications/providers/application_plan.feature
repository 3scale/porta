@ignore-backend @javascript
Feature: Applications plan
  In order to control the plan of applications
  As a provider
  I want to do stuff with the application's plans

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" uses backend v2 in his default service
      And provider "foo.example.com" has multiple applications enabled
      And a default application plan "Basic" of provider "foo.example.com"
      And a buyer "bob" signed up to provider "foo.example.com"
      And buyer "bob" has application "OKWidget"

    Given current domain is the admin domain of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
      And I don't care about application keys

  Scenario: Plan change does not show with only one plan
    When I navigate to the page of the partner "bob"
      And I follow the link to application "OKWidget" in the applications widget
    Then I should see the plan details widget
      But I should not see the change plan widget


  Scenario: Changing plan to app
    Given an application plan "Another" of provider "foo.example.com"
    When I navigate to the application "OKWidget" of the partner "bob"
    Then I should see the app plan is "Basic"

    When I change the app plan to "Another"
    Then I should see the app plan is "Another"

  Scenario: Plan can always be customized
    When I navigate to the page of the partner "bob"
      And I follow the link to application "OKWidget" in the applications widget
    Then I should be able to customize the plan

  Scenario: It shows Application expiration date when application contract is on trial
    Given the application "OKWidget" of the partner "bob" has a trial period of 10 days
    When I navigate to the application "OKWidget" of the partner "bob"
    Then I should see "trial expires in 10 days"

  @javascript
  Scenario: Customizing/Decustomizing plan of app
    Given an application plan "Another" of provider "foo.example.com"
    When I navigate to the application "OKWidget" of the partner "bob"
      And I customize the app plan
    Then I should see the app plan is customized

    When I decustomize the app plan
    Then I should see the app plan is "Basic"

  Scenario: Sorting Application Plans
    When an published application plan "Other" of provider "foo.example.com"
     And a buyer "foo" signed up to application plan "Other"
     And a buyer "bar" signed up to application plan "Other"
     And I am on the application plans admin page

    And I follow "Applications" within table header
    Then I should see following table:
      | Name   | Applications ▲ | State     |
      | Basic  | 1              | hidden    |
      | Other  | 2              | published |

    And I follow "Applications" within table header
    Then I should see following table:
      | Name   | Applications ▼ | State     |
      | Other  | 2              | published |
      | Basic  | 1              | hidden    |

    And I follow "State" within table header
    Then I should see following table:
      | Name   | Applications | State ▲   |
      | Basic  | 1            | hidden    |
      | Other  | 2            | published |

    And I follow "State" within table header
    Then I should see following table:
      | Name   | Applications | State ▼   |
      | Other  | 2            | published |
      | Basic  | 1            | hidden    |

    And I follow "Name" within table header
    Then I should see following table:
      | Name ▲ | Applications | State     |
      | Basic  | 1            | hidden    |
      | Other  | 2            | published |

    And I follow "Name" within table header
    Then I should see following table:
      | Name ▼ | Applications | State     |
      | Other  | 2            | published |
      | Basic  | 1            | hidden    |

  @javascript
  Scenario: Try to delete an application plan with subscribed applications
    When I am on the application plans admin page
    When I follow "Delete" and I confirm dialog box
    Then I should see "This application plan cannot be deleted!"

  @javascript
  Scenario: Delete an application plan with no subscribed applications
    When the provider deletes the application named "OKWidget"
      And I am on the application plans admin page
      And I follow "Delete" and I confirm dialog box
      Then I should see "The plan was deleted"
