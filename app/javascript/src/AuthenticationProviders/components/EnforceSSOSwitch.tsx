/* eslint-disable react/jsx-curly-newline */
import {
  Alert,
  Spinner,
  Stack,
  StackItem,
  Switch
} from '@patternfly/react-core'

import type { SwitchProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'

interface Props extends Required<Pick<SwitchProps, 'isChecked' | 'isDisabled'>> {
  onChange: (checked: boolean) => void;
  isLoading: boolean;
}

const EnforceSSOSwitch: FunctionComponent<Props> = ({
  onChange,
  isChecked,
  isDisabled,
  isLoading
}) => {
  return (
    <Stack hasGutter>
      <StackItem>
        <Switch
          id="settings_enforce_sso"
          isChecked={isChecked}
          isDisabled={isLoading || isDisabled}
          label={(
            <>
              Disable password-based authentication for all users of this account {isLoading && <Spinner isInline isSVG />}
            </>
          )}
          name="settings[enforce_sso]"
          onChange={onChange}
        />
      </StackItem>
      {isDisabled && (
        <StackItem>
          <Alert
            isInline
            title="To disable password-based authentication, make sure you have a published SSO integration that was tested within the last hour. Then, sign in using SSO."
            variant="info"
          />
        </StackItem>
      )}
      {isChecked && (
        <StackItem>
          <Alert
            isInline
            title="In order to edit active Single Sign-On integrations, first enable password-based authentication."
            variant="info"
          />
        </StackItem>
      )}
    </Stack>
  )
}

export type { Props }
export { EnforceSSOSwitch }
