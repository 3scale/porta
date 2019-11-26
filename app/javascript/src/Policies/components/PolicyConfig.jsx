// @flow

import React from 'react'
import Form from 'react-jsonschema-form'
import { isNotApicastPolicy } from 'Policies/components/util'
import { HeaderButton } from 'Policies/components/HeaderButton'
import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

type Props = {
  policy: ChainPolicy,
  actions: {
    submitPolicyConfig: (ChainPolicy) => ThunkAction,
    removePolicyFromChain: (ChainPolicy) => ThunkAction,
    closePolicyConfig: () => ThunkAction,
    updatePolicyConfig: (ChainPolicy) => UpdatePolicyConfigAction
  }
}

const PolicyConfig = ({policy, actions}: Props) => {
  const { submitPolicyConfig, removePolicyFromChain, closePolicyConfig, updatePolicyConfig } = actions
  const { humanName, version, summary, description, enabled, configuration, data, removable } = policy

  const onSubmit = (policy) => {
    return ({formData, schema}) => {
      submitPolicyConfig({...policy, configuration: schema, data: formData})
    }
  }
  const togglePolicy = (event) => {
    updatePolicyConfig({...policy, enabled: event.target.checked})
  }
  const remove = () => removePolicyFromChain(policy)
  const cancel = () => closePolicyConfig()

  const isPolicyVisible = isNotApicastPolicy(policy)

  return (
    <section className="PolicyConfiguration">
      <header>
        <h2>Edit Policy</h2>
        <HeaderButton type="cancel" onClick={cancel}>
          Cancel
        </HeaderButton>
      </header>
      <h2 className="PolicyConfiguration-name">{humanName}</h2>
      <p className="PolicyConfiguration-version-and-summary">
        <span className="PolicyConfiguration-version">{version}</span>
        {' - '}
        <span className="PolicyConfiguration-summary">{summary}</span>
      </p>
      <p className="PolicyConfiguration-description">{description}</p>
      { isPolicyVisible &&
        <label className="Policy-status" htmlFor="policy-enabled">
          <input
            id="policy-enabled"
            name="policy-enabled"
            type="checkbox"
            checked={enabled}
            onChange={togglePolicy}
          />
          {' '} Enabled
        </label>
      }
      { isPolicyVisible &&
        <Form
          className="PolicyConfiguration-form"
          schema={configuration}
          formData={data}
          onSubmit={onSubmit(policy)}
        >
          <button className="btn btn-info" type="submit">Update Policy</button>
        </Form>
      }
      { removable &&
        <div
          className="PolicyConfiguration-remove btn btn-danger btn-sm"
          onClick={remove}
        >
          <i className="fa fa-trash"/> Remove
        </div>
      }
    </section>
  )
}

export { PolicyConfig }
