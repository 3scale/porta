// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'

jest.mock('swagger-ui-react')

const url = 'foo.example.com'

it('should render itself', () => {
  const wrapper = mount(<ActiveDocsSpec url={url} accountData={{}} />)
  expect(wrapper.find(ActiveDocsSpec).exists()).toBe(true)
})

it('should render swagger-ui', () => {
  const wrapper = mount(<ActiveDocsSpec url={url} accountData={{}}/>)
  console.log(wrapper.debug())

  expect(wrapper).toMatchSnapshot()
})
