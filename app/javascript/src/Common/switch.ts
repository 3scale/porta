/**
 * Support JS logic for switches. See app/helpers/switch_helper.rb
 */

window.ThreeScale.enableSwitch = function (selector: string) {
  $(`${selector} .disabled_block`).fadeOut(() => {
    $(`${selector} .enabled_block`).fadeIn()
  })
}

window.ThreeScale.disableSwitch = function (selector: string) {
  $(`${selector} .enabled_block`).fadeOut(() => {
    $(`${selector} .disabled_block`).fadeIn()
  })
}
