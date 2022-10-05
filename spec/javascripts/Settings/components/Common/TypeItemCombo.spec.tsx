import { shallow } from 'enzyme'
import { TypeItemCombo } from 'Settings/components/Common/TypeItemCombo'

it('should render correctly', () => {
  const props = {
    type: {
      value: 'run_the_jewels_3',
      name: 'run_the_jewels_album',
      label: 'Your RTJ favourite album',
      catalog: {
        run_the_jewels_1: 'Run The Jewels I',
        run_the_jewels_2: 'Run The Jewels II',
        run_the_jewels_3: 'Run The Jewels III'
      }
    },
    item: {
      value: 'Thursday in the Danger Room',
      name: 'song_name',
      label: 'Your favourite song from the album above ^',
      placeholder: 'Oh Mama',
      hint: 'Enter your favourite song from the album selected'
    },
    legend: 'Legend has it!'
  }
  const view = shallow(<TypeItemCombo {...props} />)
  expect(view).toMatchSnapshot()
})
