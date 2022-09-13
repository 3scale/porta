import React from 'react'
import { shallow } from 'enzyme'

import { FormCollection } from 'Settings/components/Common'

it('should render correctly', () => {
  const GoodBand = ({ name }) => <span>{name} rocks!</span>

  const props = {
    legend: 'Some Good Bands',
    ItemComponent: GoodBand,
    collection: [
      { name: 'The Rolling Stones' },
      { name: 'The Brian Jonestown Massacre' },
      { name: 'Radiohead' },
      { name: 'Blur' },
      { name: 'The Clash' }
    ]
  }

  const view = shallow(<FormCollection {...props} />)
  expect(view).toMatchSnapshot()
})
