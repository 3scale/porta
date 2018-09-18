@javascript
Feature: Bulk operations
  In order to transfer applications from one plan to another
  As a provider
  I want to change applications' plans in bulk

  Background:
    Given a provider "foo.example.com"
    Given a default application plan "Basic" of provider "foo.example.com"
      And provider "foo.example.com" has multiple applications enabled
      And provider "foo.example.com" has "service_plans" switch allowed

    Given a following buyers with applications exists:
      | name | provider        | applications |
      | bob  | foo.example.com | BobApp       |
      | jane | foo.example.com | JaneApp      |
      | mike | foo.example.com | MikeApp      |

    Given current domain is the admin domain of provider "foo.example.com"
      And I don't care about application keys

  Scenario: Mass change of application plans
    Given an application plan "Advanced" of provider "foo.example.com"
      And I am logged in as provider "foo.example.com"
      And I am on the applications admin page

    When I check select for "BobApp", "JaneApp"
      And I press "Change application plan"

    Then I should see "Transfer these applications to different application plan"

    When I select "Advanced" from "Plan"
      And I press "Change plan" and I confirm dialog box

    Then I should see "Action completed successfully"
     And close the colorbox

    When I follow "Name"

    Then I should see following table:
      | Name ▲  | Plan     |
      | BobApp  | Advanced |
      | JaneApp | Advanced |
      | MikeApp | Basic    |
    # TODO: verify changed plans

  @wip
  Scenario: Try to mass change applications from different services
    # TODO: !
