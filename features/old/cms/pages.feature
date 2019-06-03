@javascript
Feature: CMS Pages
  To provide more info to the developers
  As a provider
  I want to CRUD pages

  Background:
    Given a provider "foo.example.com"
    And I am logged in as provider "foo.example.com" on its admin domain
    And I go to the CMS page

  @essential @allow-rescue
  Scenario: Page
      Given a CMS Layout "new-layout" of provider "foo.example.com"
      When I follow "New Page"
       And I toggle "Advanced options"
      And I fill in the following:
        | Title        | Potato        |
        | Path         | /potato       |
        | Tag list     | potato, salad |
        | Content type | text/css      |

       And I select "new-layout" from "Layout"
       And I press "Create Page"
      Then I should see "Page created"
      When I check "Liquid enabled"
       And I select "Markdown" from "Handler"
       And I fill in draft with:
        """
        # Potato is public!
        """

       And I press "Save"
      Then I should see "Page saved"
      And CMS Page "/potato" should have:
        | Title          | Potato        |
        | Layout         | new-layout    |
        | Liquid enabled | true          |
        | Path           | /potato       |
        | Content type   | text/css      |
        | Handler        | markdown      |
        | Tag list       | potato salad |

       And I press "Publish"
      Then I should see "Page saved and published"

      And I hit "/potato" on foo.example.com
     Then I should see "<h1>Potato is public!</h1>"

     When I am logged in as provider "foo.example.com" on its admin domain
      And I go to the CMS Page "/potato" page
      And I press "Hide" inside the dropdown
     Then I should see "Page has been hidden"

     When I hit "/potato" on foo.example.com
     Then I should see "Not found"

  Scenario: Builtin page
    Given provider "foo.example.com" has all the templates setup

    When I go to the CMS page
     And I choose builtin page "dashboards/show" in the CMS sidebar
     And I fill in draft with:
      """
        awesomeness builtin
      """

     And I press "Save"
    Then I should see "Built-in page saved"

     And I press "Publish"
    Then I should see "Built-in page saved and published"

     And I press "Hide" inside the dropdown
    Then I should see "Built-in page has been hidden"

  @essential @allow-rescue
  Scenario: Bug, preview link should be updated
    Given the provider has cms page "/pathbug" with:
    """
    Hattori Hanzo
    """
    And I go to the CMS Page "/pathbug" page
    And I fill in "Path" with "/hattori"
    And I press "Publish"
    And I should see "Page saved and published"
    Then preview draft link should link to "/hattori"
