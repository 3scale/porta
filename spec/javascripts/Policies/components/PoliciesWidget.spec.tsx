
import { PolicyList } from 'Policies/components/PoliciesWidget'
import { mount } from 'enzyme'

import type { Props } from 'Policies/components/PoliciesWidget'

it.todo('test PolicyWidget')

it('should render PolicyList', () => {
  const props: Props = {
    registry: [],
    chain: [],
    originalChain: [],
    policyConfig: {
      $schema: '$schema',
      configuration: {},
      description: [],
      name: 'human',
      summary: 'summary',
      version: '1',
      humanName: 'mr. human'
    },
    ui: {},
    boundActionCreators: {}
  } as any

  const wrapper = mount(<PolicyList {...props} />)
  expect(wrapper.exists()).toEqual(true)
})
