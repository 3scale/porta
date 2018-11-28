import {StatsSource} from 'Stats/lib/source'

let source = new StatsSource()

describe('StatsSource', () => {
  it('should throw error when call params directly', () => {
    expect(() => {
      source.params()
    }).toThrow(new Error('It should implement params method in subclasses.'))
  })

  it('should throw error when call data directly', () => {
    expect(() => {
      source.data()
    }).toThrow(new Error('It should implement data method in subclasses.'))
  })

  it('should throw error when call url directly', () => {
    expect(() => {
      source.url
    }).toThrow(new Error('It should implement url getter in subclasses.'))
  })
})
