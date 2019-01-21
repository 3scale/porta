// @flow

import { combineReducers } from 'redux'

import UISettingsReducer from 'Policies/reducers/UISettings'
import RegistryReducer from 'Policies/reducers/PolicyRegistry'
import PolicyConfigReducer from 'Policies/reducers/PolicyConfig'
import ChainReducer from 'Policies/reducers/PolicyChain'

// $FlowFixMe: Redux types should work out of the box
const rootReducer = combineReducers({
  chain: ChainReducer,
  registry: RegistryReducer,
  policyConfig: PolicyConfigReducer,
  ui: UISettingsReducer
})

export default rootReducer
