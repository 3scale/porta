import { shallow } from 'enzyme'
import { FormLegend } from 'Settings/components/Common/FormLegend'

it('FormLegend', () => {
  const view = shallow(<FormLegend>I am Legendary</FormLegend>)
  expect(view).toMatchSnapshot()
})

it('FormLegend with additional class name', () => {
  const view = shallow(<FormLegend className="first-class">I am Legendary</FormLegend>)
  expect(view).toMatchSnapshot()
})

it('FormLegend with additional class name and props', () => {
  const view = shallow(
    <FormLegend className="first-class" data-label-name="Legendary" id="legendary">
      I am Legendary
    </FormLegend>
  )
  expect(view).toMatchSnapshot()
})
