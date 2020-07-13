import { sortable } from '@patternfly/react-table'

const generateColumns = () => [
  {
    categoryName: 'name',
    title: 'Name',
    transforms: [sortable]
  },
  {
    categoryName: 'species',
    title: 'Species / Race',
    transforms: [sortable]
  },
  {
    categoryName: 'nationality',
    title: 'Nationality',
    transforms: [sortable]
  },
  {
    categoryName: 'state',
    title: 'State',
    transforms: [sortable]
  }
]

const generateRows = (characters) => characters.map((c) => ({
  id: c.id,
  cells: Object.keys(c).filter((k) => k !== 'id').map((k) => c[k]),
  selected: false
}))

export { generateRows, generateColumns }
