
import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  redirectUrl: string,
  setRedirectUrl: (arg1: string) => void
}

const RedirectUrlInput = (
  {
    redirectUrl,
    setRedirectUrl
  }: Props
): React.ReactElement => (
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
