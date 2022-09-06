// @flow

import * as React from 'react'
import { KeyIcon, LessThanIcon, GreaterThanIcon } from '@patternfly/react-icons'

export type ProvidersProps = {
  authorizeURL: string,
  humanKind: string
}

type Props = {
  authenticationProviders: Array<ProvidersProps>
}

const Provider = ({ authorizeURL, humanKind }: {authorizeURL: string, humanKind: string}) => {
  return (
    <p className='login-provider'>
      <a className='login-provider-link' href={authorizeURL}>
        <KeyIcon/>{' Authenticate through '}
        <LessThanIcon/><GreaterThanIcon/>{humanKind}
      </a>
    </p>
  )
}

const AuthenticationProviders = (props: Props): React.Node => {
  const { authenticationProviders } = props
  const providersList = authenticationProviders.map(
    provider => <Provider authorizeURL={provider.authorizeURL} humanKind={provider.humanKind} key={provider.humanKind}/>
  )

  return (
    <React.Fragment>
      <div className='providers-list'>
        {providersList}
      </div>
    </React.Fragment>
  )
}

export { AuthenticationProviders }
