// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'

const url = 'foo.example.com'
const accountDataUrl = 'foo.example.com/api_docs/account_data.json'

it('should render itself', () => {
  const wrapper = mount(<ActiveDocsSpec url={url} accountDataUrl={accountDataUrl} />)
  expect(wrapper.find(ActiveDocsSpec).exists()).toBe(true)
  expect(wrapper).toMatchSnapshot()
})

it('should render swagger-ui', () => {
  const wrapper = mount(<ActiveDocsSpec url={url} accountDataUrl={accountDataUrl}/>)
  expect(wrapper.find('.swagger-ui').exists()).toBe(true)
  expect(wrapper).toMatchSnapshot()
})
