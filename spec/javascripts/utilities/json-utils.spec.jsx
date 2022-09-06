import { fromJsonString, safeFromJsonString } from 'utilities'

const goodOlJsonString = '{"answer": "42"}'
const badOlJsonString = "{answer': '42'}"

console.warn = jest.fn()

describe('fromJsonString', () => {
  it('should successfully parse the json string', () => {
    expect(fromJsonString(goodOlJsonString)).toEqual({ 'answer': '42' })
  })

  it('should throw error when parsing a bad formatted json string', () => {
    expect(() => fromJsonString(badOlJsonString)).toThrow('Unexpected token a in JSON at position 1')
  })

  it('should throw an error when parsing undefined', () => {
    expect(() => fromJsonString(undefined)).toThrow()
  })
})

describe('safeFromJsonString', () => {
  it('should successfully parse the json string', () => {
    expect(safeFromJsonString(goodOlJsonString)).toEqual({ 'answer': '42' })
  })

  it('should return undefined when parsing a bad formatted json string', () => {
    expect(safeFromJsonString(badOlJsonString)).toBe(undefined)
  })

  it('should not throw an error when parsing undefined', () => {
    expect(safeFromJsonString(undefined)).toEqual(undefined)
  })
})
