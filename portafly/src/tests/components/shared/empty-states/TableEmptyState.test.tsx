import React from 'react'

import { render } from 'tests/custom-render'
import { TableEmptyState } from 'components'
import { Button } from '@patternfly/react-core'
import { fireEvent } from '@testing-library/react'

it('should render', () => {
  const title = 'Title'
  const body = 'Body'
  const buttonTitle = 'Button'
  const onClick = jest.fn()
  const { getByText } = render(
    <TableEmptyState
      title={title}
      body={body}
      button={<Button onClick={onClick}>{buttonTitle}</Button>}
    />
  )

  expect(getByText(title)).toBeInTheDocument()
  expect(getByText(body)).toBeInTheDocument()

  const button = getByText(buttonTitle)
  fireEvent.click(button)
  expect(onClick).toHaveBeenCalled()
})
