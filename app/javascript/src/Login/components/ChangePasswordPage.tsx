import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  HelperText,
  HelperTextItem,
  LoginPage,
  TextInput
} from '@patternfly/react-core'
import { useState } from 'react'

import { createReactWrapper } from 'utilities/createReactWrapper'
import brandImg from 'Login/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'Login/assets/images/PF4DownstreamBG.svg'
import { CSRFToken } from 'utilities/CSRFToken'
import { validateChangePassword } from 'Login/utils/validations'

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
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [validationVisibility, setValidationVisibility] = useState({
    password: false,
    passwordConfirmation: false
  })

  const onPasswordChange = (value: string) => {
    setPassword(value)
    setValidationVisibility(prev => ({ ...prev, password: false }))
  }

  const onPasswordConfirmationChange = (value: string) => {
    setPasswordConfirmation(value)
    setValidationVisibility(prev => ({ ...prev, passwordConfirmation: false }))
  }

  const error = errors.length ? errors[0] : undefined

  const validation = validateChangePassword({ password, passwordConfirmation })

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
        <HelperText className={error ? '' : 'invisible'}>
          <HelperTextItem hasIcon={error?.type === 'error'} variant={error?.type as 'error'}>
            {error?.message}
          </HelperTextItem>
        </HelperText>

        <input name="_method" type="hidden" value="put" />
        <input name="utf8" type="hidden" value="✓" />
        <CSRFToken />

        <FormGroup
          isRequired
          autoComplete="off"
          fieldId="user_password"
          helperTextInvalid={validation?.password?.[0]}
          label="Password"
          validated={(validationVisibility.password && validation?.password) ? 'error' : 'default'}
        >
          <TextInput
            autoFocus
            isRequired
            autoComplete="off"
            id="user_password"
            name="user[password]"
            type="password"
            validated={(validationVisibility.password && validation?.password) ? 'error' : 'default'}
            value={password}
            onBlur={() => { setValidationVisibility(prev => ({ ...prev, password: true })) }}
            onChange={onPasswordChange}
          />
        </FormGroup>

        <FormGroup
          isRequired
          autoComplete="off"
          fieldId="user_password_confirmation"
          helperTextInvalid={validation?.passwordConfirmation?.[0]}
          label="Password confirmation"
          validated={(validationVisibility.passwordConfirmation && validation?.passwordConfirmation) ? 'error' : 'default'}
        >
          <TextInput
            isRequired
            autoComplete="off"
            id="user_password_confirmation"
            name="user[password_confirmation]"
            type="password"
            validated={(validationVisibility.passwordConfirmation && validation?.passwordConfirmation) ? 'error' : 'default'}
            value={passwordConfirmation}
            onBlur={() => { setValidationVisibility(prev => ({ ...prev, passwordConfirmation: true })) }}
            onChange={onPasswordConfirmationChange}
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
