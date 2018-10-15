// TODO: This will be replace once we implement full PF4
import $ from 'jquery'

const toggleableContentClass = '.u-toggleable'
const toggleEnabledClass = 'is-toggled'
const toggleableElement = '.u-toggler'
const allToggleableElements = `${toggleableContentClass}, ${toggleableElement}`

function hideAllToggleable (selector = allToggleableElements) {
  $(selector).toggleClass(toggleEnabledClass, false)
}

function toggleElements ($elements, klass = toggleEnabledClass, state) {
  $elements.forEach($element => $element.toggleClass(klass, state))
}

function focusSearchInput ($element) {
  $element.find('input').filter(':visible:first').focus()
}

function toggleNavigation (element) {
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
