@javascript @ignore-backend
 Feature: Create application
   In order to control the way my buyers are using my API
   As a provider
   I want to create their applications

   Background:
     Given a provider "foo.3scale.localhost"
     And provider "foo.3scale.localhost" uses backend v2 in his default service
     And provider "foo.3scale.localhost" has multiple applications enabled
     And provider "foo.3scale.localhost" has "service_plans" switch allowed
     And a default application plan "Basic" of provider "foo.3scale.localhost"
     And plan "Basic" is published
     And a buyer "bob" signed up to provider "foo.3scale.localhost"
     And buyer "bob" is subscribed to the default service of provider "foo.3scale.localhost"
     And current domain is the admin domain of provider "foo.3scale.localhost"
     And I log in as provider "foo.3scale.localhost"

   Scenario: Edit an application should validate the fields
      Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
      And I go to the buyer account page for "bob"
      And I follow "UltraWidget" within "#applications_widget"
      And I follow "Edit"
      Then I should see "Edit application: UltraWidget"
      When I fill in "Name" with ""
      And I press "Update Application"
      And should see "can't be blank"

   Scenario: Edit an application
     Given buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
     And I go to the buyer account page for "bob"
     And I follow "UltraWidget" within "#applications_widget"
     And I follow "Edit"
     Then I should see "Edit application: UltraWidget"
     When I fill in "Name" with "Not So Ultra Widget"
     And I press "Update Application"
     Then I should see "Application was successfully updated"
     And I should be on the provider side "Not So Ultra Widget" application page
     And I should see "Not So Ultra Widget" in a header

   # TODO: also in single app mode
   Scenario: Edit an application with extra fields
     Given provider "foo.3scale.localhost" has the following fields defined for "Cinstance":
       | name                | required | read_only | hidden |
       | app_extra_required  | true     |           |        |
       | app_extra_read_only |          | true      |        |
       | app_extra_hidden    |          |           | true   |

       And buyer "bob" has application "UltraWidget" with description "Slightly less awesome widget"
       And I go to the provider side edit page for application "UltraWidget" of buyer "bob"
     When I fill in "Name" with "Not So Ultra Widget"
     When I fill in "App extra hidden" with "hidden but not for provider"
       And I press "Update Application"
     Then I should see "Application was successfully updated"
       And I should not see error in fields:
       | errors             |
       | App extra required |

     Then I should see "Not So Ultra Widget"
       And I should see "hidden but not for provider" in the "App extra hidden" field
