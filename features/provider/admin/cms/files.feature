@javascript
Feature: CMS files

  Background:
    Given a provider is logged in

  Scenario: Deleting a file
    Given a downloadable CMS file
    And they go to the CMS file's edit page
    When they follow "Delete"
    And confirm the dialog
    Then a success toast alert is displayed with text "File /image deleted"
    And they should not see "hypnotoad.jpg" within the CMS sidebar

  @wip
  Scenario: Uploading new files

  Scenario: Uploading file that is not an image
    Given a local file "test/fixtures/countries.yml"
    When they go to the new CMS file page
    And fill in "Path" with "countries"
    And attach the file located at "test/fixtures/countries.yml"
    And press "Create File"
    Then a success toast alert is displayed with text "Created new file"
    And they should see "countries.yml" within the CMS sidebar

  @wip
  Scenario: Making file downloadable on the developer portal

  @wip
  Scenario: Files accessible from the Developer Portal

  @wip
  Scenario: Updating existing file

  Scenario: Adding a comma separated tag list
    Given a CMS file
    And they go to the CMS file's edit page
    When the form is submitted with:
      | Tag list | pasta, tomato |
    Then a success toast alert is displayed with text "File updated"
    And field "Tag list" should be "pasta, tomato"
