import type { SwaggerUIPlugin } from 'swagger-ui'
import type { Component } from 'react'
import type { SwaggerUIContext, JsonSchemaFormProperties } from 'swagger-ui-utils'

interface SchemaProperty {
  type?: string;
  example?: unknown;
  default?: unknown;
  examples?: unknown[];
}

const PRIMITIVE_TYPES = new Set(['string', 'integer', 'number', 'boolean'])

const GENERATED_DEFAULTS: Record<string, unknown> = {
  string: 'string',
  integer: 0,
  number: 0,
  boolean: true
}

const hasSchemaExample = (prop: SchemaProperty): boolean =>
  prop.example !== undefined || prop.default !== undefined ||
  (Array.isArray(prop.examples) && prop.examples.length > 0)

const hasImmutableSchemaExample = (schema: { get?: (key: string) => unknown } | undefined): boolean => {
  if (!schema?.get) return false
  return schema.get('example') !== undefined ||
    schema.get('default') !== undefined ||
    (schema.get('examples') as { size?: number } | undefined)?.size !== undefined
}

// Given a parsed request body object and a schema, replaces swagger-ui's
// generated default values ("string", 0, true) with empty strings for
// properties that lack explicit examples or defaults in the spec.
export const clearGeneratedDefaults = (
  body: Record<string, unknown>,
  properties: Record<string, SchemaProperty>
): Record<string, unknown> => {
  const result = { ...body }
  for (const [key, prop] of Object.entries(properties)) {
    if (!(key in result)) continue
    const type = prop.type
    if (type && PRIMITIVE_TYPES.has(type) && !hasSchemaExample(prop) && result[key] === GENERATED_DEFAULTS[type]) {
      result[key] = ''
    }
  }
  return result
}

// Swagger-ui plugin that prevents auto-generated default values from filling
// form fields. Combines two overrides:
// - JsonSchemaForm wrapper: sets dispatchInitialValue=false to prevent
//   generated defaults from being dispatched on mount (handles initial render)
// - selectDefaultRequestBodyValue selector wrapper: clears generated defaults
//   from the value used by the Reset button
export const ClearDefaultValuesPlugin: SwaggerUIPlugin = () => ({
  wrapComponents: {
    // eslint-disable-next-line @typescript-eslint/naming-convention
    JsonSchemaForm: (Original: Component, { React }: SwaggerUIContext) =>
      // eslint-disable-next-line @typescript-eslint/naming-convention
      function JsonSchemaFormWrapped (props: JsonSchemaFormProperties) {
        const newProps = { ...props }
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-explicit-any
        const schema = (props as any).schema as { get?: (key: string) => unknown } | undefined
        const type = schema?.get?.('type') as string | undefined
        if (type && PRIMITIVE_TYPES.has(type) && !hasImmutableSchemaExample(schema)) {
          newProps.dispatchInitialValue = false
        }
        return React.createElement(Original, newProps)
      }
  },
  statePlugins: {
    oas3: {
      wrapSelectors: {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        selectDefaultRequestBodyValue: (oriSelector: (...args: any[]) => unknown, system: any) =>
          // eslint-disable-next-line @typescript-eslint/no-explicit-any, @typescript-eslint/no-unsafe-argument
          (_state: unknown, path: string, method: string) => {
            // eslint-disable-next-line @typescript-eslint/no-unsafe-call
            const result = oriSelector(path, method) as string | null
            if (typeof result !== 'string') return result

            // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-assignment
            const { specSelectors, oas3Selectors } = system.getSystem()
            // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-assignment
            const contentType: string | null = oas3Selectors.requestContentType(path, method)
            if (!contentType) return result

            const isFormEncoded = contentType === 'application/x-www-form-urlencoded' || contentType.startsWith('multipart/')
            if (!isFormEncoded) return result

            // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-assignment
            const requestBody = specSelectors.specResolvedSubtree(['paths', path, method, 'requestBody'])
            // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-assignment
            const schema = requestBody?.getIn?.(['content', contentType, 'schema'])?.toJS?.() as Record<string, unknown> | undefined
            const properties = schema?.properties as Record<string, SchemaProperty> | undefined
            if (!properties) return result

            try {
              const parsed = JSON.parse(result) as Record<string, unknown>
              return JSON.stringify(clearGeneratedDefaults(parsed, properties), null, 2)
            } catch {
              return result
            }
          }
      }
    }
  }
})
