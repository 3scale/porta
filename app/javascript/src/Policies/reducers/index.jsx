// @flow

import { combineReducers } from 'redux'

import UISettingsReducer from './UISettings'
import RegistryReducer from './PolicyRegistry'
import PolicyConfigReducer from './PolicyConfig'
import ChainReducer from './PolicyChain'

const rootReducer = combineReducers({
  chain: ChainReducer,
  registry: RegistryReducer,
  policyConfig: PolicyConfigReducer,
  ui: UISettingsReducer
})

export default rootReducer
