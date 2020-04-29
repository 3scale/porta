# Audience > Accounts > Listing

* [Mockups](https://marvelapp.com/55343de/screen/67190788)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4725)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4724)

##### Toolbar ([specs](../../global_components/toolbar.md))
* Bulk actions:
  * Send email
  * Change account
  * Change state
* Filters:
  * Group/org > text input ([specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Admin > text input ([specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * State > Dropdown menu with checklist ([specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input))
     * "Approved"
     * "Pending"
     * "Rejected"
     * "Suspended"
  * Plan > Dropdown menu with checklist ([specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input)), with filter when many options are available ([specs](https://www.patternfly.org/v4/documentation/react/components/select#grouped-checkbox-input-with-filtering))
     * list of current plans
