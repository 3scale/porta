import type { compose } from "redux"

export {}

declare global {
  interface Window {
    $: JQueryStatic
    statsUsage: any
    statsDaysOfWeek: any
    statsHoursOfDay: any
    statsTopApps: any
    statsApplication: any
    statsResponseCodes: any
    SwaggerUI: (args: any, serviceEndpoint: string) => void
    __REDUX_DEVTOOLS_EXTENSION_COMPOSE__: typeof compose
    serviceInitialize: any
    Stats: {
      statsApplication: any
    }
    analytics: {
      trackLink: (container: HTMLElement, msg: string) => void
    }
  }

  interface JQueryStatic {
    flash: {
      notice: (msg: string) => void
      error: (msg: string) => void
    }
  }
}
