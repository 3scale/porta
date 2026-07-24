import { Button, List, ListItem, Modal, ModalVariant, Text, TextContent } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  readonly isOpen: boolean;
  readonly onConfirm: () => void;
  readonly onCancel: () => void;
}

const AdminDomainConfirmation: FunctionComponent<Props> = ({ isOpen, onConfirm, onCancel }) => (
  <Modal
    actions={[
      <Button key="confirm" variant="primary" onClick={onConfirm}>Confirm</Button>,
      <Button key="cancel" variant="link" onClick={onCancel}>Cancel</Button>
    ]}
    isOpen={isOpen}
    title="Change admin portal domain?"
    titleIconVariant="warning"
    variant={ModalVariant.small}
    onClose={onCancel}
  >
    <TextContent>
      <Text component="h3">Changing the admin domain has the following side effects:</Text>
    </TextContent>
    <List>
      <ListItem>The new domain requires a valid <strong>SSL certificate</strong>. Make sure you have one before proceeding, or <a href="https://docs.openshift.com/enterprise/latest/dev_guide/routes.html" rel="noopener noreferrer" target="_blank">add a route on OpenShift</a> so that a certificate is provisioned automatically.</ListItem>
      <ListItem><strong>Active sessions</strong> on the old domain will be invalidated. All users will need to log in again on the new domain.</ListItem>
      <ListItem><strong>Email links</strong> already sent (password resets, invitations, activations) will point to the old domain and stop working.</ListItem>
      <ListItem>If <strong>Provider Admin SSO</strong> is configured, the callback URL in the external identity provider (Keycloak, Auth0, etc.) must be updated manually.</ListItem>
    </List>
  </Modal>
)

export type { Props }
export { AdminDomainConfirmation }
