/* eslint-disable @typescript-eslint/naming-convention */
export {}

declare global {
  interface Window {
    ThreeScale: {
      activeAjaxRequests: () => number;
      spinnerId: string;
      showSpinner: () => void;
      hideSpinner: () => void;
    };
  }
}
