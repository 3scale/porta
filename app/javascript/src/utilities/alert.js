// @flow

// HACK: our flash handler is injected in the global $ in app/assets/javascripts/flash.js
export const notice = window.$.flash.notice
export const error = window.$.flash.error
