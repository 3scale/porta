declare global {
  interface Window {
    grecaptcha: ReCaptchaInstance;
  }
}

export interface ReCaptchaInstance {
  ready: (cb: () => void) => void;
  execute: (sitekey: string, options: { action: string }) => Promise<string>;
}
