import React from 'react'
import {
  FormGroup
} from '@patternfly/react-core'

const Provider = ({href}) =>
  <div className='box'>
    <a href={href}>{`Authenticate through ${href}`}</a>
  </div>

const AuthenticationProviders = ({authenticationProviders}) => {
  const providersList = authenticationProviders.map(provider => <Provider href={provider.href} key={provider.href}/>)
  return (
    <FormGroup fieldId='kakaka'>
      {providersList}
    </FormGroup>
  )
}

export {AuthenticationProviders}
