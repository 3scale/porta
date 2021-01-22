// @flow

import React from 'react'

import { render, mount } from 'enzyme'
import { NewApplicationForm } from 'Applications/components/NewApplicationForm'

const products = [{ id: 0, name: 'API Product' }]
const applicationPlans = [{ id: 0, name: 'Basic Plan', issuer_id: products[0].id }]

const defaultProps = {
  createApplicationPath: '/applications/new',
  createServicePlanPath: '/accounts/:id/applications/new',
  products,
  applicationPlans,
  servicePlansAllowed: false,
  // servicesContracted: [],
  // servicePlanContractedForService: [],
  buyerId: 12345
}

it('should render properly', () => {
  const wrapper = mount(<NewApplicationForm {...defaultProps} />)
  expect(wrapper.exists()).toBe(true)
})

it('should be able to submit only when form is complete', () => {
  const wrapper = mount(<NewApplicationForm {...defaultProps} />)
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)

  // wrapper.find('input[name="cinstance[name]"]').simulate('change', { currentTarget: { value: 'My Application' } })
  // wrapper.find('select#product').simulate('change', { target: { value: products[0].id } })
  // wrapper.find('select[name="cinstance[plan_id]"]').simulate('change', applicationPlans[0].id)
  // expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(false)
})

describe('when in Account context', () => {
  const props = { ...defaultProps, buyerId: 12345 }

  it('should not render a select for Buyers', () => {
    const wrapper = render(<NewApplicationForm {...props} />)
    expect(wrapper.toString()).not.toContain('name="account_id"')
  })
})

describe('when in Applications context', () => {
  const props = { ...defaultProps, buyerId: undefined }

  it('should render a select for Buyers', () => {
    const wrapper = render(<NewApplicationForm {...props} />)
    expect(wrapper.toString()).toContain('name="account_id"')
  })
})

describe('when Service plans not allowed', () => {
  const props = { ...defaultProps, servicePlansAllowed: false }
})

describe('when Service plans allowed', () => {
  const props = { ...defaultProps, servicePlansAllowed: true }
})

// it('should display the current API on top', () => {
//   const wrapper = render(<NewApplicationForm {...defaultProps} />)
//   const sectionTitle = wrapper.find('.pf-c-nav__section-title').first()

//   expect(sectionTitle.text()).toBe(currentApi.name)
// })

// it('should display sections', () => {
//   const wrapper = render(<NewApplicationForm sections={sections} />)
//   const navItems = wrapper.find('.pf-c-nav__item')

//   expect(navItems.length).toBe(sections.length)
// })

// it('should display all sections closed by default', () => {
//   const wrapper = mount(<NewApplicationForm sections={sections} />)
//   expect(wrapper.find('.pf-m-expanded').exists()).toBe(false)

//   wrapper.setProps({ sections, activeSection: '0', activeItem: '0' })
//   wrapper.update()
//   expect(wrapper.find('.pf-m-expanded').exists()).toBe(true)
// })
