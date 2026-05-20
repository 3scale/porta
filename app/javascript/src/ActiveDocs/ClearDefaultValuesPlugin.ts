/* eslint-disable @typescript-eslint/no-unsafe-member-access */
import type { SwaggerUIPlugin } from 'swagger-ui'

/**
 * Swagger UI plugin that prevents any auto-filling of input fields.
 *
 * By default, Swagger UI auto-fills form inputs with values from:
 * - Explicit examples and defaults in the spec
 * - Auto-generated placeholders like "string", 0, true, enum values
 *
 * This plugin disables all auto-filling by overriding sample generation
 * to return empty values based on schema structure.
 */
export const ClearDefaultValuesPlugin: SwaggerUIPlugin = () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const emptySampleFromSchema = (schema?: any): any => {
    if (!schema || typeof schema !== 'object') return undefined

    // For object schemas, return an object with all properties as empty strings
    if (schema.type === 'object' && schema.properties) {
      const result: Record<string, string> = {}
      for (const key in schema.properties) {
        if (Object.prototype.hasOwnProperty.call(schema.properties, key)) {
          result[key] = ''
        }
      }
      return result
    }

    // For all other types, return undefined
    return undefined
  }

  return {
    fn: {
      jsonSchema5: {
        getSampleSchema: emptySampleFromSchema
      },
      jsonSchema202012: {
        getSampleSchema: emptySampleFromSchema
      },
      getSampleSchema: emptySampleFromSchema
    }
  }
}
