Feature: Signup using Cas
  As a new account
  I should not rage

  Background:
    Given a provider "foo.example.com" with default plans
      And provider "foo.example.com" uses Cas authentication
      And an application plan "iRage" of service "default"
      And application plan "iRage" is default

    Given the current domain is foo.example.com

  Scenario: Signup with Internal
    When I go to the sign up page
    Then I should see "Login with CAS"
    And fields should be required:
      | Username                |
      | Password                |
      | Organization/Group Name |

    And I should see the password field

    When I fill in the following:
      | Email                   | luis@mamacit.as  |
      | Username                | luis             |
      | Organization/Group Name | Planet MamacitAS |
      | Password                | qwerty           |
      | Password confirmation   | qwerty           |

   And I press "Sign up"
   Then I should see the registration succeeded

   When the user "luis" is activated
   And I try to log in as "luis" with password "qwerty"
   Then I should be logged in as "luis"

  Scenario: Signup with Cas
    When I have a cas token in my session
    And I go to the sign up page
    Then fields should be required:
      | user fields           |
      | Username              |

    And I should see "Please continue the signup process below."

    And fields should be required:
      | account fields          |
      | Organization/Group Name |

   When I press "Sign up"
   Then I should see error in fields:
      | user errors             |
      | Username                |
      | Email                   |

    And I should see error in fields:
      | account errors          |
      | Organization/Group Name |

    And I should not see the password field

   When I fill in the following:
      | Email                   | office@mamacit.as |
      | Username                | armstrong         |
      | Organization/Group Name | Planet MamacitAS  |

    And I press "Sign up"

   Then I should see the registration succeeded

   When I try to log in as "armstrong" with password ""
   Then I should not be logged in
    And I should see "Incorrect email or password. Please try again."
