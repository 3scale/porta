// @flow

import React from 'react'
import { KeyIcon, LessThanIcon, GreaterThanIcon } from '@patternfly/react-icons'

type ProvidersProps = {
  authorize_url: string,
  human_kind: string
}

type Props = {
  authenticationProviders: Array<ProvidersProps>
}

const Provider = ({authorizeURL, humanKind}: {authorizeURL: string, humanKind: string}) => {
  return (
    <p className='login-provider'>
      <a className='login-provider-link' href={authorizeURL}>
        <KeyIcon/>{' Authenticate through '}
        <LessThanIcon/><GreaterThanIcon/>{humanKind}
      </a>
    </p>
  )
}

const AuthenticationProviders = (props: Props) => {
  const {authenticationProviders} = props
  const providersList = authenticationProviders.map(
    provider => <Provider authorizeURL={provider.authorize_url} humanKind={provider.human_kind} key={provider.human_kind}/>
  )

  return (
    <React.Fragment>
      <div className='providers-list'>
        {providersList}
      </div>
    </React.Fragment>
  )
}

export {AuthenticationProviders}
