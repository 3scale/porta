import { mount } from 'enzyme'
import { Alert } from '@patternfly/react-core'

import { FormAlert } from 'ActiveDocs/components/FormAlert'

it('should render itself', () => {
  const wrapper = mount(<FormAlert><Alert title="An alert" /></FormAlert>)

  expect(wrapper.find(Alert).props().title).toEqual('An alert')
})
