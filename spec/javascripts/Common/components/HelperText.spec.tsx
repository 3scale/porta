import { mount } from 'enzyme'
import { HelperText, HelperTextItem } from 'Common/components/HelperText'

const mountWrapper = () => mount((
  <HelperText>
    <HelperTextItem>
      <div>
        Hello test
      </div>
    </HelperTextItem>
  </HelperText>
))

afterEach(() => jest.resetAllMocks())

it('should render correctly', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(HelperTextItem).text()).toEqual('Hello test')
})
