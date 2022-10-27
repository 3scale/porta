import Form from 'react-jsonschema-form'
import { Button } from '@patternfly/react-core'
import { isNotApicastPolicy } from 'Policies/util'
import { HeaderButton } from 'Policies/components/HeaderButton'

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
  const { submitPolicyConfig, removePolicyFromChain, closePolicyConfig, updatePolicyConfig } = actions
  const { humanName, version, summary, description, enabled, configuration, data, removable } = policy

  const onSubmit = (chainPolicy: ChainPolicy) => {
    return ({ formData, schema }: { formData: ChainPolicy['data']; schema: ChainPolicy['configuration'] }) => {
      submitPolicyConfig({ ...chainPolicy, configuration: schema, data: formData })
    }
  }
  const togglePolicy = (event: React.ChangeEvent<HTMLInputElement>) => {
    updatePolicyConfig({ ...policy, enabled: event.target.checked })
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
          />
          Enabled
        </label>
      )}
      {isPolicyVisible && (
        <Form
          className="PolicyConfiguration-form"
          formData={data}
          schema={configuration}
          onSubmit={onSubmit(policy)}
        >
          <Button className="btn-info" type="submit">Update Policy</Button>
        </Form>
      )}
      {removable && (
        <Button
          variant="danger"
          onClick={remove}
        >
          Remove
        </Button>
      )}
    </section>
  )
}

export { PolicyConfig, Props }
