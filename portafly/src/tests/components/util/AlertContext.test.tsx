import React from 'react'
import { AlertsProvider, useAlertsContext } from 'components'
import { render } from 'tests/custom-render'
import { waitFor } from '@testing-library/react'

const AlertComponent = () => {
  const { addAlert } = useAlertsContext()
  React.useEffect(() => addAlert({ id: 'id', title: 'title', variant: 'danger' }), [])
  return <></>
}

it('shows an alert that disappears after 8 seconds', async () => {
  jest.setTimeout(8001)
  const { getByText, queryByText } = render(
    <AlertsProvider>
      <AlertComponent />
    </AlertsProvider>
  )

  await waitFor(() => expect(getByText('title')).toBeInTheDocument(), { timeout: 7999 })
  waitFor(() => expect(queryByText('title')).not.toBeInTheDocument(), { timeout: 8001 })
})
