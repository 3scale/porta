/* eslint-disable @typescript-eslint/naming-convention */
import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'
import { Select } from '@patternfly/react-core'

import { SelectGroup } from 'Settings/components/Common/SelectGroup'

import type { Props } from 'Settings/components/Common/SelectGroup'
import type { SelectOptionObject } from '@patternfly/react-core'

const defaultProps: Props = {
  name: 'jukebox',
  value: 'nick_cave',
  label: 'Jukebox',
  children: undefined,
  legend: undefined,
  checked: undefined,
  hint: 'Pick your favourite',
  placeholder: undefined,
  defaultValue: undefined,
  readOnly: undefined,
  inputType: undefined,
  isDefaultValue: undefined,
  onChange: undefined,
  catalog: {
    the_libertines: 'The Libertines',
    tame_impala: 'Tame Impala',
    massive_attack: 'Massive Attack',
    nick_cave: 'Nick Cave'
  }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<SelectGroup {...{ ...defaultProps, ...props }} />)

it('should render correctly', () => {
  const tree = mountWrapper()
  expect(tree).toMatchSnapshot()
})

it('should change the hidden input value as expected', () => {
  const tree = mountWrapper()
  const selectProps = tree.find(Select).props()
  expect(tree.find('input[type="hidden"]').prop('value')).toBe('nick_cave')

  // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
  act(() => { selectProps.onSelect!({} as any, { key: 'massive_attack', toString: jest.fn() } as SelectOptionObject & { key: string }) })
  tree.update()

  expect(tree.find('input[type="hidden"]').prop('value')).toBe('massive_attack')
})
