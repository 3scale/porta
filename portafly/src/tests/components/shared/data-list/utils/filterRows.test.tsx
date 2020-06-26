import React from 'react'

import { filterRows } from 'components'
import { Filters, DataListRow } from 'types/data-list'
import { Button } from '@patternfly/react-core'

const Lara = { id: 0, cells: ['Lara Croft', '1996'] }
const Nate = { id: 1, cells: ['Nathan Drake', '2007'] }
const Indi: DataListRow = {
  id: 2,
  cells: [{ title: <Button>Indiana Jones</Button>, stringValue: 'Indiana Jones' }, '1981']
}
const rows = [Lara, Nate, Indi]
const columns = [
  { categoryName: 'explorer', title: 'Explorer' },
  { categoryName: 'year', title: 'Year' }
]

it('should filter correctly for 1 category', () => {
  const filterAll: Filters = {}
  expect(filterRows(rows, filterAll, columns)).toEqual(rows)

  const filterAllToo: Filters = { explorer: [] }
  expect(filterRows(rows, filterAllToo, columns)).toEqual(rows)

  const filterOne: Filters = { explorer: ['Lara'] }
  expect(filterRows(rows, filterOne, columns)).toEqual([Lara])

  const filterTwo: Filters = { explorer: ['Drake', 'Lara'] }
  expect(filterRows(rows, filterTwo, columns)).toEqual([Lara, Nate])

  const filterCase: Filters = { explorer: ['CRO', 'jo'] }
  expect(filterRows(rows, filterCase, columns)).toEqual([Lara, Indi])

  const filterNone: Filters = { explorer: ['O\'Connell'] }
  expect(filterRows(rows, filterNone, columns)).toEqual([])
})

it('should filter correctly for many categories', () => {
  const filterAll: Filters = { explorer: [], year: [] }
  expect(filterRows(rows, filterAll, columns)).toEqual(rows)

  const filterOne: Filters = { explorer: ['Lara'], year: ['1996'] }
  expect(filterRows(rows, filterOne, columns)).toEqual([Lara])

  const filterTwo: Filters = { explorer: ['Drake'], year: ['1996'] }
  expect(filterRows(rows, filterTwo, columns)).toEqual([])

  const filterCase: Filters = { explorer: [], year: ['19'] }
  expect(filterRows(rows, filterCase, columns)).toEqual([Lara, Indi])

  const filterNone: Filters = { explorer: ['Croft', 'Jones', 'Drake'], year: ['2020'] }
  expect(filterRows(rows, filterNone, columns)).toEqual([])
})

it('filters from same category should be inclusive, but exclusive from different ones', () => {
  const filterInclusive: Filters = { explorer: ['Indiana', 'Lara'] }
  expect(filterRows(rows, filterInclusive, columns)).toEqual([Lara, Indi])

  const filterExclusive: Filters = { explorer: ['Indiana'], year: ['1996'] }
  expect(filterRows(rows, filterExclusive, columns)).toEqual([])
})

it('should throw error when invalid categories', () => {
  const wrongFilterLast: Filters = { explorer: ['Indiana', 'Lara'], origin: ['movie'] }
  expect(() => filterRows(rows, wrongFilterLast, columns)).toThrow(new Error('You are trying to filter a category that doesn\'t correspond to any column in your DataList'))

  const wrongFilterFirst: Filters = { items: ['whip'], explorer: ['Indiana', 'Lara'] }
  expect(() => filterRows(rows, wrongFilterFirst, columns)).toThrow(new Error('You are trying to filter a category that doesn\'t correspond to any column in your DataList'))
})
