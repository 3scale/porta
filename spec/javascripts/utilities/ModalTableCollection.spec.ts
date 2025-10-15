import { ModalTableCollection } from 'utilities/ModalTableCollection'

const getItems = (count: number) => new Array(count).fill({}).map((_, i) => ({ id: i, value: `item no. ${i}` }))

describe('constructor', () => {
  it('should paginate the collection with 5 per page', () => {
    const collection = new ModalTableCollection(getItems(12))

    expect(collection.get(1)).toHaveLength(5)
    expect(collection.get(2)).toHaveLength(5)
    expect(collection.get(3)).toHaveLength(2)
  })

  it('should handle empty arrays', () => {
    const collection = new ModalTableCollection([])

    expect(collection.get(1)).toBeUndefined()
  })

  it('should handle arrays with fewer items than per page', () => {
    const collection = new ModalTableCollection(getItems(2))

    expect(collection.get(1)).toHaveLength(2)
    expect(collection.get(2)).toBeUndefined()
  })
})

describe('get', () => {
  it('should return items for a given page', () => {
    const items = getItems(10)
    const collection = new ModalTableCollection(items)

    expect(collection.get(1)).toEqual(items.splice(0, 5))
  })

  it('should return undefined for non-existent page', () => {
    const collection = new ModalTableCollection(getItems(5))

    expect(collection.get(99)).toBeUndefined()
  })
})

describe('set', () => {
  it('should set items for a given page', () => {
    const items = getItems(5)

    const collection = new ModalTableCollection(items)
    expect(collection.get(1)).toEqual(items)

    const newItems = [{ id: 100, value: 'new item' }]
    collection.set(1, newItems)
    expect(collection.get(1)).toEqual(newItems)
  })

  it('should create a new page if it does not exist', () => {
    const collection = new ModalTableCollection(getItems(5))
    expect(collection.get(10)).toBeUndefined()

    const newItems = [{ id: 100, value: 'new item' }]
    collection.set(10, newItems)
    expect(collection.get(10)).toEqual(newItems)
  })
})

describe('isPageEmpty', () => {
  it('should return true when page does not exist', () => {
    const collection = new ModalTableCollection(getItems(5))

    expect(collection.isPageEmpty(99)).toBe(true)
  })

  it('should return true when page exists but has no items', () => {
    const collection = new ModalTableCollection([])
    collection.set(1, [])

    expect(collection.isPageEmpty(1)).toBe(true)
  })

  it('should return false when page has items', () => {
    const collection = new ModalTableCollection(getItems(1))

    expect(collection.isPageEmpty(1)).toBe(false)
  })
})

describe('clear', () => {
  it('should clear all pages', () => {
    const collection = new ModalTableCollection(getItems(7))
    expect(collection.get(1)).not.toBeUndefined()
    expect(collection.get(2)).not.toBeUndefined()

    collection.clear()
    expect(collection.get(1)).toBeUndefined()
    expect(collection.get(2)).toBeUndefined()
  })
})
