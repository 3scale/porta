import { mount } from 'enzyme'
import { TextInputGroup } from 'Settings/components/Common/TextInputGroup'

import type { Props } from 'Settings/components/Common/TextInputGroup'

const defaultProps: Props = {
  name: 'dooz_kawa_chanson',
  value: 'Me Faire La Belle',
  label: '',
  legend: undefined,
  checked: undefined,
  hint: 'Enter your favourite Dooz Kawa tune',
  placeholder: 'You Favourite Dooz Kawa',
  defaultValue: 'Le Monstre',
  readOnly: undefined,
  inputType: undefined,
  isDefaultValue: undefined,
  onChange: undefined
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<TextInputGroup {...{ ...defaultProps, ...props }} />)

it('should render correctly', () => {
  const view = mountWrapper()
  expect(view).toMatchSnapshot()
})

it('should default value when indicated', () => {
  const view = mountWrapper({ isDefaultValue: true })
  expect(view.find('input').prop('value')).toBe('Le Monstre')
})
