/* eslint-disable @typescript-eslint/naming-convention */
import type { TYPE } from 'utilities/toast'

declare global {
  interface Window {
    ThreeScale: {
      toast: (message: string, type?: TYPE) => void;
      hideToast: (alert: HTMLLIElement) => void;
      spinnerId: string;
      showSpinner: () => void;
      hideSpinner: () => void;
    };
  }
}
