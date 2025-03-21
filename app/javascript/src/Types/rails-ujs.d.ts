/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/naming-convention */
/**
 * IMPORTANT: jquery-ujs will use the jQuery available in the global scope, window.j  Query, which is
 * exposed by rails-jquery and as of today is "1.12.4". Events triggered by jquery-ujs (e.g. remote
 * forms) won't be caught by event listeners registered in jQuery 3.x, the one used in our TS
 * codebase.
 *
 * SPOILER ALERT: As of rails 7 UJS is deprecated. It is recommended to use Turbo now.
 *
 * For want of documented go to:
 *   - https://guides.rubyonrails.org/v6.1.0/working_with_javascript_in_rails.html
 *   - https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts/rails-ujs.esm.js
 */
import type { JQueryXHR, JQuery as JQuery1 } from 'Types/jquery/v1'

declare global {
  interface Window {
    Rails: RailsUJS;
  }

  interface GlobalEventHandlersEventMap {
    'ajax:before': AJAXBeforeEvent;
    'ajax:beforeSend': AJAXBeforeSendEvent;
    'ajax:send': AJAXSendEvent;
    'ajax:stop': AJAXStopEvent;
    'ajax:success': AJAXSuccessEvent<any>;
    'ajax:error': AJAXErrorEvent<any>;
    'ajax:complete': AJAXCompleteEvent;
  }
}

interface RailsUJS {
  handleRemote: (arg: JQuery1) => JQueryXHR | false;
}

type AJAXBeforeEvent = Event

interface AJAXBeforeSendEvent extends Event {
  detail: [xhr: XMLHttpRequest, options: unknown];
}

interface AJAXSendEvent extends Event {
  detail: [xhr: XMLHttpRequest];
}

type AJAXStopEvent = Event

interface AJAXSuccessEvent<T> extends Event {
  detail: [response: T, status: string, xhr: XMLHttpRequest];
}

interface AJAXErrorEvent<T> extends Event {
  detail: [response: T, status: string, xhr: XMLHttpRequest];
}

interface AJAXCompleteEvent extends Event {
  detail: [xhr: XMLHttpRequest, status: string];
}
