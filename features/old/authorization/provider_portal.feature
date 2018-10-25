Feature: Provider portal section authorization
  In order to manage my portal
  As a provider
  I want to control who can access the portal area

  Background:
    Given a provider "foo.example.com"
      And provider "foo.example.com" has Browser CMS activated
    Given current domain is the admin domain of provider "foo.example.com"

  Scenario Outline: Provider admin can access portal
    When I log in as provider "foo.example.com"

    When I go to the provider dashboard
    Then I should see the link "Portal" in the audience dashboard widget

    When I go to the <page> page
    Then I should be on the <page> page

    Examples:
      | page          |
      | CMS Templates |
      | CMS Sections  |
      | CMS Files     |

  Scenario: Provider admin can access portal groups
    When I log in as provider "foo.example.com"
    When I want to go to the groups page
    Then I should get access denied

    When provider "foo.example.com" has "groups" switch allowed

    When I go to the groups page
    Then I should be on the groups page

  Scenario Outline: Members by default cannot access portal
    Given an active user "member" of account "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"

    When I log in as provider "member"
     And I go to the provider dashboard
    Then I should not see "Portal" in the audience dashboard widget

    When I request the url of the '<page>' page then I should see an exception

    Examples:
      | page          |
      | CMS Templates |
      | CMS Sections  |
      | CMS Files     |
      #not groups
      | groups |

  Scenario: Members of portal group can not access portal groups area
    Given an active user "member" of account "foo.example.com"
     And user "member" has access to the admin section "portal"
     When I log in as provider "member"
     When I request the url of the 'groups' page then I should see an exception

  Scenario Outline: Members of portal group can access portal
    Given an active user "member" of account "foo.example.com"
      And user "member" has access to the admin section "portal"
     When I log in as provider "member"
      And I go to the provider dashboard
    Then I should see "Portal" in the audience dashboard widget

    When I go to the <page> page
    Then I should be on the <page> page

    Examples:
      | page          |
      | CMS Templates |
      | CMS Sections  |
      | CMS Files     |
