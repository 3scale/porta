import * as React from 'react'
import { render } from 'tests/custom-render'
import { FormatDate } from 'components'
import it from 'date-fns/locale/it'

const dateISO = '2019-10-14T11:55:39.058Z'

// TODO: Fix tests to use TZ
describe('FormatDate tests', () => {
  test('should render the date string in an human readable way', async () => {
    const { getByText } = render(<FormatDate date={dateISO} />)
    expect(getByText('10/14/2019, 1:55 PM')).not.toBeUndefined()
  })

  test('should render the date string accordingly to the passed format', async () => {
    const { getByText } = render(<FormatDate date={dateISO} format="dMy" />)
    expect(getByText('14102019')).not.toBeUndefined()
  })

  test('should render the date string respecting the date-fns config object', async () => {
    const { getByText } = render(
      <FormatDate date={dateISO} options={{ locale: it }} />
    )
    expect(getByText('14/10/2019 13:55')).not.toBeUndefined()
  })
})
