/* eslint-disable @typescript-eslint/naming-convention */
export {}

declare global {
  interface Window {
    CMS: {
      partialPaths: (paths: string[]) => void;
    };
  }
}
