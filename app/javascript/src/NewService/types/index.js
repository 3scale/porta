// @flow

import * as React from 'react'

export type FormProps = {
  id: string,
  formActionPath: string,
  hasHiddenServiceDiscoveryInput?: boolean,
  submitText: string,
  children?: React.Node
}
