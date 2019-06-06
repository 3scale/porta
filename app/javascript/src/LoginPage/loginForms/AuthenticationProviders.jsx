// @flow

import React from 'react'

import { Card, CardBody } from '@patternfly/react-core'
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
    <Card>
      <CardBody>
        <a className='authentication-link' href={authorizeURL}>
          <KeyIcon/>{' Authenticate through '}
          <LessThanIcon/><GreaterThanIcon/>{humanKind}
        </a>
      </CardBody>
    </Card>
  )
}

const AuthenticationProviders = (props: Props) => {
  const {authenticationProviders} = props
  const providersList = authenticationProviders.map(
    provider => <Provider authorizeURL={provider.authorize_url} humanKind={provider.human_kind} key={provider.human_kind}/>
  )

  return (
    <React.Fragment>
      <h3>Please use your single sign-on LDAP credentials</h3>
      <div className='providers-list'>
        {providersList}
      </div>
    </React.Fragment>
  )
}

export {AuthenticationProviders}
