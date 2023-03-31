import { GreaterThanIcon, KeyIcon, LessThanIcon } from '@patternfly/react-icons'

import type { FunctionComponent } from 'react'

export interface ProvidersProps {
  authorizeURL: string;
  humanKind: string;
}

interface Props {
  authenticationProviders: ProvidersProps[];
}

const Provider: FunctionComponent<ProvidersProps> = ({ authorizeURL, humanKind }) => (
  <p className="login-provider">
    <a className="login-provider-link" href={authorizeURL}>
      <KeyIcon />{' Authenticate through '}
      <LessThanIcon /><GreaterThanIcon />{humanKind}
    </a>
  </p>
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const AuthenticationProviders: FunctionComponent<Props> = (props) => {
  const { authenticationProviders } = props
  const providersList = authenticationProviders.map(
    provider => <Provider key={provider.humanKind} authorizeURL={provider.authorizeURL} humanKind={provider.humanKind} />
  )

  return (
    <div className="providers-list">
      {providersList}
    </div>
  )
}

export type { Props }
export { AuthenticationProviders }
