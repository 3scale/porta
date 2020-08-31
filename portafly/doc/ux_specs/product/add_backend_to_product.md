# Add backend to product

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/693i10c/screen/72209377)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/APPDUX-409 )
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-5780)

##### Page header
* Title:
  * Title include a `pf-icon-help` icon
  * Icon toggles a popover ([PF specs](https://www.patternfly.org/v4/documentation/react/components/popover))
  * Popover includes content to explain users what the page is about:
    1. At least one backend is needed for a product to work
    2. When adding two or more backends, a unique public path for backends should be specified
* Add backend button
  * Primary button

##### Toolbar ([specs](../global_components/toolbar.md))
* Filters:
  * Backend name > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Private base URL > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))
  * Public path > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/inputgroup#with-dropdown))

##### Table ([PF specs](https://www.patternfly.org/v4/documentation/react/components/table))
* Table columns distribution rule:
  * cellWidth(20)
  * cellWidth(30)
  * cellWidth(20)
  * cellWidth(25)
* Table header:
  * Backend name [sortable]
  * Private base URL [sortable]
  * Public path [sortable]
  * Actions
* Actions buttons:
  * Edit button
    * Link button
    * Icon is `fa-pencil-alt`
    * Triggers in-line edit state
  * Remove button
    * Destructive link button
    * Icon is `fa-minus-circle`
    * Triggers backend removal confirmation modal
* In-line edit ([PF specs](https://www.patternfly.org/v4/documentation/react/components/table#editable-rows))
  * Input fields
    * Backend name [disabled] > text input
    * Private base URL > text input
    * Public path > text input
  * Buttons:
    * Save button
      * Link button style
      * Icon is `fa-check`
      * Submits the form
    * Cancel button
      * Link button style
      * Icon is `fa-times`
      * Dismisses edit state

##### 'Removal confirmation' modal
* Buttons
  * Remove button
    * Primary destructive style
    * Submits the removal action
  * Cancel button
    * Link button style
    * Dismisses modal

##### 'Add new backend to product' form
* Input fields
  * Backend [required] > select single with typeahead ([PF specs](https://www.patternfly.org/v4/documentation/core/components/select#single-with-typeahead))
  * Path > text input with helper text
* Buttons
  * Add to product button
    * Primary button style
    * Submits form
  * Cancel button
    * Link button style
    * Leads back to previous page
  * Create new backend button
    * Link button style
    * Leads to Create backend page

#### Toast alerts ([PF specs](https://www.patternfly.org/v4/documentation/react/components/alert#variations))
* Addition successful
  * Variant is `success`
  * Action link
    * Leads to APIcast configuration page
* Addition failure
  * Variant is `danger`
  * ?
* Edit successful
  * Variant is `success`
  * Action link
    * Leads to APIcast configuration page
* Edit validation error
  * Variant is `danger`
* Removal successful
  * Variant is `success`
  * Action link
    * Leads to APIcast configuration page
* Removal failure
  * Variant is `danger`
  * ?
