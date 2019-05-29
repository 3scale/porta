import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import {CSRFToken} from 'utilities/utils'
import {JSDOM} from 'jsdom'
Enzyme.configure({ adapter: new Adapter() })

describe('CSRFToken', () => {
  function setup () {
    const jsdom = new JSDOM(
      `<!doctype html><html>
         <head><meta name="csrf-param" content="authenticity_token"><meta name="csrf-token" content="=42="></head>
         <body></body>
       </html>`
    )
    const { window } = jsdom
    return mount(<CSRFToken win={window} />)
  }

  it('should render itself correctly', () => {
    const wrapper = setup()
    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBe('authenticity_token')
    expect(wrapper.find('input').prop('value')).toBe('=42=')
  })

  it('should return null values when csrf-param meta tag is not present', () => {
    const { window } = new JSDOM(
      `<!doctype html><html>
         <head></head>
         <body></body>
       </html>`
    )
    const wrapper = mount(<CSRFToken win={window} />)
    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBe(null)
    expect(wrapper.find('input').prop('value')).toBe(null)
  })
})
