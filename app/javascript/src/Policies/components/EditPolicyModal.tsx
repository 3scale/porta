import { Button, Modal } from '@patternfly/react-core'

import { PolicyConfig } from 'Policies/components/PolicyConfig'
import { isNotApicastPolicy } from 'Policies/util'

import type { FunctionComponent } from 'react'
import type { ModalProps } from '@patternfly/react-core'
import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

interface Props extends Pick<ModalProps, 'isOpen'> {
  actions: {
    submitPolicyConfig: (policy: ChainPolicy) => ThunkAction;
    removePolicyFromChain: (policy: ChainPolicy) => ThunkAction;
    closePolicyConfig: () => ThunkAction;
    updatePolicyConfig: (policy: ChainPolicy) => UpdatePolicyConfigAction;
  };
  policy: ChainPolicy;
}

const EditPolicyModal: FunctionComponent<Props> = ({
  actions,
  isOpen,
  policy
}) => {
  const { removePolicyFromChain, closePolicyConfig } = actions
  const { humanName, removable } = policy

  const FORM_ID = 'edit-policy-form'

  const isPolicyVisible = isNotApicastPolicy(policy)

  const modalActions = []

  if (isPolicyVisible) {
    modalActions.push(
      <Button
        key="confirm"
        type="submit"
        variant="primary"
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        onClick={() => { document.forms.namedItem(FORM_ID)!.requestSubmit() }}
      >
        Update Policy
      </Button>,
      <Button
        key="cancel"
        variant="secondary"
        onClick={closePolicyConfig}
      >
        Cancel
      </Button>
    )
  } else {
    modalActions.push(
      <Button
        key="close"
        variant="primary"
        onClick={closePolicyConfig}
      >
        Close
      </Button>
    )
  }

  if (removable) {
    modalActions.push(
      <Button
        key="remove"
        variant="danger"
        onClick={() => removePolicyFromChain(policy)}
      >
        Remove
      </Button>
    )
  }

  return (
    <Modal
      actions={modalActions}
      aria-label="Edit policy modal"
      id="policy-edit-modal"
      isOpen={isOpen}
      title={humanName}
      variant="medium"
      onClose={closePolicyConfig}
    >
      <PolicyConfig actions={actions} policy={policy} />
    </Modal>
  )
}

export type { Props }
export { EditPolicyModal }
