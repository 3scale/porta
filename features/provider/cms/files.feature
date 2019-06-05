@javascript
Feature: CMS files
  As a provider I want to be able to upload files to portal

  Background:
    Given a provider is logged in

  Scenario: Deleting a file
    Given there is a downloadable cms file
     When the file is deleted
     Then there is not an image preview of that file

  Scenario: Uploading new file
    When there is a downloadable cms file
    Then there is an image preview of that file

   Scenario: Uploading file that is not an image
     When I upload a file that is not an image to the cms
     Then there is not an image preview of that file

  Scenario: Making file downloadable on the developer portal
    Given there is a downloadable cms file
    When I access the file on developer portal
    Then the file should be downloaded

  Scenario: Files accessible from the Developer Portal
    Given there is a cms file
    When I access the file on developer portal
    Then the file should be the same as uploaded

  Scenario: Updating existing file
    Given there is a cms file
    When I update the file with different image
    Then the file should be updated
      And the original file should be gone
