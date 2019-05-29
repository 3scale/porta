// @flow

import React from 'react'
import type {FormProps} from 'NewService/types'
import {CSRFToken} from 'utilities/utils'
import {HiddenServiceDiscoveryInput} from 'NewService/components/FormElements'

const FormWrapper = (props: FormProps) => {
  const {id, formActionPath, hasHiddenServiceDiscoveryInput, submitText} = props
  return (
    <form
      className='formtastic service'
      id={id}
      action={formActionPath}
      acceptCharset="UTF-8"
      method="post"
    >
      <input name="utf8" type="hidden" value="✓"/>
      <CSRFToken />
      {hasHiddenServiceDiscoveryInput && <HiddenServiceDiscoveryInput />}
      <fieldset className="inputs" name="Service">
        <legend><span>Service</span></legend>
        <ol>
          {props.children}
        </ol>
      </fieldset>
      <fieldset className="buttons">
        <input
          type="submit"
          name="commit"
          value={submitText}
          className="important-button create"/>
      </fieldset>
    </form>
  )
}

export {FormWrapper}
