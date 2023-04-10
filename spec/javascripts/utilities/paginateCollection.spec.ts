import { paginateCollection } from 'utilities/paginateCollection'

it('should paginate a collection', () => {
  const items = new Array(6).fill({}).map((_, i) => ({ id: i, value: `item no. ${i}` }))
  const perPage = 2

  expect(paginateCollection(items, perPage)).toMatchInlineSnapshot(`
    {
      "1": [
        {
          "id": 0,
          "value": "item no. 0",
        },
        {
          "id": 1,
          "value": "item no. 1",
        },
      ],
      "2": [
        {
          "id": 2,
          "value": "item no. 2",
        },
        {
          "id": 3,
          "value": "item no. 3",
        },
      ],
      "3": [
        {
          "id": 4,
          "value": "item no. 4",
        },
        {
          "id": 5,
          "value": "item no. 5",
        },
      ],
    }
  `)
})

it('should not fail', () => {
  expect(paginateCollection([1, 2, 3], 0)).toEqual({})
})
