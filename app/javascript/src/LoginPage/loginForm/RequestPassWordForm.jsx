import React from 'react'
import {CSRFToken} from 'utilities/utils'
import {LoginMainFooterBandItem} from '@patternfly/react-core'

const RequestPasswordForm = ({providerPasswordPath, providerLoginPath}) => {
  return (
    <form
      className='pf-c-form'
      action={providerPasswordPath}
      acceptCharset='UTF-8'
      method='post'
    >
      <input name="utf8" type="hidden" value="✓"/>
      <input type="hidden" name="_method" value="delete"/>
      <CSRFToken/>
      <div className='pf-c-form__group'>
        <label
          className='pf-c-form__label'
          htmlFor='email'
        >
        Email address

        </label>
        <input
          className='pf-c-form-control'
          id="email"
          type="email"
          name="email"
          autoFocus/>
        <p>
          Please enter the email address you used to sign up to this site.
          Instructions on how to reset your password will be sent by email.
        </p>
      </div>
      <div className='pf-c-form__group pf-m-action'>
        <div className='pf-c-form__actions'>
          <button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'>
              Reset password
          </button>
        </div>
      </div>
      <a href={providerLoginPath}>Sign in</a>
    </form>
  )
}

export {RequestPasswordForm}
