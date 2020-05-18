import React, { useState } from 'react'
import { Redirect } from 'react-router-dom'
import { useAuth } from 'auth'
import { useTranslation } from 'i18n/useTranslation'
import { useDocumentTitle } from 'components/util'
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  TextInput,
  LoginPage
} from '@patternfly/react-core'
import brandImg from 'assets/logo.svg'
import BackgroundImageSrcLg from 'assets/images/pfbg_1200.jpg'
import BackgroundImageSrcSm from 'assets/images/pfbg_768.jpg'
import BackgroundImageSrcSm2x from 'assets/images/pfbg_768@2x.jpg'
import BackgroundImageSrcXs from 'assets/images/pfbg_576.jpg'
import BackgroundImageSrcXs2x from 'assets/images/pfbg_576@2x.jpg'

const backgroundImages = {
  lg: BackgroundImageSrcLg,
  sm: BackgroundImageSrcSm,
  sm2x: BackgroundImageSrcSm2x,
  xs: BackgroundImageSrcXs,
  xs2x: BackgroundImageSrcXs2x
}

interface ILoginForm {
  token: string
  onChange: (value: string) => void
  onClick: () => void
}

const LoginForm: React.FunctionComponent<ILoginForm> = ({
  token,
  onChange,
  onClick
}) => {
  const { t } = useTranslation('login')
  return (
    <Form>
      <FormGroup label={t('form_label_token')} isRequired fieldId="simple-form-name">
        <TextInput
          isRequired
          type="text"
          id="token"
          name="token"
          value={token}
          onChange={onChange}
        />
        <ActionGroup>
          <Button onClick={onClick} variant="primary">{t('shared:buttons.submit')}</Button>
          <Button variant="secondary">{t('shared:buttons.cancel')}</Button>
        </ActionGroup>
      </FormGroup>
    </Form>
  )
}

const Login: React.FunctionComponent = () => {
  const { authToken, setAuthToken } = useAuth()

  if (authToken) {
    return <Redirect to="/" />
  }

  const [token, setToken] = useState('')
  const { t } = useTranslation('login')
  useDocumentTitle(t('page_title'))

  function postLogin() { // TODO: Here's the place to get and validate the token before saving it.
    setAuthToken(token)
  }

  return (
    <LoginPage
      brandImgSrc={brandImg}
      brandImgAlt={t('brand_img_alt')}
      backgroundImgSrc={backgroundImages}
      backgroundImgAlt={t('background_img_alt')}
      loginTitle={t('login_title')}
      loginSubtitle={t('login_subtitle')}
      textContent={t('text_content')}
    >
      <LoginForm
        token={token}
        onChange={setToken}
        onClick={postLogin}
      />
    </LoginPage>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default Login
