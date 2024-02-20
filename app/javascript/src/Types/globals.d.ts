/* eslint-disable @typescript-eslint/naming-convention */
import type CodeMirror from 'codemirror'
import type SwaggerUI from 'swagger-ui'
import type { compose } from 'redux'

declare global {
  interface Window {
    $: JQueryStatic;
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

  // Overrides jquery typings from node_modules to include jquery-ui. This has nothing to do
  // with JQueryV1 or JQueryV1Plugins. This is for TS files with: import $ from 'jquery'
  interface JQueryStatic {
    ui: {
      version: string;
    };
  }

  // Overrides jquery typings from node_modules to include jquery-ui. This has nothing to do
  // with JQueryV1 or JQueryV1Plugins. This is for TS files with: import $ from 'jquery'
  interface JQuery {
    sortable: (opts: string | {
      update: (event: Event, ui: { item: JQuery }) => void;
    }) => string | undefined;
  }
}
