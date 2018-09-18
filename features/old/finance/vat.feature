Feature: Billing with VAT
  In order to allow different VAT rates for buyers
  I want to edit them and see them affecting invoice costs

Background:
  Given a provider "foo.example.com" with billing enabled
    Given provider "foo.example.com" has "finance" switch visible
    And an application plan "best" of provider "foo.example.com" for 100 monthly

  Scenario: Buyer sees no VAT on an invoice by default
    Given the time is 31st December 2008
    And a buyer "tycoon" signed up to application plan "best"
    And time flies to 3rd February 2009

    When I log in as "tycoon" on foo.example.com
    And I navigate to invoice issued for me in "January, 2009"
    Then I should see line items
    | name                         | quantity | cost |
    | Fixed fee ('best')           |          |  100 |
    | Total cost                   |          |  100 |

  Scenario: Buyer sees the VAT on an invoice
   Given the time is 31st December 2008
     And a buyer "tycoon" signed up to application plan "best"
     And VAT rate of buyer "tycoon" is 5%
     And time flies to 3rd February 2009
    When I log in as "tycoon" on foo.example.com
     And I navigate to invoice issued for me in "January, 2009"
    Then I should see line items
        | name                         | quantity | cost |
        | Fixed fee ('best')           |          |  100 |
        | Total cost (without VAT)     |          |  100 |
        | Total VAT Amount             |          |    5 |
        | Total cost (VAT 5% included) |          |  105 |

  Scenario: Buyer sees the VAT on an invoice when it's 0
    Given the time is 31st December 2008
    And a buyer "tycoon" signed up to application plan "best"
    And VAT rate of buyer "tycoon" is 0%
    And time flies to 3rd February 2009

    When I log in as "tycoon" on foo.example.com
    And I navigate to invoice issued for me in "January, 2009"
    Then I should see line items
    | name                         | quantity | cost |
    | Fixed fee ('best')           |          |  100 |
    | Total cost (without VAT)     |          |  100 |
    | Total VAT Amount             |          |    0 |
    | Total cost (VAT 5% included) |          |  100 |

  Scenario: Sums on dashboard are VAT sensitive
   Given a buyer "europe" signed up to application plan "best"
     And VAT rate of buyer "europe" is 5%
     And an invoice of buyer "europe" for May, 1945 with items
     | name       | description         | cost |
     | Liberation | started in Normandy |  100 |

    And current domain is the admin domain of provider "foo.example.com"
    And I log in as provider "foo.example.com"

     And I go to the invoices by months page
     Then I should have an invoice of "105.0 EUR"
    # TODO: Then should see the following table:
