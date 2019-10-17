// @flow

import React from 'react'
import { bindActionCreators } from 'redux'
import { actions } from 'Policies/actions/index'
import { PolicyConfig } from 'Policies/components/PolicyConfig'
import { PolicyChain } from 'Policies/components/PolicyChain'
import { PolicyRegistry } from 'Policies/components/PolicyRegistry'
import { PolicyChainHiddenInput } from 'Policies/components/PolicyChainHiddenInput'
import { connect } from 'react-redux'
import { isPolicyChainChanged } from 'Policies/util'

import type { ChainPolicy, State, RegistryState, ChainState, UIState, Dispatch, IPoliciesActions } from 'Policies/types'

type Props = {
  registry: RegistryState,
  chain: ChainState,
  originalChain: ChainState,
  policyConfig: ChainPolicy,
  ui: UIState,
  boundActionCreators: IPoliciesActions
}

const mapStateToProps = (state: State) => ({
  registry: state.registry,
  chain: state.chain,
  originalChain: state.originalChain,
  policyConfig: state.policyConfig,
  ui: state.ui
})

const mapDispatchToProps = (dispatch: Dispatch) => ({
  boundActionCreators: bindActionCreators(actions, dispatch)
})

const PolicyList = ({ registry, chain, originalChain, policyConfig, ui, boundActionCreators }: Props) => {
  const chainActions = {
    openPolicyRegistry: boundActionCreators.openPolicyRegistry,
    editPolicy: boundActionCreators.editPolicy,
    sortPolicyChain: boundActionCreators.sortPolicyChain
  }
  const policyConfigActions = {
    submitPolicyConfig: boundActionCreators.submitPolicyConfig,
    removePolicyFromChain: boundActionCreators.removePolicyFromChain,
    closePolicyConfig: boundActionCreators.closePolicyConfig,
    updatePolicyConfig: boundActionCreators.updatePolicyConfig
  }
  const policyRegistryActions = {
    addPolicy: boundActionCreators.addPolicy,
    closePolicyRegistry: boundActionCreators.closePolicyRegistry
  }

  const buttonsFieldset = document.querySelector('[id^="edit_proxy_"] > fieldset.buttons')
  if (buttonsFieldset) {
    // classList.toggle second argument is not supported in IE11
    if (ui.chain) {
      buttonsFieldset.classList.remove('is-hidden')
    } else {
      buttonsFieldset.classList.add('is-hidden')
    }
  }

  // HACK: enable the submit button after any change is made
  const submitButton = document.querySelector('#policies-button-sav')
  if (submitButton) {
    // classList.toggle second argument is not supported in IE11
    if (isPolicyChainChanged(chain, originalChain)) {
      submitButton.removeAttribute('disabled')
      submitButton.classList.remove('disabled-button')
      submitButton.classList.add('important-button')
    } else {
      submitButton.setAttribute('disabled', '')
      submitButton.classList.add('disabled-button')
      submitButton.classList.remove('important-button')
    }
  }

  return (
    <div className="PoliciesWidget">
      <PolicyChain
        chain={chain}
        visible={ui.chain}
        actions={chainActions}
      />
      <PolicyRegistry
        items={registry}
        visible={ui.registry}
        actions={policyRegistryActions}
      />
      <PolicyConfig
        visible={ui.policyConfig}
        policy={policyConfig}
        actions={policyConfigActions}
      />
      <PolicyChainHiddenInput policies={chain} />
    </div>
  )
}

// $FlowFixMe: Redux types should work out of the box
const PoliciesWidget = connect(
  mapStateToProps,
  mapDispatchToProps
)(PolicyList)

export default PoliciesWidget
