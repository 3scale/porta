import { mount } from 'enzyme'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'

describe('FormFieldset', () => {
  it('should render default form fieldset variant', () => {
    const view = mount(
      <FormFieldset>
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render inline form fieldset variant', () => {
    const view = mount(
      <FormFieldset isInline>
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })

  it('should render form fieldset with custom class names', () => {
    const view = mount(
      <FormFieldset className="extra-class another-class">
        <input id="input-id" />
      </FormFieldset>
    )
    expect(view).toMatchSnapshot()
  })
})
