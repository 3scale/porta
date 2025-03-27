@javascript
Feature: Email templates management
  In order to have really good CRM
  As a provider
  I want to modify content of email templates

  Background:
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has "skip_email_engagement_footer" switch visible
    And I log in as "foo.3scale.localhost" on the admin domain of provider "foo.3scale.localhost"

  Scenario: Creating template
    When I go to the email templates page
    And I follow "Buyer Account approved"
    Then I should see default content of email template "account_approved"

    When I fill in the draft with "new content for account approved"
    And I fill the form with following:
      | Subject | Bcc | Cc | From |
      | subj3ct | dcc | c! | strange@3scale.localhost |
    And I press "Create Email Template"
    Then I should see "Bcc is an invalid email address"
    Then I should see "Cc is an invalid email address"
    Then I should see "From does not match the domain of your outbound email"
    And I fill the form with following:
      | Subject | Bcc            | Cc                            | From       |
      | subj3ct | some@email.com | "Example" <other@3scale.localhost> | My Company |
    And I press "Create Email Template"
    Then I should see "Email Template overrided"
    And the content of the email template "account_approved" should be
      """
      new content for account approved
      """
    And the headers of email template "account_approved" should be following:
      | subject | bcc | cc |
      | subj3ct | some@email.com | "Example" <other@3scale.localhost> |

  Scenario: Updating template
    When I have following email template of provider "foo.3scale.localhost":
      | System Name      |
      | account_approved |
    When I log in as "foo.3scale.localhost" on the admin domain of provider "foo.3scale.localhost"

    When I go to the email templates page
    And I follow "Buyer Account approved"
    And I fill the form with following:
      | Subject | Bcc | Cc |
      | subj3ct | bcc@3scale.localhost | cc@3scale.localhost |
    And I press "Save"
    Then I should see "Template updated"
    And the headers of email template "account_approved" should be following:
      | subject | bcc | cc |
      | subj3ct | bcc@3scale.localhost | cc@3scale.localhost |

  Scenario: New signup email template
    Given admin of account "foo.3scale.localhost" has email "foo@3scale.localhost"
      And all the rolling updates features are off

    When I go to the email templates page
     And I follow "Sign up notification for buyer"
     And I fill the form with following:
      | Bcc          | From |
      | test@bcc.com | "Some Really Long String" <api@example.com> |
     And I fill in the draft with:
      """
      Email: {{user.email}}
      Org: {{account.name}}
      """
    When I press "Create Email Template"

    When buyer "bob" with email "bob@mail.com" signs up to provider "foo.3scale.localhost"
     And "test@bcc.com" opens the email with subject "foo.3scale.localhost API account confirmation"

    Then I should see following email body
      """
      Email: bob@mail.com
      Org: bob
      """

    When I follow "Sign up notification for buyer"
     And I fill in the draft with:
      """
      {% email %}
        {% bcc 'bcc@mail.com' %}
        {% subject 'Overriden' %}
      {% endemail %}
      Email: {{user.email}}
      Org: {{account.name}}
      """
    When I press "Save"

    When buyer "steve" with email "steve@mail.com" signs up to provider "foo.3scale.localhost"
    And "bcc@mail.com" opens the email with subject "Overriden"

    Then I should see following email body
      """
      Email: steve@mail.com
      Org: steve
      """
    Then I should see the email delivered from "Some Really Long String <api@example.com>"
