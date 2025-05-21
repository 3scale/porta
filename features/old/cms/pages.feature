@javascript
Feature: CMS Pages
  To provide more info to the developers
  As a provider
  I want to CRUD pages

  Background:
    Given a provider "foo.3scale.localhost"
    And I am logged in as provider "foo.3scale.localhost" on its admin domain
    And I go to the CMS page

  @allow-rescue
  Scenario: Page
      Given a CMS Layout "new-layout" of provider "foo.3scale.localhost"
      When I press "New Page"
       And I toggle "Advanced options"
      And I fill in the following:
        | Title        | Potato        |
        | Path         | /potato       |
        | Tag list     | potato, salad |
        | Content type | text/css      |

       And I select "new-layout" from "Layout"
       And I press "Create Page"
      Then I should see "Template created"
      When I check "Liquid enabled"
       And I select "Markdown" from "Handler"
       And I fill in the draft with:
        """
        # Potato is public!
        """

       And I press "Save"
      Then I should see "Template saved"
      And CMS Page "/potato" should have:
        | Title          | Potato        |
        | Layout         | new-layout    |
        | Liquid enabled | true          |
        | Path           | /potato       |
        | Content type   | text/css      |
        | Handler        | markdown      |
      Then I should see the tags "potato, salad"

       And I press "Publish"
      Then I should see "Template saved and published"

      And I hit "/potato" on foo.3scale.localhost
     Then I should see "<h1>Potato is public!</h1>"

     When I am logged in as provider "foo.3scale.localhost" on its admin domain
      And I go to the CMS Page "/potato" page
      And I follow "Hide" from the CMS "Publish" dropdown
     Then I should see "Template has been hidden"

     When I hit "/potato" on foo.3scale.localhost
     Then I should see "Not found"

  Scenario: Builtin page
    Given provider "foo.3scale.localhost" has all the templates setup

    When I go to the CMS page
     And I choose builtin page "dashboards/show" in the CMS sidebar
     And I fill in the draft with:
      """
        awesomeness builtin
      """

     And I press "Save"
    Then I should see "Template saved"

     And I press "Publish"
    Then I should see "Template saved and published"

     And I follow "Hide" from the CMS "Publish" dropdown
    Then I should see "Template has been hidden"

  @allow-rescue
  Scenario: Bug, preview link should be updated
    Given the provider has cms page "/pathbug" with:
    """
    Hattori Hanzo
    """
    And I go to the CMS Page "/pathbug" page
    And I fill in "Path" with "/hattori"
    And I press "Publish"
    And I should see "Template saved and published"
    Then preview draft link should link to "/hattori"

  Scenario: Update page after unsuccessful validation
    Given the provider has cms page "/some-path" with:
    """
    Sample content
    """
    And I go to the CMS Page "/some-path" page
    And I fill in "Title" with ""
    And I press "Save"
    And I should see "Title can't be blank"
    And I fill in "Title" with "New title"
    And I press "Save"
    And I should see "Template saved"
    And I go to the CMS Page "/some-path" page
    Then I should see "Page 'New title'"
