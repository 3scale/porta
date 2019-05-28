import React from 'react'

const Login3scaleForm = () => {
  return (
    <form
      className='pf-c-form'
      id='new_session'
      action='/p/sessions'
      acceptCharset='UTF-8'
      method='post'
    >
      <div className='pf-c-form__group'>
        <label
          className='pf-c-form__label'
          htmlFor='session_username'
        >
        Email or Username
          <span className='pf-c-form__label-required' aria-hidden='true'>*</span>
        </label>
        <input
          className='pf-c-form-control'
          name='username'
          id='session_username'
          type='text'
          tabIndex='1'
          autoFocus
          required
        />
      </div>
      <div>
        <label
          className='pf-c-form__label'
          htmlFor='session_password'>
        Password
          <span className='pf-c-form__label-required' aria-hidden='true'>*</span>
        </label>
        <input
          className='pf-c-form-control'
          name='password'
          tabIndex='2'
          id='session_password'
          type='password'
          required
        />
      </div>
      <div className='pf-c-form__group pf-m-action'>
        <div className='pf-c-form__actions'>
          <button
            className='pf-c-button pf-m-primary pf-m-block'
            type='submit'>
            Sign in
          </button>
        </div>
      </div>
    </form>
  )
}

export {
  Login3scaleForm
}
