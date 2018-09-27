Feature: Menu
  In order to navigate easily
  As a provider
  I want to have a concise menu

  Background:
    Given a provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
      And I log in as provider "foo.example.com"

  Scenario: General menu structure
    When I go to the provider dashboard
    Then I should have menu
      | Main Menu        | Submenu              | Sidetabs         |
      | Dashboard        |                      |                  |
      | Developers       |                      |                  |
      | -                | Accounts             |                  |
      | -                | Messages             |                  |
      | Applications     |                      |                  |
      | API              |                      |                  |
      | -                | Overview             |                  |
      | Developer Portal |                      |                  |
      | -                | Content              |                  |
      | -                | 0 Drafts             |                  |
      | -                | Redirects            |                  |
      | -                | Feature Visibility   |                  |
      | Settings         |                      |                  |
      | -                | General              |                  |
      | -                | Developer Portal     |                  |
      | -                | -                    | Domains & Access |
      | -                | -                    | Spam Protection  |
      | -                | Emails               |                  |
      | -                | -                    | Support Emails   |
      | -                | -                    | Templates        |
      | -                | Legal Terms          |                  |
      | -                | -                    | Signup           |
      | -                | -                    | Application      |
      | -                | Fields Definitions   |                  |

  Scenario: Menu structure with "account_plans" switch allowed
    Given provider "foo.example.com" has "account_plans" switch allowed
    When I go to the provider dashboard
    Then I should have menu
      | Main Menu       | Submenu              | Sidetabs         |
      | Dashboard       |                      |                  |
      | Developers      |                      |                  |
      | -               | Accounts             |                  |
      | -               | Messages             |                  |
      | Applications    |                      |                  |
      | API             |                      |                  |
      | -               | Overview             |                  |
      | -               | Account Plans        |                  |
      | Developer Portal|                      |                  |
      | -               | Content              |                  |
      | -               | 0 Drafts             |                  |
      | -               | Redirects            |                  |
      | -               | Feature Visibility   |                  |
      | Settings        |                      |                  |
      | -               | General              |                  |
      | -               | Developer Portal     |                  |
      | -               | -                    | Domains & Access |
      | -               | -                    | Spam Protection  |
      | -               | Emails               |                  |
      | -               | -                    | Support Emails   |
      | -               | -                    | Templates        |
      | -               | Legal Terms          |                  |
      | -               | -                    | Signup           |
      | -               | -                    | Application      |
      | -               | Fields Definitions   |                  |


    Scenario: With multiple applications enabled
      Given provider "foo.example.com" has multiple applications enabled
      When I go to the provider dashboard
      Then I should have menu
         | Main Menu    | Submenu |
         | Applications |         |
        # WIP - highlighting does not work
#        | -            | All          |
#        | -            | Live         |
#        | -            | Pending      |
#        | -            | Suspended    |

    Scenario: Forum enabled
    Given provider "foo.example.com" has "forum" enabled
     When I go to the provider dashboard
     Then I should have menu
        | Main Menu    | Submenu      |
        | Developers   |              |
        | -            | Forum        |
     Then I should have menu
        | Main Menu    | Submenu          | Sidetabs |
        | Settings     |                  |          |
        | -            | Developer Portal |          |
        | -            | -                | Forum    |


    Scenario: Finance enabled
     Given provider "foo.example.com" is charging
       And provider "foo.example.com" has "finance" switch allowed
      When I go to the provider dashboard
      Then I should have menu
        | Main Menu | Submenu            |
        | Billing   |                    |
        | -         | Invoices           |
        | -         | Earnings by month  |
#       | -         | Log                |
        |           |                    |
        | Settings  |                    |
        | -         | Billing            |
        | -         | Policies           |

    Scenario: Groups enabled
     Given provider "foo.example.com" is charging
       And provider "foo.example.com" has "groups" switch allowed
      When I go to the provider dashboard
      Then I should have menu
        | Main Menu        | Submenu   |
        | Developer Portal |           |
        | -                | Groups    |



    # When XSS protection is enabled we want hide the sidetab XSS protection
    # but this still available.
    #
    # The thing is allow to the old customers activate the XSS protection without
    # broke nothing and hide these option for the rest.
    Scenario: XSS protection options disabled
    Given provider "foo.example.com" has "account_plans" switch allowed
      Given provider "foo.example.com" has xss protection options disabled
      When I go to the provider dashboard
      Then I should have menu
      | Main Menu    | Submenu              | Sidetabs         |
      | Settings     |                      |                  |
      | -            | General              |                  |
      | -            | Developer Portal     |                  |
      | -            | -                    | XSS Protection   |
      | -            | -                    | Domains & Access |
      | -            | -                    | Spam Protection  |


    Scenario: My invoices with finance disabled
      Given provider "foo.example.com" has "finance" switch denied
      When I go to the provider dashboard
       And I follow "Account"
      Then I should see "3scale Invoices"
       And I follow "3scale Invoices"
      Then I should be on my invoices from 3scale page

    Scenario: My invoices with finance enabled
     Given provider "foo.example.com" is charging
       And provider "foo.example.com" has "finance" switch allowed
      When I go to the provider dashboard
       And I follow "Account"
      Then I should see "3scale Invoices"
       And I follow "3scale Invoices"
      Then I should be on my invoices from 3scale page

    Scenario: Multiple services enabled
     Given a service "Another one" of provider "foo.example.com"
     Given provider "foo.example.com" has "multiple_services" switch allowed
      When I go to the provider dashboard
      Then I should have menu
        | Main Menu  | Submenu       |              |
        | APIs       |               |              |
        | -          | Overview      |              |
        |            |               |              |
        | Settings   |               |              |
        | -          | Legal Terms   |              |
        | -          | -             | Subscription |
        |            |               |              |
        | Analytics  |               |              |
        | -          | Alerts        |              |

    Scenario: Service plans
     Given a service "Another one" of provider "foo.example.com"
       And provider "foo.example.com" has "service_plans" switch allowed
      When I go to the provider dashboard
      Then I should have menu
        | Main Menu  | Submenu       |
        | Developers |               |
        | -          | Subscriptions |


  # Legacy scenarios
  #
  Scenario: Navigate to End Users
    Given an end user plan "First" of provider "foo.example.com"
      And current domain is the admin domain of provider "foo.example.com"
    Given I am logged in as provider "foo.example.com"
      And provider "foo.example.com" has "end_users" switch allowed
    When I am on the edit page for service "API" of provider "foo.example.com"
     And I follow "End-users"
    Then I should be on the end users of service "API" page of provider "foo.example.com"

  @wip
  Scenario: Stats
    Given a buyer "bob" of provider "foo.example.com"
      And buyer "bob" has application "Lumberjack"
     When I follow "Accounts"
      And I follow "bob"
      And I follow "More details" in the applications widget
      And I follow "Stats" in the subsubmenu
     Then I should see "Usage"
