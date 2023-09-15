import Form from 'react-jsonschema-form'

import { isNotApicastPolicy } from 'Policies/util'

import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

interface Props {
  policy: ChainPolicy;
  actions: {
    submitPolicyConfig: (policy: ChainPolicy) => ThunkAction;
    removePolicyFromChain: (policy: ChainPolicy) => ThunkAction;
    closePolicyConfig: () => ThunkAction;
    updatePolicyConfig: (policy: ChainPolicy) => UpdatePolicyConfigAction;
  };
}

const PolicyConfig: React.FunctionComponent<Props> = ({
  policy,
  actions
}) => {
  const { submitPolicyConfig, updatePolicyConfig } = actions
  const { version, summary, description, enabled, configuration, data } = policy

  const onSubmit = (chainPolicy: ChainPolicy) => {
    return ({ formData, schema }: { formData: ChainPolicy['data']; schema: ChainPolicy['configuration'] }) => {
      submitPolicyConfig({ ...chainPolicy, configuration: schema, data: formData })
    }
  }
  const togglePolicy = (event: React.ChangeEvent<HTMLInputElement>) => {
    updatePolicyConfig({ ...policy, enabled: event.target.checked })
  }

  const isPolicyVisible = isNotApicastPolicy(policy)

  return (
    <section className="PolicyConfiguration">
      <p className="PolicyConfiguration-version-and-summary">
        {`${version} - ${summary || ''}`}
      </p>
      <p className="PolicyConfiguration-description">{description}</p>
      {isPolicyVisible && (
        <label className="Policy-status" htmlFor="policy-enabled">
          <input
            checked={enabled}
            id="policy-enabled"
            name="policy-enabled"
            type="checkbox"
            onChange={togglePolicy}
          />Enabled
        </label>
      )}
      {isPolicyVisible && (
        <Form
          className="PolicyConfiguration-form formtastic"
          formData={data}
          id="edit-policy-form"
          schema={configuration}
          onSubmit={onSubmit(policy)}
        >
          <span /> { /* Prevents rendering default submit button */ }
        </Form>
      )}
    </section>
  )
}

export type { Props }
export { PolicyConfig }
