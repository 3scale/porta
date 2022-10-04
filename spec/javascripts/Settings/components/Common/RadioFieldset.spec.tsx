import { shallow } from 'enzyme'
import { RadioFieldset } from 'Settings/components/Common/RadioFieldset'

import type { Props } from 'Settings/components/Common/RadioFieldset'

it('should render correctly', () => {
  const props: Props = {
    name: 'foo_fighters',
    value: 'pat',
    label: 'label',
    legend: 'Foo Fighters',
    checked: undefined,
    hint: undefined,
    placeholder: undefined,
    defaultValue: undefined,
    readOnly: undefined,
    inputType: undefined,
    isDefaultValue: undefined,
    onChange: undefined,
    catalog: {
      dave: 'Grohl',
      pat: 'Smear'
    }
  }

  const view = shallow(<RadioFieldset {...props} ><span>My Hero</span></RadioFieldset>)
  expect(view).toMatchSnapshot()
})
