# Modals UX/UI specs

* [PatternFly Modal dialog design guidelines](https://www.patternfly.org/v4/design-guidelines/usage-and-behavior/modal)
* [PatternFly-react Modal docs](https://www.patternfly.org/v4/documentation/react/components/modal)

### _'Send email to selected items'_ modal
* Form ([PF specs](https://www.patternfly.org/v4/documentation/react/components/form))
  * List of selected items > unordered list ([PF specs](https://www.patternfly.org/v4/documentation/react/components/list))
    * Items are displayed in alphabetical order
    * When the list of selected items is bigger than 5 items, only the first 5 will be displayed
      * also, a button will be displayed at the bottom of the list to trigger display of the remaining items
    * When the full list is displayed, the height of the container will be fixed and the content will be scrollable so that the entire dialog can still be seen above the fold
  * Subject field > text input ([PF specs](https://www.patternfly.org/v4/documentation/react/components/textinput))
    * mandatory field
  * Message field > text area ([PF specs](https://www.patternfly.org/v4/documentation/react/components/textarea))
    * mandatory field
  * Buttons:
    * Submit button [Disabled state until all conditions required to submit the form are met]
    * Cancel button [Always enabled]
      * Dismisses modal


### _'Change plan for selected items'_ modal
* Form ([PF specs](https://www.patternfly.org/v4/documentation/react/components/form))
  * List of selected items > unordered list ([PF specs](https://www.patternfly.org/v4/documentation/react/components/list))
    * Items are displayed in alphabetical order
    * When the list of selected items is bigger than 5 items, only the first 5 will be displayed
      * also, a button will be displayed at the bottom of the list to trigger display of the remaining items
    * When the full list is displayed, the height of the container will be fixed and the content will be scrollable so that the entire dialog can still be seen above the fold
  * Select plan field > dropdown ([PF specs](https://www.patternfly.org/v4/documentation/react/components/dropdown))
    * mandatory field
  * Buttons:
    * Submit button [Disabled state until all conditions required to submit the form are met]
    * Cancel button [Always enabled]
      * Dismisses modal


### _'Change state for selected items'_ modal
* Form ([PF specs](https://www.patternfly.org/v4/documentation/react/components/form))
  * List of selected items > unordered list ([PF specs](https://www.patternfly.org/v4/documentation/react/components/list))
    * Items are displayed in alphabetical order
    * When the list of selected items is bigger than 5 items, only the first 5 will be displayed
      * also, a button will be displayed at the bottom of the list to trigger display of the remaining items
    * When the full list is displayed, the height of the container will be fixed and the content will be scrollable so that the entire dialog can still be seen above the fold
  * Select state field > dropdown ([PF specs](https://www.patternfly.org/v4/documentation/react/components/dropdown))
    * mandatory field
  * Buttons:
    * Submit button [Disabled state until all conditions required to submit the form are met]
    * Cancel button [Always enabled]
      * Dismisses modal
