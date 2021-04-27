// @flow

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  redirectUrl: string,
  setRedirectUrl: string => void
}

const RedirectUrlInput = ({ redirectUrl, setRedirectUrl }: Props): React.Node => (
  <FormGroup
    label="Redirect URL"
    validated="default"
    fieldId="proxy_rule_redirect_url"
  >
    <TextInput
      type="text"
      id="proxy_rule_redirect_url"
      name="proxy_rule[redirect_url]"
      value={redirectUrl}
      onChange={setRedirectUrl}
    />
  </FormGroup>
)

export { RedirectUrlInput }
