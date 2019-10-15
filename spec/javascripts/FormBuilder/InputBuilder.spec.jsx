import React from 'react'
import { shallow } from 'enzyme'
import {
  TextInput,
  FormSelect,
  Checkbox,
  Radio
} from '@patternfly/react-core'

import { InputBuilder } from 'FormBuilder/InputBuilder'

it('should return the correct PF4 component given a type', () => {
  const props = {
    text: {
      type: 'text',
      fieldId: 'baz',
      id: 'bar'
    },
    select: {
      type: 'select',
      fieldId: 'foo',
      collection: [
        {value: 'foo', label: 'Foo'}
      ]
    },
    checkbox: {
      fieldId: 'check',
      type: 'checkbox',
      id: 'checkthisout'
    },
    radio: {
      fieldId: 'rad',
      type: 'radio',
      id: 'checkthisoutornot',
      name: 'tvontheradio'
    }
  }

  const expected = {
    text: TextInput,
    select: FormSelect,
    checkbox: Checkbox,
    radio: Radio
  }

  Object.keys(props).forEach(k => {
    const wrapper = shallow(<InputBuilder settings={props[k]} />)
    expect(wrapper.find(expected[k]).exists()).toBe(true)
  })
})
