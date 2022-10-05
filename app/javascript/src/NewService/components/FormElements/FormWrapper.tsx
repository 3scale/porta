import { CSRFToken } from 'utilities/CSRFToken'
import { HiddenServiceDiscoveryInput } from 'NewService/components/FormElements'
import { Button } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'
import type { FormProps } from 'NewService/types'

const FormWrapper: FunctionComponent<FormProps> = (props) => {
  const { id, formActionPath, hasHiddenServiceDiscoveryInput, submitText } = props
  return (
    <form
      acceptCharset="UTF-8"
      action={formActionPath}
      className='formtastic service'
      id={id}
      method="post"
    >
      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />
      {hasHiddenServiceDiscoveryInput && <HiddenServiceDiscoveryInput />}
      <fieldset className="inputs" name="Service">
        <legend><span>Product</span></legend>
        <ol>
          {props.children}
        </ol>
      </fieldset>
      <fieldset className="buttons">
        <Button
          className="create"
          data-testid="newProductCreateProduct-buttonSubmit"
          name="commit"
          type="submit"
        >{ submitText }
        </Button>
      </fieldset>
    </form>
  )
}

export { FormWrapper }
