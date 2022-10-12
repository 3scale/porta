// @flow

// Disabling all weak-type checks since this file is a workaround for missing types
/* eslint-disable flowtype/no-weak-types */

declare module 'swagger-ui-react' {
  declare module.exports: any;
}

declare module 'validate.js' {
  declare module.exports: any;
}

declare module 'jquery' {
  declare module.exports: JQueryStatic & {
    flash: {
      notice: (msg: string) => void,
      error: (msg: string) => void
    }
  };
}

export type Window = any
