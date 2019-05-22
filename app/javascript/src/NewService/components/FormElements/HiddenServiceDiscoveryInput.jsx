// @flow

import React from 'react'

const HiddenServiceDiscoveryInput = () =>
  <input
    value='discover'
    type='hidden'
    name='service[source]'
    id='service_source'
  />

export {HiddenServiceDiscoveryInput}
