/* eslint-disable @typescript-eslint/naming-convention */
import type CodeMirror from 'codemirror'
import type SwaggerUI from 'swagger-ui'
import type { compose } from 'redux'

declare global {
  interface Window {
    $: JQueryStatic;
    colorbox: ColorboxStatic;
    CodeMirror: typeof CodeMirror;
    statsUsage: unknown;
    statsDaysOfWeek: unknown;
    statsHoursOfDay: unknown;
    statsTopApps: unknown;
    statsApplication: unknown;
    statsResponseCodes: unknown;
    SwaggerUI: (args: SwaggerUI.SwaggerUIOptions, serviceEndpoint: string) => void;
    __REDUX_DEVTOOLS_EXTENSION_COMPOSE__?: typeof compose;
    Stats: {
      statsApplication: unknown;
    };
    analytics: {
      trackLink: (container: HTMLElement, msg: string) => void;
    };
  }

  // jQueryUI static props injected into jQuery 3.7
  interface JQueryStatic {
    ui?: {
      version: string;
    };
    active: number;
    cookie: (name: string, value?: string, opts?: unknown) => string | undefined;
  }

  // jQueryUI widgets injected into jQuery 3.7. Only the ones imported in the same file will be available.
  interface JQuery {
    sortable?: (opts: string | {
      cancel?: string;
      cursor?: string;
      handle?: string;
      helper?: string;
      items?: string;
      update: (event: Event, ui: { item: JQuery }) => void;
    }) => string | undefined;
    tabs?: (opts?: Partial<{
      active: boolean | number;
      activate: (event: Event, ui: { newPanel: JQuery }) => void;
    }>) => void;
    droppable?: (opts: {
      hoverClass: string;
      drop: (event: Event, ui: { helper: JQuery }) => void;
    }) => void;
    draggable?: (opts: {
      handle: string;
      helper: string | ((event: Event) => Element);
      revert: string;
    }) => void;
    pjax?: (selector: string, container: string, opts?: { timeout?: number }) => void;
  }

  type WithRequiredProp<T, Key extends keyof T> = Required<Pick<T, Key>> & T
}
