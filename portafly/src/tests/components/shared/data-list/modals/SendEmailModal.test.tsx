import React from 'react'

import { render } from 'tests/custom-render'
import { fireEvent } from '@testing-library/react'
import { SendEmailModal } from 'components'

it('should disable its submit button when any field is empty', () => {
  const { baseElement, getByText } = render(<SendEmailModal items={['test']} />)
  const subject = baseElement.querySelector('[name="subject"]') as HTMLElement
  const body = baseElement.querySelector('[name="body"]') as HTMLElement
  const submitButton = getByText('modals.send_email.send')

  expect(submitButton).toBeDisabled()

  fireEvent.change(subject, { target: { value: 'The subject' } })
  fireEvent.change(body, { target: { value: '' } })
  expect(submitButton).toBeDisabled()

  fireEvent.change(subject, { target: { value: '' } })
  fireEvent.change(body, { target: { value: 'The body' } })
  expect(submitButton).toBeDisabled()

  fireEvent.change(subject, { target: { value: 'The subject' } })
  expect(submitButton).not.toBeDisabled()
})
