Feature: Create invoice
  In order to add custom charges even thought there is none from the system
  As a provider
  I want to be able to create an invoice on demand

 Background:
  Given a provider "foo.example.com" with prepaid billing enabled
    And an application plan "Fixed" of provider "foo.example.com" for 0 monthly
    And a buyer "zoidberg" signed up to application plan "Fixed"

 @javascript @alert
 Scenario: Create and view the invoice
   When current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"
    And go to the invoices of account "zoidberg" page
   Then I should not see "open"

   When the date is 1st January 2009
    And I follow "Create invoice"
   Then I should see "Invoice successfully created"
    And I should see "open"
   Then I follow "Create invoice" and I confirm dialog box "You cannot create a new invoice for 'zoidberg' since it already has one open. Please issue it before creating a new one."


   When I follow "Show"
   Then I should see "Invoice for January 2009"
