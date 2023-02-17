interface InjectedJQuery {
  flash: {
    notice: (msg: string) => void;
    error: (msg: string) => void;
  };
}

// @ts-expect-error HACK: flash is a function injected in the global $ (see app/assets/javascripts/flash.js).
// We use the custom type here, instead of in globals.d.ts, to encapsulate all flash usage within this module.
const { flash } = window.$ as InjectedJQuery

export const notice = (msg: string): void => { flash.notice(msg) }
export const error = (msg: string): void => { flash.error(msg) }
