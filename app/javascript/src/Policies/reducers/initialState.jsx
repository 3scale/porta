// @flow

import type {State} from '../types/State'

export const initialState: State = {
  registry: [],
  chain: [],
  policyConfig: {
    $schema: '',
    schema: {},
    name: '',
    humanName: '',
    configuration: {},
    id: '',
    version: '',
    description: '',
    summary: '',
    enabled: true,
    removable: true,
    uuid: ''
  },
  ui: {
    registry: false,
    chain: true,
    policyConfig: false,
    requests: 0,
    error: {}
  }
}
