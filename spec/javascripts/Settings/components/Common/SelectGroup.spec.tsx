import React from 'react'
import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { SelectGroup } from 'Settings/components/Common'

const setup = () => {
  const props = {
    label: 'Jukebox',
    name: 'jukebox',
    hint: 'Pick your favourite',
    value: 'nick_cave',
    catalog: {
      the_libertines: 'The Libertines',
      tame_impala: 'Tame Impala',
      massive_attack: 'Massive Attack',
      nick_cave: 'Nick Cave'
    }
  }
  const tree = mount(<SelectGroup {...props} />)
  return { props, tree }
}

it('should render correctly', () => {
  const { tree } = setup()
  expect(tree).toMatchSnapshot()
})

it('should change the hidden input value as expected', () => {
  const { tree } = setup()
  const selectProps = tree.find('Select').props()
  expect(tree.find('input[type="hidden"]').prop('value')).toBe('nick_cave')

  act(() => selectProps.onSelect({}, { key: 'massive_attack', toString: jest.fn() }))
  tree.update()

  expect(tree.find('input[type="hidden"]').prop('value')).toBe('massive_attack')
})
