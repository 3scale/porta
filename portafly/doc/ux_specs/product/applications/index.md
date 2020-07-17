# Product > Applications index

[Back to index](../../index.md)

* [Mockups](https://marvelapp.com/ee82j74/screen/70440629)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4693)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4214)

##### Page header
* Create button
  * Primary button

##### Toolbar ([specs](../../global_components/toolbar.md))
* Filters:
  * Name > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * State > Dropdown menu with multi-select checklist ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input))
     * "Live"
     * "Pending"
     * "Suspended"
  * Account > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Plan > Dropdown menu with multi-select checklist ([PF specs](https://www.patternfly.org/v4/documentation/react/components/select#checkbox-input))
     * dropdown menu content depends on users application plans

##### Table ([PF specs](https://www.patternfly.org/v4/documentation/react/components/table))
* Table columns distribution rule:
  * cellWidth(20)
  * cellWidth(20)
  * cellWidth(30)
  * cellWidth(15)
  * cellWidth(15)
* Table header:
  * Application name [sortable]
  * Account [sortable]
  * Plan [sortable]
  * Created on [sortable -- ordered descending by default]
  * State [sortable]
* State column labels:
  * "Live" = 'blue'
  * "Pending" = 'orange'
  * "Suspended" = 'red'
