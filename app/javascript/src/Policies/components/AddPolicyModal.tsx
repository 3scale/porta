import { Modal } from '@patternfly/react-core'

import { PolicyRegistry } from 'Policies/components/PolicyRegistry'

import type { FunctionComponent } from 'react'
import type { ModalProps } from '@patternfly/react-core'
import type { RegistryPolicy, ThunkAction } from 'Policies/types'

interface Props extends Pick<ModalProps, 'isOpen'> {
  actions: {
    addPolicy: (policy: RegistryPolicy) => ThunkAction;
    closePolicyRegistry: () => ThunkAction;
  };
  items: RegistryPolicy[];
}

const AddPolicyModal: FunctionComponent<Props> = ({
  actions,
  isOpen,
  items
}) => {
  return (
    <Modal
      aria-label="Add policy modal"
      id="policy-add-modal"
      isOpen={isOpen}
      title="Select a Policy"
      variant="medium"
      onClose={actions.closePolicyRegistry}
    >
      <PolicyRegistry actions={actions} items={items} />
    </Modal>
  )
}

export { AddPolicyModal }
