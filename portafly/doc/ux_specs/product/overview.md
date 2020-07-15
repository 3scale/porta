# Product overview

[Back to index](../index.md)

* [Mockups](https://marvelapp.com/prototype/ee82j74/screen/70939434)
* [Mockups JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4389)
* [Parent JIRA ticket](https://issues.redhat.com/browse/THREESCALE-4197)

##### Page header
* Edit button
  * Secondary button
* Delete button
  * Customized button (A secondary button to resemble a destructive button)

#### Delete modal ([specs](../global_components/modal.md))
* Modal's title will include the name of the current Product the user is trying to delete
* Enter product name > text input field [required]
  * Validation error:
    * Wrong product name on _onblur_
* Buttons
  * Delete button [Disabled state until all conditions required to submit the form are met]
    * Primary danger button variant
    * Submits form
  * Cancel button [Always enabled]
    * Dismisses modal
