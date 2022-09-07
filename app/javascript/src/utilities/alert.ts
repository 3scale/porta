// HACK: our flash handler is injected in the global $ in app/assets/javascripts/flash.js
export const notice = (msg: string): void => window.$.flash.notice(msg);
export const error = (msg: string): void => window.$.flash.error(msg)
