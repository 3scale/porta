import React from 'react'
import { mount } from 'enzyme'

import { TextInputGroup } from 'Settings/components/Common'

const setup = (custom = {}) => {
  const props = {
    placeholder: 'You Favourite Dooz Kawa',
    name: 'dooz_kawa_chanson',
    hint: 'Enter your favourite Dooz Kawa tune',
    value: 'Me Faire La Belle',
    defaultValue: 'Le Monstre',
    ...custom
  }
  const view = mount(<TextInputGroup {...props} />)
  return { props, view }
}

it('should render correctly', () => {
  const { view } = setup()
  expect(view).toMatchSnapshot()
})

it('should default value when indicated', () => {
  const { view } = setup({ isDefaultValue: true })
  expect(view.find('input').prop('value')).toBe('Le Monstre')
})
