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
    serviceInitialize: unknown;
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

  interface JQueryStatic {
    flash: {
      notice: (msg: string) => void;
      error: (msg: string) => void;
    };
  }
}
