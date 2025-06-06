import type { IAlertType } from 'Types'

declare global {
  interface Window {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    ThreeScale: {
      activeAjaxRequests: () => number;
      toast: (message: string, type?: IAlertType) => void;
      hideToast: (alert: HTMLLIElement) => void;
      spinnerId: string;
      showSpinner: () => void;
      hideSpinner: () => void;
    };
  }
}
