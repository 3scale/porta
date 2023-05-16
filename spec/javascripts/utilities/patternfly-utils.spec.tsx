import { SelectOption } from '@patternfly/react-core'
import * as patternflyUtils from 'utilities/patternfly-utils'
import type { IRecord } from 'utilities/patternfly-utils'

const item = { id: 10, name: 'The item', description: 'A standard item object' }

it('#toSelectOptionObject should work', () => {
  const obj = patternflyUtils.toSelectOptionObject(item)

  expect(obj).toMatchObject({ id: '10', name: 'The item', toString: expect.any(Function) })
  expect(obj.toString()).toEqual('The item')
})

it('#toSelectOption should work', () => {
  const selectOption = patternflyUtils.toSelectOption({ ...item, disabled: undefined, className: 'banana' })

  expect(selectOption).toMatchInlineSnapshot(`
<SelectOption
  className="banana"
  component="button"
  data-description="A standard item object"
  index={0}
  inputId=""
  isChecked={false}
  isDisabled={false}
  isFavorite={null}
  isLastOptionBeforeFooter={[Function]}
  isLoad={false}
  isLoading={false}
  isNoResultsOption={false}
  isPlaceholder={false}
  isSelected={false}
  keyHandler={[Function]}
  onClick={[Function]}
  sendRef={[Function]}
  setViewMoreNextIndex={[Function]}
  value={
    {
      "compareTo": [Function],
      "id": "10",
      "name": "The item",
      "toString": [Function],
    }
  }
/>
`)
})

it('#handleOnFilter should work', () => {
  const items = [
    { id: 1, name: 'One item', description: '' },
    { id: 2, name: 'Another item', description: '' }
  ]

  const filter = (term: string): any[] => patternflyUtils.handleOnFilter(items)(undefined, term)!
    .map((el) => (el as unknown as SelectOption).props.value)

  expect(filter('one')).toMatchInlineSnapshot(`
[
  {
    "compareTo": [Function],
    "id": "1",
    "name": "One item",
    "toString": [Function],
  },
]
`)
  expect(filter('item')).toMatchInlineSnapshot(`
[
  {
    "compareTo": [Function],
    "id": "1",
    "name": "One item",
    "toString": [Function],
  },
  {
    "compareTo": [Function],
    "id": "2",
    "name": "Another item",
    "toString": [Function],
  },
]
`)
  expect(filter('')).toMatchInlineSnapshot(`
[
  {
    "compareTo": [Function],
    "id": "1",
    "name": "One item",
    "toString": [Function],
  },
  {
    "compareTo": [Function],
    "id": "2",
    "name": "Another item",
    "toString": [Function],
  },
]
`)
  expect(filter('asdf')).toEqual([])
})
