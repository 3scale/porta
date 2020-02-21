import * as React from 'react'
import { render } from '@test/setup'
import { FormatDate } from '@src'
import it from 'date-fns/locale/it'

const dateISO = '2019-10-14T11:55:39.058Z'

// TODO: Fix tests to use TZ
xdescribe('FormatDate tests', () => {
  test('should render the date string in an human readable way', async () => {
    const { getByText } = render(<FormatDate date={dateISO} />)
    getByText('10/14/2019, 1:55 PM')
  })

  test('should render the date string accordingly to the passed format', async () => {
    const { getByText } = render(<FormatDate date={dateISO} format={'dMy'} />)
    getByText('14102019')
  })

  test('should render the date string respecting the date-fns config object', async () => {
    const { getByText } = render(
      <FormatDate date={dateISO} options={{ locale: it }} />
    )
    getByText('14/10/2019 13:55')
  })
})
