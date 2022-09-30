import { ReactElement } from 'react'

import * as patternflyUtils from 'utilities/patternfly-utils'

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
      isChecked={false}
      isDisabled={false}
      isFocused={false}
      isNoResultsOption={false}
      isPlaceholder={false}
      isSelected={false}
      keyHandler={[Function]}
      onClick={[Function]}
      sendRef={[Function]}
      value={
        Object {
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
  const onFilter = patternflyUtils.handleOnFilter(items)

  const filter = (value: string) => onFilter({ currentTarget: { value } } as React.SyntheticEvent<HTMLInputElement>)
    .map((el: ReactElement) => el.props.value)

  expect(filter('one')).toMatchInlineSnapshot(`
    Array [
      Object {
        "id": "1",
        "name": "One item",
        "toString": [Function],
      },
    ]
  `)
  expect(filter('item')).toMatchInlineSnapshot(`
    Array [
      Object {
        "id": "1",
        "name": "One item",
        "toString": [Function],
      },
      Object {
        "id": "2",
        "name": "Another item",
        "toString": [Function],
      },
    ]
  `)
  expect(filter('')).toMatchInlineSnapshot(`
    Array [
      Object {
        "id": "1",
        "name": "One item",
        "toString": [Function],
      },
      Object {
        "id": "2",
        "name": "Another item",
        "toString": [Function],
      },
    ]
  `)
  expect(filter('asdf')).toEqual([])
})
