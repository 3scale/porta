# Accounts index

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/55343de/screen/67190788)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4725)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4724)

##### Page header
* Export button
  * Secondary button
* Create button
  * Primary button

##### Toolbar ([specs](../global_components/toolbar.md))
<!-- * Bulk actions:
  * Send email
  * Change state -->
* Filters:
  * Group/org > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Admin > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * State > Dropdown menu with multi-select checklist ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input))
     * "Approved"
     * "Pending"
     * "Rejected"
     * "Suspended"
  <!-- * Plan > Dropdown menu with multi-select checklist ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input)) -- with filter when many options are available ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#grouped-checkbox-input-with-filtering))
     * list of current plans -->

##### Table ([PF specs](https://www.patternfly.org/v4/documentation/react/components/table))
* Table columns distribution rule:
  * cellWidth(25)
  * cellWidth(30)
  * cellWidth(15)
  * cellWidth(15)
* Table header:
  * Group/organization [sortable]
  * Admin [sortable]
  * Signup date [sortable]
  * Applications [sortable] -- not doable for v1
  * State [sortable]
  <!-- * Actions -->
<!-- * Table rows include a checkbox -->
<!-- * Action column values:
  * Approve
    * Icon is `check`
  * Activate
    * Icon is `play-circle`
  * [MASTER] Act as
    * Icon is `bolt` -->

<!-- ##### Modals -->
<!-- * Send email modal ([specs](../../global_components/modal.md))
  * Listed items:
    * format of the string: {{admin_name}} ({{account_name}})
    * one item = one admin user -->

<!-- * Change state modal ([specs](../../global_components/modal.md))
  * Listed items:
    * format of the string: {{account_name}} ({{state}})
    * one item = one account
  * Select state input field includes helper text -->
