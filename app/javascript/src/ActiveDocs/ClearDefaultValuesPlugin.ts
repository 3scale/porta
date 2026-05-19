import type { SwaggerUIPlugin } from 'swagger-ui'
import type { Component } from 'react'
import type { SwaggerUIContext, JsonSchemaFormProperties } from 'swagger-ui-utils'

// A plain schema property as it appears in the resolved OAS3 spec JSON.
interface SchemaProperty {
  type?: string;
  example?: unknown;
  default?: unknown;
  examples?: unknown[];
}

// Primitive types for which swagger-ui auto-generates placeholder values
// ("string", 0, true) when no explicit value exists in the spec.
const PRIMITIVE_TYPES = new Set(['string', 'integer', 'number', 'boolean'])

// The exact placeholder values swagger-ui generates per type, used to detect
// auto-filled fields vs. values the user or spec author actually provided.
const GENERATED_DEFAULTS: Record<string, unknown> = {
  string: 'string',
  integer: 0,
  number: 0,
  boolean: true
}

// Returns true when a plain-object schema property has an explicit example or
// default, meaning the generated placeholder is intentional and should not be
// cleared. Used with the resolved spec (plain JS objects).
const hasSchemaExample = (prop: SchemaProperty): boolean =>
  prop.example !== undefined || prop.default !== undefined ||
  (Array.isArray(prop.examples) && prop.examples.length > 0)

// Same check, but for Immutable.js Map objects. swagger-ui passes schema as
// an Immutable Map to JsonSchemaForm, so ordinary property access won't work.
const hasImmutableSchemaExample = (schema: { get?: (key: string) => unknown } | undefined): boolean => {
  if (!schema?.get) return false
  return schema.get('example') !== undefined ||
    schema.get('default') !== undefined ||
    // Immutable Lists have a `size` property; a non-empty examples list suffices.
    (schema.get('examples') as { size?: number } | undefined)?.size !== undefined
}

// Replaces swagger-ui's auto-generated placeholder values with empty strings
// for properties that have no explicit example or default in the spec.
// Properties with real spec values, or body keys absent from the schema, are
// left untouched. Does not mutate the input object.
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

// Swagger-ui plugin that prevents auto-generated placeholder values ("string",
// 0, true) from appearing in form fields when no example or default is defined
// in the spec. It combines two targeted overrides:
//
// 1. JsonSchemaForm wrapper — runs once at mount. Sets dispatchInitialValue=false
//    for primitive fields without spec examples/defaults, which stops swagger-ui
//    from dispatching the generated placeholder into the form state on mount.
//    Fields with explicit examples/defaults are left at dispatchInitialValue=true
//    so their spec values are dispatched normally.
//
// 2. selectDefaultRequestBodyValue selector wrapper — runs only when the user
//    clicks Reset. Post-processes the selector's JSON string result, replacing
//    generated placeholders with empty strings using the resolved spec schema.
//
// Only form-encoded content types are processed by the selector wrapper;
// JSON and other types pass through unchanged.
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
          // The wrapSelectors convention injects state as the first arg; we
          // don't need it since the original selector already has state bound.
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

            // Only form-encoded bodies are represented as flat key/value pairs;
            // JSON bodies should pass through to preserve their structure.
            const isFormEncoded = contentType === 'application/x-www-form-urlencoded' || contentType.startsWith('multipart/')
            if (!isFormEncoded) return result

            // specResolvedSubtree returns an Immutable Map with $refs already resolved.
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
