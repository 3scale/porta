import React from 'react'
import { shallow } from 'enzyme'

import { ServiceManualListItems } from 'NewService/components/FormElements'

it('should render required form fields', () => {
  const props = {
    service: {
      name: 'New API',
      system_name: 'new_api',
      description: 'A brand new API'
    },
    errors: {}
  }
  const view = shallow(<ServiceManualListItems {...props}/>)

  expect(view).toMatchSnapshot()
})

it('should render required form fields with errors', () => {
  const props = {
    service: {
      name: '',
      system_name: 'new api',
      description: 'A brand new API'
    },
    errors: {
      name: ["Can't be blank"],
      system_name: ['Only ASCII letters, numbers, dashes and underscores are allowed.']
    }
  }
  const view = shallow(<ServiceManualListItems {...props}/>)

  expect(view).toMatchSnapshot()
})
