// @flow

import React from 'react'
import Form from 'react-jsonschema-form'

import { isNotApicastPolicy } from 'Policies/components/util'

import type { ThunkAction } from 'Policies/types/index'
import type { ChainPolicy } from 'Policies/types/Policies'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

class PolicyForm extends Form {
  componentWillReceiveProps (nextProps: Props) {
    if (nextProps.schema !== this.state.schema) {
      this.setState({...this.getStateFromProps(nextProps), ...{errors: []}})
    }
  }
}

type Props = {
  schema?: string,
  visible: boolean,
  policy: ChainPolicy,
  submitForm: (ChainPolicy) => ThunkAction,
  removePolicy: (ChainPolicy) => ThunkAction,
  closePolicyConfig: () => ThunkAction,
  updatePolicy: (ChainPolicy) => UpdatePolicyConfigAction
}

function PoliciesForm ({
  visible, policy, submitForm, updatePolicy, removePolicy,
  closePolicyConfig}: Props) {
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

function hiddenClass (bool?: boolean): string {
  return bool ? '' : 'hidden'
}

export { PolicyForm, PoliciesForm }
