// TODO: This will be replace once we implement full PF4
import $ from 'jquery'

const toggleableContentClass = '.u-toggleable'
const toggleEnabledClass = 'is-toggled'
const toggleableElement = '.u-toggler'
const allToggleableElements = `${toggleableContentClass}, ${toggleableElement}`

function hideAllToggleable (selector = allToggleableElements): void {
  $(selector).toggleClass(toggleEnabledClass, false)
}

// eslint-disable-next-line @typescript-eslint/default-param-last -- Ignoring this because it's gonna be deleted
function toggleElements ($elements: JQuery<EventTarget>[], className = toggleEnabledClass, state: boolean): void {
  for (const element of $elements) {
    element.toggleClass(className, state)
  }
}

function focusSearchInput ($element: JQuery<EventTarget>) {
  $element.find('input').filter(':visible:first').focus()
}

function toggleNavigation (element: EventTarget): void {
  const $element = $(element)
  const $list = $element.siblings(toggleableContentClass)
  const state = $list.hasClass(toggleEnabledClass)
  hideAllToggleable()
  toggleElements([$list, $element], toggleEnabledClass, !state)
  focusSearchInput($list)
}

export {
  toggleNavigation,
  hideAllToggleable
}
