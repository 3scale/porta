// @flow

import * as React from 'react'

const HiddenServiceDiscoveryInput = (): React.Node =>
  <input
    value='discover'
    type='hidden'
    name='service[source]'
    id='service_source'
  />

export { HiddenServiceDiscoveryInput }
