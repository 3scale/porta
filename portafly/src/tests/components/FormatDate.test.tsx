import * as React from 'react'
import { render } from 'tests/custom-render'
import { FormatDate } from 'components'
import { it as IT } from 'date-fns/locale'

describe('when date is UTC', () => {
  const dateISO: string = '2019-10-14T13:55:39.058' // Make UTC by not adding timezone at the end
  const dateISOInt: number = Date.parse(dateISO)
  const dateISODate: Date = new Date(dateISO)

  it('should render a date in an human readable way', () => {
    const result = '10/14/2019, 1:55 PM' // default locales is us-US

    const { queryByText, rerender } = render(<FormatDate date={dateISO} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISOInt} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISODate} />)
    expect(queryByText(result)).toBeInTheDocument()
  })

  it('should render the date accordingly to the passed format', () => {
    const format = 'dMy'
    const result = '14102019'

    const { queryByText, rerender } = render(<FormatDate date={dateISO} format={format} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISOInt} format={format} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISODate} format={format} />)
    expect(queryByText(result)).toBeInTheDocument()
  })

  it('should render the date respecting the date-fns config object', () => {
    const options = { locale: IT }
    const result = '14/10/2019 13:55'

    const { queryByText, rerender } = render(<FormatDate date={dateISO} options={options} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISOInt} options={options} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISODate} options={options} />)
    expect(queryByText(result)).toBeInTheDocument()
  })
})

// FIXME: use date-fns-tz OR change library OR fix it somehow
// By adding Z (UTC) to the ISO string, the date is automatically formatted
// using the browser's timezone. This makes it fail in CircleCI.
describe.skip('when date takes timezone into consideration', () => {
  const dateISO: string = '2019-10-14T13:55:39.058Z'
  const dateISOInt: number = Date.parse(dateISO)
  const dateISODate: Date = new Date(dateISO)

  it('should render a date in an human readable way', () => {
    const result = '10/14/2019, 1:55 PM'

    const { queryByText, rerender } = render(<FormatDate date={dateISO} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISOInt} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISODate} />)
    expect(queryByText(result)).toBeInTheDocument()
  })

  it('should render the date accordingly to the passed format', () => {
    const format = 'dMy'
    const result = '14102019'

    const { queryByText, rerender } = render(<FormatDate date={dateISO} format={format} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISOInt} format={format} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISODate} format={format} />)
    expect(queryByText(result)).toBeInTheDocument()
  })

  it('should render the date respecting the date-fns config object', () => {
    const options = { locale: IT }
    const result = '14/10/2019 13:55'

    const { queryByText, rerender } = render(<FormatDate date={dateISO} options={options} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISOInt} options={options} />)
    expect(queryByText(result)).toBeInTheDocument()

    rerender(<FormatDate date={dateISODate} options={options} />)
    expect(queryByText(result)).toBeInTheDocument()
  })
})
