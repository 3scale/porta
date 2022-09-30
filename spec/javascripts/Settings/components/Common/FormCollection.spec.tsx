import { FunctionComponent } from 'react'
import { shallow } from 'enzyme'

import { FormCollection, Props } from 'Settings/components/Common/FormCollection'
import { FieldGroupProps } from 'Settings/types'

it('should render correctly', () => {
  const GoodBand: FunctionComponent<FieldGroupProps> = ({ name }) => <span>{name} rocks!</span>

  const props: Props = {
    legend: 'Some Good Bands',
    ItemComponent: GoodBand,
    collection: [
      { name: 'The Rolling Stones' },
      { name: 'The Brian Jonestown Massacre' },
      { name: 'Radiohead' },
      { name: 'Blur' },
      { name: 'The Clash' }
    ] as FieldGroupProps[]
  }

  const view = shallow(<FormCollection {...props} />)
  expect(view).toMatchSnapshot()
})
