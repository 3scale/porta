import { createReactWrapper } from 'utilities/createReactWrapper'
import { ActionGroup, Button, Form, LoginPage } from '@patternfly/react-core'
import { useFormState } from 'ChangePassword/components/ChangePasswordHooks'
import { FlashMessages } from 'LoginPage/loginForms/FlashMessages'
import { PasswordField, PasswordConfirmationField } from 'LoginPage/loginForms/FormGroups'
import { HiddenInputs } from 'LoginPage/loginForms/HiddenInputs'
import brandImg from 'LoginPage/assets/images/3scale_Logo_Reverse.png'
import PF4DownstreamBG from 'LoginPage/assets/images/PF4DownstreamBG.svg'
import 'LoginPage/assets/styles/loginPage.scss'

import type { FlashMessage, InputProps } from 'Types'
import type { FunctionComponent } from 'react'

interface Props {
  lostPasswordToken?: string | null;
  url?: string;
  errors?: FlashMessage[];
}

const ChangePassword: FunctionComponent<Props> = ({
  lostPasswordToken = null,
  url = '',
  errors = []
}) => {
  const {
    isFormDisabled,
    onFormChange,
    password,
    passwordConfirmation
  } = useFormState()

  const passwordProps: InputProps = {
    isRequired: true,
    name: 'user[password]',
    fieldId: 'user_password',
    label: 'Password',
    value: password.value,
    isValid: password.isValid,
    errorMessage: password.errorMessage,
    autoFocus: true,
    onBlur: password.onBlur,
    onChange: password.onChange
  }

  const passwordConfirmationProps = {
    isRequired: true,
    name: 'user[password_confirmation]',
    fieldId: 'user_password_confirmation',
    label: 'Password confirmation',
    value: passwordConfirmation.value,
    isValid: passwordConfirmation.isValid,
    errorMessage: passwordConfirmation.errorMessage,
    onBlur: passwordConfirmation.onBlur,
    onChange: passwordConfirmation.onChange
  }

  return (
    <LoginPage
      backgroundImgAlt="Red Hat 3scale API Management"
      backgroundImgSrc={PF4DownstreamBG}
      brandImgAlt="Red Hat 3scale API Management"
      brandImgSrc={brandImg}
      loginTitle="Change Password"
    >
      {errors.length && <FlashMessages flashMessages={errors} />}
      <Form
        noValidate
        acceptCharset="UTF-8"
        action={url}
        id="edit_user_2"
        method="post"
        onChange={onFormChange}
      >
        <input name="_method" type="hidden" value="put" />
        <HiddenInputs />
        <PasswordField inputProps={passwordProps} />
        <PasswordConfirmationField inputProps={passwordConfirmationProps} />
        {!!lostPasswordToken && <input id="password_reset_token" name="password_reset_token" type="hidden" value={lostPasswordToken} />}
        <ActionGroup>
          <Button
            className="pf-c-button pf-m-primary pf-m-block"
            isDisabled={isFormDisabled}
            name="commit"
            type="submit"
          >
          Change Password
          </Button>
        </ActionGroup>
      </Form>
    </LoginPage>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ChangePasswordWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ChangePassword {...props} />, containerId) }

export { ChangePassword, ChangePasswordWrapper, Props }
