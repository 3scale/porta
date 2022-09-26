import { State } from 'Policies/types'

export const initialState: State = {
  registry: [],
  chain: [],
  originalChain: [],
  policyConfig: {
    $schema: '',
    name: '',
    humanName: '',
    configuration: {},
    version: '',
    description: [''],
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
    submitButtonEnabled: false,
    error: {}
  }
}
