import * as React from 'react'

const HiddenServiceDiscoveryInput = (): React.ReactElement => <input
  value='discover'
  type='hidden'
  name='service[source]'
  id='service_source'
/>

export { HiddenServiceDiscoveryInput }
