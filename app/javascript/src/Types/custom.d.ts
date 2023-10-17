/* eslint-disable @typescript-eslint/naming-convention */
declare module '*.svg' {
  // eslint-disable-next-line @typescript-eslint/no-require-imports -- TODO: let's try to remove this
  import React = require('react')

  // @ts-expect-error For some reason SFC makes it work, even though it seems it does not exist
  // eslint-disable-next-line @typescript-eslint/init-declarations
  export const ReactComponent: React.SFC<React.SVGProps<SVGSVGElement>>
  const src: string
  export default src
}

declare module '*.jpg' {
  const content: string
  export default content
}

declare module '*.png' {
  const content: string
  export default content
}

declare module '*.json' {
  const content: string
  export default content
}

declare module '*.yaml' {
  const data: unknown
  export default data
}

// We don't care about missing types from this package. Used only in spec/javascripts/PaymentGateways/braintree/BraintreeForm.spec.tsx
declare module 'braintree-web/hosted-fields';

declare let __webpack_public_path__: string
