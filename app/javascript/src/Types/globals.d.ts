/* eslint-disable @typescript-eslint/naming-convention */
import type CodeMirror from 'codemirror'
import type SwaggerUI from 'swagger-ui'
import type { compose } from 'redux'

declare global {
  interface Window {
    $: JQueryStatic;
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
}
