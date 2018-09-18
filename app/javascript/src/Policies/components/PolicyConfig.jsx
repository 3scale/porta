// @flow

import React from 'react'
import Form from 'react-jsonschema-form'

import type { ThunkAction } from '../types/index'
import type { ChainPolicy } from '../types/Policies'
import type { UpdatePolicyConfigAction } from '../actions/PolicyConfig'

import { isNotApicastPolicy } from './util'

type Props = {
  visible: boolean,
  policy: ChainPolicy,
  actions: {
    submitPolicyConfig: (ChainPolicy) => ThunkAction,
    removePolicyFromChain: (ChainPolicy) => ThunkAction,
    closePolicyConfig: () => ThunkAction,
    updatePolicyConfig: (ChainPolicy) => UpdatePolicyConfigAction
  }
}

function hiddenClass (bool: boolean): string {
  return bool ? '' : 'hidden'
}

class PolicyForm extends Form {
  componentWillReceiveProps (nextProps: Object) {
    if (nextProps.schema !== this.state.schema) {
      this.setState({...this.getStateFromProps(nextProps), ...{errors: []}})
    }
  }
}

function PoliciesForm ({
  visible, policy, submitForm, updatePolicy, removePolicy,
  closePolicyConfig}) {
  const onSubmit = (policy) => {
    return ({formData, schema}) => {
      submitForm({...policy, ...{schema, configuration: formData}})
    }
  }
  const togglePolicy = (event) => {
    updatePolicy({...policy, ...{enabled: event.target.checked}})
  }
  const remove = () => removePolicy(policy)
  const cancel = () => closePolicyConfig()

  return (
    <section className={`PolicyConfiguration ${hiddenClass(visible)}`}>
      <header className="PolicyConfiguration-header">
        <h2 className="PolicyConfiguration-title">Edit Policy</h2>
        <div onClick={cancel} className="PolicyConfiguration-cancel"><i className="fa fa-times-circle"></i> Cancel</div>
      </header>
      <h2 className="PolicyConfiguration-name">{policy.humanName}</h2>
      <p className="PolicyConfiguration-version-and-summary">
        <span className="PolicyConfiguration-version">{policy.version}</span>
        {' - '}
        <span className="PolicyConfiguration-summary">{policy.summary}</span>
      </p>
      <p className="PolicyConfiguration-description">{policy.description}</p>
      <label className={`${hiddenClass(isNotApicastPolicy(policy))} Policy-status`} htmlFor="policy-enabled">
        <input
          id="policy-enabled" name="policy-enabled" type="checkbox"
          checked={policy.enabled}
          onChange={togglePolicy}
        />
        {' '} Enabled
      </label>
      <PolicyForm
        className={`PolicyConfiguration-form ${hiddenClass(isNotApicastPolicy(policy))}`}
        schema={policy.schema}
        formData={policy.configuration}
        onSubmit={onSubmit(policy)}
      >
        <button className='btn btn-info' type="submit">Update Policy</button>
      </PolicyForm>
      <div
        className={`PolicyConfiguration-remove btn btn-danger btn-sm ${hiddenClass(policy.removable)}`}
        onClick={remove}>
        <i className="fa fa-trash"></i> Remove
      </div>
    </section>
  )
}

const PolicyConfig = ({visible, policy, actions}: Props) => {
  return (<PoliciesForm
    visible={visible}
    policy={policy}
    submitForm={actions.submitPolicyConfig}
    removePolicy={actions.removePolicyFromChain}
    closePolicyConfig={actions.closePolicyConfig}
    updatePolicy={actions.updatePolicyConfig}
  />)
}

export { PolicyConfig, PolicyForm }
