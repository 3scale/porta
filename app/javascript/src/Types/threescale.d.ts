/* eslint-disable @typescript-eslint/naming-convention */
export {}

declare global {
  interface Window {
    ThreeScale: {
      spinnerId: string;
      showSpinner: () => void;
      hideSpinner: () => void;
    };
  }
}
