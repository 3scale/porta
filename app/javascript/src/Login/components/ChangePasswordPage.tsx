import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  LoginPage,
  TextInput
} from '@patternfly/react-core'
import { useState } from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'
import brandImg from 'Login/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'Login/assets/images/PF4DownstreamBG.svg'
import { CSRFToken } from 'utilities/CSRFToken'
import { validateChangePassword } from 'Login/utils/validations'
import { LoginAlert } from 'Login/components/FormAlert'

import type { FunctionComponent } from 'react'
import type { FlashMessage } from 'Types'

interface Props {
  lostPasswordToken?: string | null;
  url?: string;
  errors?: FlashMessage[];
}

const emptyArray = [] as never[]

const ChangePasswordPage: FunctionComponent<Props> = ({
  lostPasswordToken = null,
  url,
  errors = emptyArray
}) => {
  const [state, setState] = useState({
    password: '',
    passwordConfirmation: ''
  })
  const [validationVisibility, setValidationVisibility] = useState({
    password: false,
    passwordConfirmation: false
  })

  const handleOnChange = (field: keyof typeof state) => {
    return (value: string) => {
      setState(prev => ({ ...prev, [field]: value }))
      setValidationVisibility(prev => ({ ...prev, [field]: false }))
    }
  }

  const handleOnBlur = (field: keyof typeof state) => {
    return () => {
      setValidationVisibility(prev => ({ ...prev, [field]: true }))
    }
  }

  const error = errors.length ? errors[0] : undefined

  const validation = validateChangePassword(state)

  const passwordErrors = validation?.password
  const passwordConfirmationErrors = validation?.passwordConfirmation

  const passwordValidated = (validationVisibility.password && passwordErrors) ? 'error' : 'default'
  const passwordConfirmationValidated = (validationVisibility.passwordConfirmation && passwordConfirmationErrors) ? 'error' : 'default'

  return (
    <LoginPage
      backgroundImgAlt="Red Hat 3scale API Management"
      backgroundImgSrc={PF4DownstreamBG}
      brandImgAlt="Red Hat 3scale API Management"
      brandImgSrc={brandImg}
      loginTitle="Change Password"
    >
      <Form
        noValidate
        acceptCharset="UTF-8"
        action={url}
        id="edit_user_2"
        method="post"
      >
        <LoginAlert error={error} />

        <input name="_method" type="hidden" value="put" />
        <input name="utf8" type="hidden" value="✓" />
        <CSRFToken />

        <FormGroup
          isRequired
          autoComplete="off"
          fieldId="user_password"
          helperTextInvalid={passwordErrors?.[0]}
          label="Password"
          validated={passwordValidated}
        >
          <TextInput
            autoFocus
            isRequired
            autoComplete="off"
            id="user_password"
            name="user[password]"
            type="password"
            validated={passwordValidated}
            value={state.password}
            onBlur={handleOnBlur('password')}
            onChange={handleOnChange('password')}
          />
        </FormGroup>

        <FormGroup
          isRequired
          autoComplete="off"
          fieldId="user_password_confirmation"
          helperTextInvalid={passwordConfirmationErrors?.[0]}
          label="Password confirmation"
          validated={passwordConfirmationValidated}
        >
          <TextInput
            isRequired
            autoComplete="off"
            id="user_password_confirmation"
            name="user[password_confirmation]"
            type="password"
            validated={passwordConfirmationValidated}
            value={state.passwordConfirmation}
            onBlur={handleOnBlur('passwordConfirmation')}
            onChange={handleOnChange('passwordConfirmation')}
          />
        </FormGroup>

        {!!lostPasswordToken && <input id="password_reset_token" name="password_reset_token" type="hidden" value={lostPasswordToken} />}
        <ActionGroup>
          <Button
            isBlock
            isDisabled={validation !== undefined}
            type="submit"
            variant="primary"
          >
            Change Password
          </Button>
        </ActionGroup>
      </Form>
    </LoginPage>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ChangePasswordWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ChangePasswordPage {...props} />, containerId) }

export type { Props }
export { ChangePasswordPage, ChangePasswordWrapper }
