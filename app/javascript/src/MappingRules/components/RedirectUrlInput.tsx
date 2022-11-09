import { FormGroup, TextInput } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'
import type { TextInputProps } from '@patternfly/react-core'

interface Props {
  redirectUrl: TextInputProps['value'];
  setRedirectUrl: (redirectUrl: string) => void;
}

const RedirectUrlInput: FunctionComponent<Props> = ({
  redirectUrl,
  setRedirectUrl
}) => (
  <FormGroup
    fieldId="proxy_rule_redirect_url"
    label="Redirect URL"
    validated="default"
  >
    <TextInput
      id="proxy_rule_redirect_url"
      name="proxy_rule[redirect_url]"
      type="text"
      value={redirectUrl}
      onChange={setRedirectUrl}
    />
  </FormGroup>
)

export { RedirectUrlInput, Props }
