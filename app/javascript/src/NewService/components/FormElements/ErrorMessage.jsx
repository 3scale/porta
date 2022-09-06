// @flow

import * as React from 'react'

const ErrorMessage = ({ fetchErrorMessage }: {
  fetchErrorMessage: string
}): React.Node => (
  <p className='errorMessage'>
    {`Sorry, your request has failed with the error: ${fetchErrorMessage}`}
  </p>
)

export {
  ErrorMessage
}
