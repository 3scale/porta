@javascript
Feature: Context selector

  As a user, I want to be able to switch between the different contexts of 3scale in an easy and
  quick way

  Background:
    Given a provider

  Rule: User is an admin
    Background:
      Given an admin user "Admin" of the provider
      And the user logs in

    Scenario: Admin sees all contexts
      Given they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Audience         |
        | Products         |
        | Backends         |
        | Account Settings |

  Rule: User is a member
    Background:
      Given a member user "Member" of the provider
      And the user logs in

    Scenario: Member with no permissions can't see Audience, Services and Backends
      Given the user has no permissions
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Account Settings |

    Scenario: Member with portal permission can see Audience
      Given the user has portal permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Audience         |
        | Account Settings |

    @wip
    Scenario: Member with finance permission can see Audience
      Given the user has finance permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Audience         |
        | Account Settings |

    Scenario: Member with settings permission can see Audience
      Given the user has settings permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Audience         |
        | Account Settings |

    Scenario: Member with partners permission can't see backends
      Given the user has partners permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Audience         |
        | Products         |
        | Account Settings |

    Scenario: Member with monitoring permission can see Products and Backends
      Given the user has monitoring permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Products         |
        | Backends         |
        | Account Settings |

    Scenario: Member with plans permission can see Products and Backends
      Given the user has plans permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Products         |
        | Backends         |
        | Account Settings |

    Scenario: Member with policy registry permission can see Products
      Given the user has policy_registry permission
      When they go to the provider dashboard
      Then the current context should be "Dashboard"
      And they should be able to navigate to the following contexts:
        | Dashboard        |
        | Products         |
        | Account Settings |
