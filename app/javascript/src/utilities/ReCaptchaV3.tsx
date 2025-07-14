import { useState } from 'react'

import { useScript } from 'utilities/useScript'

import type { FunctionComponent } from 'react'

interface Props {
  siteKey: string;
  action: string;
}

const ReCaptchaV3: FunctionComponent<Props> = ({ siteKey, action }) => {
  const inputId = `g-recaptcha-response-data-${action}`.replace(/\//g, '-')
  const inputName = `g-recaptcha-response-data[${action}]`
  const [token, setToken] = useState('')

  useScript(`https://www.google.com/recaptcha/api.js?render=${siteKey}`, () => {
    const { grecaptcha } = window
    grecaptcha.ready(() => {
      grecaptcha.execute(siteKey, { action: action })
        .then((t: string) => {
          setToken(t)
        })
        .catch((error: string) => { console.error(error) })
    })
  })

  return (
    <div>
      <small>
        This site is protected by reCAPTCHA and the Google <a href="https://policies.google.com/privacy">Privacy Policy</a> and <a href="https://policies.google.com/terms">Terms of Service</a> apply.
      </small>
      <input className="g-recaptcha g-recaptcha-response" data-sitekey={siteKey} id={inputId} name={inputName} type="hidden" value={token} />
    </div>
  )
}

export type { Props }
export { ReCaptchaV3 }
