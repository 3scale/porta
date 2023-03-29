/* eslint-disable @typescript-eslint/naming-convention */
import type SwaggerUI from 'swagger-ui'
import type { compose } from 'redux'

declare global {
  interface Window {
    $: JQueryStatic;
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
}
