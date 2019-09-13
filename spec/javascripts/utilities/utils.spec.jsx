import React from 'react'
import { mount } from 'enzyme'
import { JSDOM } from 'jsdom'

const { CSRFToken } = jest.requireActual('utilities/utils')

describe('CSRFToken', () => {
  it('should render itself correctly', () => {
    const { window } = new JSDOM(`
      <!doctype html>
      <html>
        <head>
          <meta name="csrf-param" content="authenticity_token">
          <meta name="csrf-token" content="=42=">
        </head>
        <body></body>
      </html>
    `)
    const wrapper = mount(<CSRFToken win={window} />)

    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBe('authenticity_token')
    expect(wrapper.find('input').prop('value')).toBe('=42=')
  })

  it('should return undefined values when csrf-param meta tag is not present', () => {
    const { window } = new JSDOM(`
      <!doctype html>
      <html>
        <head></head>
        <body></body>
      </html>
    `)
    const wrapper = mount(<CSRFToken win={window} />)

    expect(wrapper.find(CSRFToken).exists()).toBe(true)
    expect(wrapper.find('input').prop('name')).toBeUndefined()
    expect(wrapper.find('input').prop('value')).toBeUndefined()
  })
})
