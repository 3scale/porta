import { fromJsonString, safeFromJsonString } from 'utilities/json-utils'

const goodOlJsonString = '{"answer": "42"}'
const badOlJsonString = "{answer': '42'}"

describe('fromJsonString', () => {
  it('should successfully parse the json string', () => {
    expect(fromJsonString(goodOlJsonString)).toEqual({'answer': '42'})
  })

  it('should throw error when parsing a bad formatted json string', () => {
    expect(() => fromJsonString(badOlJsonString)).toThrow('Unexpected token a in JSON at position 1')
  })
})

describe('safeFromJsonString', () => {
  it('should successfully parse the json string', () => {
    expect(safeFromJsonString(goodOlJsonString)).toEqual({'answer': '42'})
  })

  it('should return undefined when parsing a bad formatted json string', () => {
    expect(safeFromJsonString(badOlJsonString)).toBe(undefined)
  })
})
