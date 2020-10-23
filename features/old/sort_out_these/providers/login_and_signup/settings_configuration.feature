Feature: Settings Configuration
  In order configure the information a user sees about support
  As a provider
  I want to set email addresses and text about support information

  @wip
  Scenario: Provider Keys disabled
    Given a provider "foo.3scale.localhost"
    And provider "foo.3scale.localhost" has billing enabled
    And current domain is the admin domain of provider "foo.3scale.localhost"
    And I log in as provider "foo.3scale.localhost"
    And I go to the provider support page
    Then I should see "Edit Support Details"

    When I fill in "Technical support email address" with "tech@foo.3scale.localhost"
    And I fill in "Administrative support email address" with "admin@foo.3scale.localhost"
    And I fill in "Who should be emailed, to change credit card details" with "credit@foo.3scale.localhost"
    And I fill in "Contact and Support Information" with "We love to help"
    And I press "Save"
    Then I should see "Service information was updated"
    And I should be on the provider support page
    When I am on the master domain
    When the current domain is foo.example
    And I am on the support page
    Then I should see "admin@foo.3scale.localhost"
    And I should see "tech@foo.3scale.localhost"
    And I should see "We love to help"


    # if looking at invoices pages should see administrative email address or admin email

    # email to 3sprovider with these parametres signed up
    # paid: switch on provider side: billing, not payment.

    # support email as well for invoice


    # provider side, looking at individ user, box showing properties of contract, not flushed. does not include setup cost
