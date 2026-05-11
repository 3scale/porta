import type { SwaggerUIPlugin } from 'swagger-ui'
import type { Component } from 'react'
import type { JsonSchemaFormProperties, SwaggerUIContext } from 'swagger-ui-utils'

export const ClearDefaultValuesPlugin: SwaggerUIPlugin = () => {
  return {
    wrapComponents: {
      // eslint-disable-next-line @typescript-eslint/naming-convention, react/no-multi-comp
      JsonSchemaForm: (originalComponent: Component, { React }: SwaggerUIContext) => function JsonSchemaFormWrapped (props: JsonSchemaFormProperties) {
        return React.createElement(originalComponent, { ...props, dispatchInitialValue: false })
      }
    }
  }
}
