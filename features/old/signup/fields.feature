#TODO finish this, not all cases are covered
Feature: Signup with defined fields
  In order to have an awesome signup
  As a new account
  I want to sign up with defined fields

  Background:
    Given a provider "foo.3scale.localhost" with default plans
    Given provider "foo.3scale.localhost" has the following fields defined for accounts:
      | name                      | required | read_only | hidden |
      | account_extra_required    | true     |           |        |
      | account_extra_read_only   |          | true      |        |
      | account_extra_hidden      |          |           | true   |

    Given provider "foo.3scale.localhost" has the following fields defined for users:
      | name                  | required | read_only | hidden |
      | user_extra_required   | true     |           |        |
      | user_extra_read_only  |          | true      |        |
      | user_extra_hidden     |          |           | true   |

    Given the current domain is foo.3scale.localhost


  Scenario: Required fields on signup
    When I go to the sign up page
    Then fields are required:
      | user fields           |
      | Username              |
      | Password              |
      | Password confirmation |
      | User extra required   |

    And fields are required:
      | account fields          |
      | Organization/Group Name |
      | Account extra required  |

    And I should not see the fields:
      | hidden fields           |
      | User extra read only    |
      | User extra hidden       |
      | Account extra read only |
      | Account extra hidden    |

    When I press "Sign up"
    Then I should see error in fields:
      | user errors             |
      | Username                |
      | Email                   |
      | Password                |
      | User extra required     |

    And I should see error in fields:
      | account errors          |
      | Organization/Group Name |
      | Account extra required  |

   When I fill in the following:
      | Email                   | bender@planet.ex |
      | Username                | bender           |
      | Password                | superSecret1234#      |
      | Password confirmation   | superSecret1234#      |
      | User extra required     | MustBe           |
      | Organization/Group Name | Planet eXpress   |
      | Account extra required  | foo              |

      And I press "Sign up"
   Then I should see the registration succeeded
