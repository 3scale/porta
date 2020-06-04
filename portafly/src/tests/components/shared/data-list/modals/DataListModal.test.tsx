import React from 'react'

import { render } from 'tests/custom-render'
import { fireEvent } from '@testing-library/react'
import { DataListModal } from 'components'

it('shows up to 5 items and a button to expand the list', () => {
  const items = new Array(10).fill('test').map((admin, i) => admin + i)
  const { getByText, getAllByText } = render(<DataListModal
    actions={[]}
    to="to"
    title="title"
    items={items}
    onClose={jest.fn()}
  />)
  const expandButton = getByText('modals.expand_list_button')
  expect(expandButton).toBeInTheDocument()
  expect(getAllByText(/test/).length).toBe(5)

  fireEvent.click(expandButton)
  expect(getAllByText(/test/).length).toBe(items.length)
})
