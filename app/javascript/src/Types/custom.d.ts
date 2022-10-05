declare module '*.svg' {
  import React = require('react')

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
  const data: any
  export default data
}

// We don't care about missing types from this package. Used only in spec/javascripts/PaymentGateways/braintree/BraintreeForm.spec.tsx
declare module 'braintree-web/hosted-fields';

// TODO: when we use a official release of Quickstarts we can remove this workaround
declare module '@patternfly/quickstarts/dist/quickstarts-full.es';
