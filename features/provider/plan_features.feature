@javascript
Feature: Application, service and account plan Features

  Background:
    Given a provider is logged in
    And a product "My API"
    And the provider has "service_plans" allowed
    And the provider has "account_plans" allowed
    And the following application plan:
      | Product | Name |
      | My API  | Free |
    And the following account plan:
      | Issuer               | Name |
      | foo.3scale.localhost | Free |
    And the following service plan:
      | Product | Name |
      | My API  | Free |

  Scenario Outline: Navigation
    Given they go to <index plans page>
    When they follow "Free" within the table
    Then the current page is <plan> admin edit page

    Examples:
      | index plans page                           | plan                    |
      | the product's application plans admin page | application plan "Free" |
      | product "My API" service plans admin page  | service plan "Free"     |
      | the account plans admin page               | account plan "Free"     |

  Scenario Outline: Edit a plan without billing enabled
    Given they go to <plan> admin edit page
    And there is no field "Trial Period (days)"
    And there is no field "Setup free"
    And there is no field "Cost per month"
    # FIXME: should be "readonly", but the input would have to be updated
    And field "System name" is disabled
    When the form is submitted with:
      | Name | Still free |
    Then the current page is <index plans page>
    # And they should see "Plan was updated" FIXME: #edit method doesn't call flash[notice]
    And the table has the following row:
      | Name       |
      | Still free |

    Examples:
      | index plans page                           | plan                    |
      | the product's application plans admin page | application plan "Free" |
      | product "My API" service plans admin page  | service plan "Free"     |
      | the account plans admin page               | account plan "Free"     |

  Scenario Outline: Edit a plan with billing enabled
    # See app/views/api/plans/forms/_billing_strategy.html.erb
    Given the provider is charging its buyers
    And they go to <plan> admin edit page
    When the form is submitted with:
      | Name                | Not free anymore |
      | Trial Period (days) | 7                |
      | Setup fee           | 100              |
      | Cost per month      | 10               |
    Then the current page is <index plans page>
    # And they should see "Plan was updated" FIXME: #edit method doesn't call flash[notice]
    And the table has the following row:
      | Name             |
      | Not free anymore |

    Examples:
      | index plans page                           | plan                    |
      | the product's application plans admin page | application plan "Free" |
      | product "My API" service plans admin page  | service plan "Free"     |
      | the account plans admin page               | account plan "Free"     |

  Scenario Outline: Adding a new plan feature
    Given they go to <plan> admin edit page
    When they follow "New feature"
    And the modal is submitted with:
      | Name        | Free T-shirt                               |
      | System name | free-tee                                   |
      | Description | T-shirt with logo of our company for free. |
    Then they should see the flash message "Feature has been created."
    And should see the following table within the features:
      | Name         | Description                                |
      | Free T-shirt | T-shirt with logo of our company for free. |

    Examples:
      | plan                    |
      | application plan "Free" |
      | service plan "Free"     |
      | account plan "Free"     |

  @wip
  Scenario Outline: Form validation

  Scenario Outline: Plan with no features
    Given <plan> does not have any features
    When they go to <plan> admin edit page
    Then they should see "This plan has no features yet." within the features

    Examples:
      | plan                    |
      | application plan "Free" |
      | service plan "Free"     |
      | account plan "Free"     |

  Scenario Outline: Disabling plan features
    Given <plan> has the following features:
      | Name         | Enabled? |
      | Some Feature | True     |
    And they go to <plan> admin edit page
    When they disable feature "Some Feature"
    Then they should see the flash message "Feature has been disabled."

    Examples:
      | plan                    |
      | application plan "Free" |
      | service plan "Free"     |
      | account plan "Free"     |

  Scenario Outline: Enabling plan features
    Given <plan> has the following features:
      | Name         | Enabled? |
      | Some Feature | False    |
    And they go to <plan> admin edit page
    When they enable feature "Some Feature"
    Then they should see the flash message "Feature has been enabled."

    Examples:
      | plan                    |
      | application plan "Free" |
      | service plan "Free"     |
      | account plan "Free"     |

  Scenario Outline: Editting plan features
    Given <plan> has the following features:
      | Name         | Description |
      | Some Feature | Bananas     |
    And they go to <plan> admin edit page
    When they follow "Edit" that belongs to feature "Some Feature"
    And the modal is submitted with:
      | Name | New name |
    Then they should see the flash message "Feature has been updated."
    And should see the following table within the features:
      | Name     | Description |
      | New name | Bananas     |

    Examples:
      | plan                    |
      | application plan "Free" |
      | service plan "Free"     |
      | account plan "Free"     |

  Scenario Outline: Deleting plan features
    Given <plan> has the following features:
      | Name         | Description |
      | Some Feature | Bananas     |
    And they go to <plan> admin edit page
    When they press "Delete" that belongs to feature "Some Feature"
    And confirm the dialog
    Then they should see the flash message "Feature has been deleted."
    And should not see "Some Features" within the features

    Examples:
      | plan                    |
      | application plan "Free" |
      | service plan "Free"     |
      | account plan "Free"     |
