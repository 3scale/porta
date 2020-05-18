# Toolbar UX/UI specs

[Back to index](../index.md)

* [PatternFly Toolbar design guidelines](https://www.patternfly.org/v4/design-guidelines/usage-and-behavior/toolbar)
* [PatternFly-react Toolbar demo](https://www.patternfly.org/v4/documentation/react/demos/toolbardemo)
* [AppDev Toolbar design convention guidelines](https://docs.google.com/presentation/d/1kZUJl1Pyt2aTmRLQ5OzaW_Wb9A-dUm7-hppARaTXyhs/edit?usp=sharing)

### Bulk selection ([guidelines](https://www.patternfly.org/v4/design-guidelines/usage-and-behavior/bulk-selection), [demo](https://www.patternfly.org/v4/documentation/react/demos/bulkselecttable))
##### Bulk select split dropdown button ([specs](https://www.patternfly.org/v4/documentation/react/components/dropdown#split-button-with-text))
* Bulk selection options will be the same across all occurrences:
  * Select none
  * Select page
  * Select all

##### Bulk actions primary toggle ([specs](https://www.patternfly.org/v4/documentation/react/components/dropdown#primary-toggle))
* Bulk actions:
  * depend on the context [please check page specs for specific bulk actions]
* When no items are selected:
  * it will still be possible to trigger the dropdown menu
  * the dropdown menu will feature a message on top informing the user that a selection is mandatory to enable the bulk actions
  * Bulk actions will be listed, but they will be disabled

### Filter group ([guidelines](https://www.patternfly.org/v4/design-guidelines/usage-and-behavior/filters), [demo](https://www.patternfly.org/v4/documentation/react/demos/filtertabledemo))
* Filters:
  * context dependant (please check specific page specs for filtering options)
* When at least one filter is selected, a new Chip group will be added in a second row of the toolbar
  * [Chip group specs](https://www.patternfly.org/v4/documentation/react/components/chipgroup)

### Pagination ([guidelines](https://www.patternfly.org/v4/design-guidelines/usage-and-behavior/pagination), [specs](https://www.patternfly.org/v4/documentation/react/components/pagination))
* Pagination is only enabled when there is more than one page available
* Pagination is compact when less than two pages are available
* Pagination is standard when more than two pages are available
* Pagination options will be the same across all occurrences:
  * 5 per page
  * 10 per page
  * 20 per page
  * 30 per page
