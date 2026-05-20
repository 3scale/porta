import { ClearDefaultValuesPlugin } from 'ActiveDocs/ClearDefaultValuesPlugin'

describe('ClearDefaultValuesPlugin', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const plugin = (ClearDefaultValuesPlugin as any)() as any

  describe('getSampleSchema overrides', () => {
    it('returns undefined when schema is not provided', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      const result = plugin.fn.getSampleSchema()
      expect(result).toBeUndefined()
    })

    it('returns undefined when schema is null', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      const result = plugin.fn.getSampleSchema(null)
      expect(result).toBeUndefined()
    })

    it('returns undefined for primitive types', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      expect(plugin.fn.getSampleSchema({ type: 'string' })).toBeUndefined()
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      expect(plugin.fn.getSampleSchema({ type: 'integer' })).toBeUndefined()
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      expect(plugin.fn.getSampleSchema({ type: 'number' })).toBeUndefined()
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      expect(plugin.fn.getSampleSchema({ type: 'boolean' })).toBeUndefined()
    })

    it('returns undefined for array types', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      const result = plugin.fn.getSampleSchema({ type: 'array', items: { type: 'string' } })
      expect(result).toBeUndefined()
    })

    it('returns undefined for object without properties', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      const result = plugin.fn.getSampleSchema({ type: 'object' })
      expect(result).toBeUndefined()
    })

    it('returns empty object with all properties as empty strings for object with properties', () => {
      const schema = {
        type: 'object',
        properties: {
          name: { type: 'string' },
          age: { type: 'integer' },
          email: { type: 'string' }
        }
      }

      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      const result = plugin.fn.getSampleSchema(schema)

      expect(result).toEqual({
        name: '',
        age: '',
        email: ''
      })
    })

    it('ignores examples and defaults in schema properties', () => {
      const schema = {
        type: 'object',
        properties: {
          name: { type: 'string', example: 'Jane Doe' },
          age: { type: 'integer', default: 30 }
        }
      }

      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access, @typescript-eslint/no-unsafe-call
      const result = plugin.fn.getSampleSchema(schema)

      expect(result).toEqual({
        name: '',
        age: ''
      })
    })
  })

  describe('namespace overrides', () => {
    it('overrides fn.getSampleSchema', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
      expect(plugin.fn.getSampleSchema).toBeDefined()
    })

    it('overrides fn.jsonSchema5.getSampleSchema', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
      expect(plugin.fn.jsonSchema5.getSampleSchema).toBeDefined()
    })

    it('overrides fn.jsonSchema202012.getSampleSchema', () => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
      expect(plugin.fn.jsonSchema202012.getSampleSchema).toBeDefined()
    })
  })
})
