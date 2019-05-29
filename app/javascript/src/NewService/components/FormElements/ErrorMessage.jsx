// @flow

import React from 'react'

const ErrorMessage = ({fetchErrorMessage}: {
  fetchErrorMessage: string
}) => <p className='errorMessage'>
  {`Sorry, your request has failed with the error: ${fetchErrorMessage}`}
</p>

export {
  ErrorMessage
}
