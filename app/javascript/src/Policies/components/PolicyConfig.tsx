import Form from '@rjsf/core'
import { customizeValidator } from '@rjsf/validator-ajv6'

import { isNotApicastPolicy } from 'Policies/util'

import type { JSONSchema7 } from 'json-schema'
import type { RJSFSchema } from '@rjsf/utils'
import type { IChangeEvent } from '@rjsf/core'
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

const policyValidator = customizeValidator<JSONSchema7, RJSFSchema, never>()

const PolicyConfig: React.FunctionComponent<Props> = ({
  policy,
  actions
}) => {
  const { submitPolicyConfig, updatePolicyConfig } = actions
  const { version, summary, description, enabled, configuration, data } = policy

  const onSubmit = (chainPolicy: ChainPolicy) => {
    return (formData: IChangeEvent<JSONSchema7, JSONSchema7, never>) => {
      submitPolicyConfig({ ...chainPolicy, configuration: formData.schema, data: formData.formData })
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
          validator={policyValidator}
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
