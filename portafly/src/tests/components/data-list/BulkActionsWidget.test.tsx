import React from 'react'

import { render } from 'tests/custom-render'
import { BulkActionsWidget, BulkAction } from 'components/data-list'
import { fireEvent } from '@testing-library/react'
import { useDataListTable } from 'components/data-list/DataListContext'

jest.mock('components/data-list/DataListContext')

const actions = {
  sendEmail: 'Send email',
  changeState: 'Change status'
}

const selectAction = jest.fn()
const setup = (selectedRows: Array<any> = []) => {
  (useDataListTable as jest.Mock).mockReturnValue({ selectedRows })
  return render(<BulkActionsWidget actions={actions} selectAction={selectAction} />)
}

it('should render properly when closed', () => {
  const wrapper = setup()
  expect(wrapper.container.firstChild).toMatchSnapshot()
})

it('expands and collapses properly', () => {
  const wrapper = setup()
  expect(wrapper.queryByRole('menu')).not.toBeInTheDocument()

  const button = wrapper.getByRole('button')
  fireEvent.click(button)
  expect(wrapper.queryByRole('menu')).toBeInTheDocument()

  fireEvent.click(button)
  expect(wrapper.queryByRole('menu')).not.toBeInTheDocument()
})

describe('when it is disabled', () => {
  it('shows a warning inside the dropdown when opened', () => {
    const wrapper = setup()
    const button = wrapper.getByRole('button')
    fireEvent.click(button)
    expect(wrapper.getByText('bulk_actions.warning')).toBeInTheDocument()
  })
})

describe('when it is enabled', () => {
  it('shows the list of options when opened', () => {
    const wrapper = setup(['element'])
    const button = wrapper.getByRole('button')
    fireEvent.click(button)

    Object.keys(actions).forEach((key) => {
      expect(wrapper.getByText(actions[key as BulkAction])).toBeInTheDocument()
    })
  })
})
