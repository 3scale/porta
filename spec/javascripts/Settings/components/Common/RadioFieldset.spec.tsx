import React from 'react'
import { shallow } from 'enzyme'

import { RadioFieldset } from 'Settings/components/Common'

it('should render correctly', () => {
  const props = {
    legend: 'Foo Fighters',
    value: 'pat',
    name: 'foo_fighters',
    catalog: {
      dave: 'Grohl',
      pat: 'Smear'
    },
    onChange: jest.fn()
  }

  const view = shallow(<  RadioFieldset {...props}><span>My Hero</span></>)
  expect(view).toMatchSnapshot()
})
