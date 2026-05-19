import { ClearDefaultValuesPlugin, clearGeneratedDefaults } from 'ActiveDocs/ClearDefaultValuesPlugin'

describe('ClearDefaultValuesPlugin', () => {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const plugin = (ClearDefaultValuesPlugin as any)() as any

  describe('wrapComponents.JsonSchemaForm', () => {
    const mockImmutableSchema = (fields: Record<string, unknown>) => ({
      get: (key: string) => fields[key]
    })

    it.each(['string', 'integer', 'number', 'boolean'])('sets dispatchInitialValue to false for type "%s" without example', (type) => {
      const createElement = jest.fn()
      const Original = jest.fn()

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
      const Wrapped = plugin.wrapComponents.JsonSchemaForm(Original, { React: { createElement } })

      Wrapped({ dispatchInitialValue: true, schema: mockImmutableSchema({ type }) })

      expect(createElement).toHaveBeenCalledWith(Original, expect.objectContaining({
        dispatchInitialValue: false
      }))
    })

    it('keeps dispatchInitialValue when schema has example', () => {
      const createElement = jest.fn()
      const Original = jest.fn()

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
      const Wrapped = plugin.wrapComponents.JsonSchemaForm(Original, { React: { createElement } })

      Wrapped({ dispatchInitialValue: true, schema: mockImmutableSchema({ type: 'string', example: 'Jane Doe' }) })

      expect(createElement).toHaveBeenCalledWith(Original, expect.objectContaining({
        dispatchInitialValue: true
      }))
    })

    it('keeps dispatchInitialValue when schema has default', () => {
      const createElement = jest.fn()
      const Original = jest.fn()

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
      const Wrapped = plugin.wrapComponents.JsonSchemaForm(Original, { React: { createElement } })

      Wrapped({ dispatchInitialValue: true, schema: mockImmutableSchema({ type: 'integer', default: 30 }) })

      expect(createElement).toHaveBeenCalledWith(Original, expect.objectContaining({
        dispatchInitialValue: true
      }))
    })

    it('keeps dispatchInitialValue for non-primitive types', () => {
      const createElement = jest.fn()
      const Original = jest.fn()

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
      const Wrapped = plugin.wrapComponents.JsonSchemaForm(Original, { React: { createElement } })

      Wrapped({ dispatchInitialValue: true, schema: mockImmutableSchema({ type: 'object' }) })

      expect(createElement).toHaveBeenCalledWith(Original, expect.objectContaining({
        dispatchInitialValue: true
      }))
    })

    it('preserves all other props', () => {
      const createElement = jest.fn()
      const Original = jest.fn()

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
      const Wrapped = plugin.wrapComponents.JsonSchemaForm(Original, { React: { createElement } })

      const schema = mockImmutableSchema({ type: 'string' })
      Wrapped({ dispatchInitialValue: true, value: 'test', schema, fn: {}, errors: [] })

      expect(createElement).toHaveBeenCalledWith(Original, expect.objectContaining({
        value: 'test',
        schema,
        fn: {},
        errors: []
      }))
    })
  })

  describe('wrapSelectors.selectDefaultRequestBodyValue', () => {
    const createMockSystem = (contentType: string | null, schema: Record<string, unknown> | undefined) => ({
      getSystem: () => ({
        oas3Selectors: {
          requestContentType: jest.fn().mockReturnValue(contentType)
        },
        specSelectors: {
          specResolvedSubtree: jest.fn().mockReturnValue(schema ? {
            getIn: (path: string[]) => {
              if (path[0] === 'content' && path[1] === contentType && path[2] === 'schema') {
                return { toJS: () => schema }
              }
              return undefined
            }
          } : undefined)
        }
      })
    })

    // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
    const getWrapper = () => plugin.statePlugins.oas3.wrapSelectors.selectDefaultRequestBodyValue

    it('clears generated defaults for properties without examples', () => {
      const wrapper = getWrapper()
      const schema = {
        type: 'object',
        properties: {
          name: { type: 'string' },
          age: { type: 'integer' },
          score: { type: 'number' },
          active: { type: 'boolean' }
        }
      }
      const body = { name: 'string', age: 0, score: 0, active: true }
      const oriSelector = jest.fn().mockReturnValue(JSON.stringify(body))
      const system = createMockSystem('application/x-www-form-urlencoded', schema)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const result = JSON.parse(wrapped(null, '/users', 'post') as string) as Record<string, unknown>

      expect(result.name).toBe('')
      expect(result.age).toBe('')
      expect(result.score).toBe('')
      expect(result.active).toBe('')
    })

    it('preserves properties with explicit examples', () => {
      const wrapper = getWrapper()
      const schema = {
        type: 'object',
        properties: {
          name: { type: 'string', example: 'Jane Doe' },
          age: { type: 'integer', default: 30 },
          email: { type: 'string' }
        }
      }
      const body = { name: 'Jane Doe', age: 30, email: 'string' }
      const oriSelector = jest.fn().mockReturnValue(JSON.stringify(body))
      const system = createMockSystem('application/x-www-form-urlencoded', schema)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const result = JSON.parse(wrapped(null, '/users', 'post') as string) as Record<string, unknown>

      expect(result.name).toBe('Jane Doe')
      expect(result.age).toBe(30)
      expect(result.email).toBe('')
    })

    it('preserves properties with examples array', () => {
      const wrapper = getWrapper()
      const schema = {
        type: 'object',
        properties: {
          name: { type: 'string', examples: ['foo', 'bar'] }
        }
      }
      const body = { name: 'foo' }
      const oriSelector = jest.fn().mockReturnValue(JSON.stringify(body))
      const system = createMockSystem('application/x-www-form-urlencoded', schema)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const result = JSON.parse(wrapped(null, '/users', 'post') as string) as Record<string, unknown>

      expect(result.name).toBe('foo')
    })

    it('returns null when original selector returns null', () => {
      const wrapper = getWrapper()
      const oriSelector = jest.fn().mockReturnValue(null)
      const system = createMockSystem('application/x-www-form-urlencoded', undefined)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      expect(wrapped(null, '/users', 'post')).toBeNull()
    })

    it('passes through for non-form content types', () => {
      const wrapper = getWrapper()
      const body = '{"name":"string"}'
      const oriSelector = jest.fn().mockReturnValue(body)
      const system = createMockSystem('application/json', undefined)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      expect(wrapped(null, '/users', 'post')).toBe(body)
    })

    it('handles multipart content types', () => {
      const wrapper = getWrapper()
      const schema = {
        type: 'object',
        properties: {
          name: { type: 'string' }
        }
      }
      const body = { name: 'string' }
      const oriSelector = jest.fn().mockReturnValue(JSON.stringify(body))
      const system = createMockSystem('multipart/form-data', schema)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const result = JSON.parse(wrapped(null, '/users', 'post') as string) as Record<string, unknown>

      expect(result.name).toBe('')
    })

    it('does not mutate original body values', () => {
      const wrapper = getWrapper()
      const schema = {
        type: 'object',
        properties: { name: { type: 'string' } }
      }
      const originalBody = { name: 'string' }
      const oriSelector = jest.fn().mockReturnValue(JSON.stringify(originalBody))
      const system = createMockSystem('application/x-www-form-urlencoded', schema)

      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      const wrapped = wrapper(oriSelector, system)
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      wrapped(null, '/users', 'post')

      expect(originalBody.name).toBe('string')
    })
  })
})

describe('clearGeneratedDefaults', () => {
  it('replaces generated "string" default with empty string', () => {
    const body = { name: 'string' }
    const properties = { name: { type: 'string' } }
    expect(clearGeneratedDefaults(body, properties).name).toBe('')
  })

  it('replaces generated 0 default for integer with empty string', () => {
    const body = { age: 0 }
    const properties = { age: { type: 'integer' } }
    expect(clearGeneratedDefaults(body, properties).age).toBe('')
  })

  it('replaces generated 0 default for number with empty string', () => {
    const body = { score: 0 }
    const properties = { score: { type: 'number' } }
    expect(clearGeneratedDefaults(body, properties).score).toBe('')
  })

  it('replaces generated true default for boolean with empty string', () => {
    const body = { active: true }
    const properties = { active: { type: 'boolean' } }
    expect(clearGeneratedDefaults(body, properties).active).toBe('')
  })

  it('preserves values that differ from generated defaults', () => {
    const body = { name: 'Alice', age: 25 }
    const properties = { name: { type: 'string' }, age: { type: 'integer' } }
    const result = clearGeneratedDefaults(body, properties)
    expect(result.name).toBe('Alice')
    expect(result.age).toBe(25)
  })

  it('preserves properties with explicit example', () => {
    const body = { name: 'string' }
    const properties = { name: { type: 'string', example: 'string' } }
    expect(clearGeneratedDefaults(body, properties).name).toBe('string')
  })

  it('preserves properties with explicit default', () => {
    const body = { age: 0 }
    const properties = { age: { type: 'integer', default: 0 } }
    expect(clearGeneratedDefaults(body, properties).age).toBe(0)
  })

  it('ignores body keys not in schema properties', () => {
    const body = { extra: 'string' }
    const properties = { name: { type: 'string' } }
    expect(clearGeneratedDefaults(body, properties).extra).toBe('string')
  })

  it('ignores schema properties not in body', () => {
    const body = {}
    const properties = { name: { type: 'string' } }
    expect(clearGeneratedDefaults(body, properties)).toEqual({})
  })
})
