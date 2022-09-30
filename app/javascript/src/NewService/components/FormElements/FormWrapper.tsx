import type { FormProps } from 'NewService/types'
import { CSRFToken } from 'utilities'
import { HiddenServiceDiscoveryInput } from 'NewService/components/FormElements'
import { Button } from '@patternfly/react-core'

const FormWrapper = (props: FormProps): React.ReactElement => {
  const { id, formActionPath, hasHiddenServiceDiscoveryInput, submitText } = props
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
        <legend><span>Product</span></legend>
        <ol>
          {props.children}
        </ol>
      </fieldset>
      <fieldset className="buttons">
        <Button
          data-testid="newProductCreateProduct-buttonSubmit"
          type="submit"
          name="commit"
          className="create">{ submitText }</Button>
      </fieldset>
    </form>
  )
}

export { FormWrapper }
