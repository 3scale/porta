/* eslint-disable @typescript-eslint/naming-convention */
import type CodeMirror from 'codemirror'
import type SwaggerUI from 'swagger-ui'
import type { compose } from 'redux'
import type { JQueryStatic as JQueryStaticV1, JQueryXHR, JQuery as JQuery1 } from 'Types/jquery/v1'

declare global {
  interface Window {
    $: JQueryStaticV1 & JQueryStaticV1Plugins;
    jQueryUI: JQueryStatic;
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
    dashboardWidget: {
      loadAudienceWidget: (widgetPath: string) => void;
    };
    renderChartWidget: (widget: string, data: unknown) => void;
    setLocationHash: (value: string) => void; // Defined in app/assets/javascripts/provider/utils.js.coffee
  }

  // This is jQuery v1 that is loaded from app/assets/javascript and exported to window.$
  // This should be de default jQuery available, only TS files loaded by webpack have v3.7.0
  interface JQueryStaticV1Plugins {
    colorbox: ColorboxStatic;
    cookie: (name: string, value?: string, opts?: unknown) => string | undefined;
    flash: ((message: string) => void) & {
      notice: (message: string) => void;
      error: (message: string) => void;
    };
    rails: {
      handleRemote: (arg: JQuery | JQuery1) => JQueryXHR | false;
    };
  }

  // jQueryUI static props injected into jQuery 3.7 when imported from webpack
  interface JQueryStatic {
    ui?: {
      version: string;
    };
  }

  // jQueryUI widgets injected into jQuery 3.7 when imported from webpack. Only the ones imported
  // will be available hence the optional nature.
  interface JQuery {
    sortable?: (opts: string | {
      update: (event: Event, ui: { item: JQuery }) => void;
    }) => string | undefined;
    tabs?: (opts: Partial<{
      active: boolean | number;
      activate: (event: Event, ui: { newPanel: JQuery }) => void;
      show: (event: Event, ui: { panel: JQuery }) => void;
    }>) => void;
    droppable?: (opts: {
      hoverClass: string;
      drop: (event: Event, ui: { helper: JQuery }) => void;
    }) => void;
    draggable?: (opts: {
      helper: (event: Event) => unknown;
      revert: string;
    }) => void;
  }

  type WithRequiredProp<T, Key extends keyof T> = Required<Pick<T, Key>> & T

  namespace ThreeScale {
    function partialPaths (paths: string[]): void
  }
}
