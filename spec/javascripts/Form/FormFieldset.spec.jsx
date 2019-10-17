import React from 'react'
import { mount } from 'enzyme'
import { FormFieldset } from 'Form/FormFieldset'

describe('FormFieldset', () => {
  it('should render default form fieldset variant', () => {
    const view = mount(
      <FormFieldset fieldId="label-id">
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render inline form fieldset variant', () => {
    const view = mount(
      <FormFieldset isInline fieldId="label-id">
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render form fieldset variant with node label and help text', () => {
    const view = mount(
      <FormFieldset fieldId="id" label={<span>Label</span>} helperText="this is helper text" >
        <input aria-label="input" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render form fieldset variant with node helperText', () => {
    const view = mount(
      <FormFieldset label="Label" fieldId="label-id" helperText={<span>Help text!</span>}>
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render form fieldset required variant', () => {
    const view = mount(
      <FormFieldset isRequired label="label" fieldId="id">
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render form fieldset invalid variant', () => {
    const view = mount(
      <FormFieldset label="label" fieldId="label-id" isValid={false} helperTextInvalid="Invalid FormFieldset">
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })
})
