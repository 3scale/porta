// @flow

import React from 'react'
import { mount } from 'enzyme'
import SwaggerUI from 'swagger-ui-react'
import { ActiveDocsSpec } from 'ActiveDocs/components/ActiveDocsSpec'

const url = 'foo.example.com'
const responseInterceptor = jest.fn(() => () => {})

it('should render itself', () => {
  const wrapper = mount(<ActiveDocsSpec url={url} responseInterceptor={responseInterceptor} />)
  expect(wrapper.find(ActiveDocsSpec).exists()).toBe(true)
  expect(wrapper).toMatchSnapshot()
})

it('should render swagger-ui', () => {
  const wrapper = mount(<ActiveDocsSpec url={url} responseInterceptor={responseInterceptor}/>)
  expect(wrapper.find('.swagger-ui').exists()).toBe(true)
  expect(wrapper.find(SwaggerUI).prop('url')).toBe('foo.example.com')
  expect(typeof wrapper.find(SwaggerUI).prop('responseInterceptor')).toBe('function')
})
