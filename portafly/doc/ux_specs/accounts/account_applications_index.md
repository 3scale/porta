# Account > Applications index

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/55343de/screen/70849844)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5423)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5422)

##### Page header
* Create Application button
  * Primary button
* Tabs:
  * Overview
  * Applications [selected]

##### Toolbar ([specs](../global_components/toolbar.md))
* Filters:
  * Name > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Product > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Plan > Dropdown menu with multi-select checklist ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input))
     * dropdown menu content depends on users application plans
  * State > Dropdown menu with multi-select checklist ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input))
    * "Live"
    * "Pending"
    * "Suspended"

##### Table ([PF specs](https://www.patternfly.org/v4/documentation/react/components/table))
* Table columns distribution rule:
  * cellWidth(20)
  * cellWidth(20)
  * cellWidth(30)
  * cellWidth(15)
  * cellWidth(15)
* Table header:
  * Application name [sortable]
  * Product [sortable]
  * Plan [sortable]
  * Created on [sortable -- ordered descending by default]
  * State [sortable]
* State column labels:
  * "Live" = 'blue'
  * "Pending" = 'orange'
  * "Suspended" = 'red'
