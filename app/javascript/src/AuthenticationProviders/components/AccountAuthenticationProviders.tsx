import {
  Button,
  Card,
  CardBody,
  FlexItem,
  Modal,
  ModalVariant
} from '@patternfly/react-core'
import { useState } from 'react'

import { EnforceSSOSwitch } from 'AuthenticationProviders/components/EnforceSSOSwitch'
import { AuthenticationProvidersTable } from 'AuthenticationProviders/components/AuthenticationProvidersTable'
import { AuthenticationProvidersEmptyState } from 'AuthenticationProviders/components/AuthenticationProvidersEmptyState'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { ajaxJSON } from 'utilities/ajax'
import { toast } from 'utilities/toast'

import type { IAlert } from 'Types'
import type { FunctionComponent } from 'react'
import type { Props as TableProps } from 'AuthenticationProviders/components/AuthenticationProvidersTable'

interface Props {
  showToggle: boolean;
  table: TableProps;
  ssoEnabled: boolean;
  toggleDisabled: boolean;
  ssoPath: string;
}

const AccountAuthenticationProviders: FunctionComponent<Props> = ({
  showToggle,
  ssoEnabled,
  ssoPath,
  table,
  toggleDisabled
}) => {
  const [loading, setLoading] = useState(false)
  const [isSSOEnabled, setIsSSOEnabled] = useState(ssoEnabled)
  const [openModal, setOpenModal] = useState<'disable' | 'enable' | undefined>(undefined)

  const enforceSSO = () => {
    if (!loading) {
      setLoading(true)
      setIsSSOEnabled(true)

      void ajaxJSON<Required<IAlert> & { ok: boolean }>(ssoPath, { method: 'POST' })
        .then(res => res.json())
        .then(({ type, message, ok }) => {
          toast(message, type)
          if (!ok) {
            setIsSSOEnabled(false)
          }
        })
        .finally(() => {
          setLoading(false)
        })
    }

    setOpenModal(undefined)
  }

  const disableSSO = () => {
    if (!loading) {
      setLoading(true)
      setIsSSOEnabled(false)

      void ajaxJSON<Required<IAlert> & { ok: boolean }>(ssoPath, { method: 'DELETE' })
        .then(res => res.json())
        .then(({ type, message, ok }) => {
          toast(message, type)
          setIsSSOEnabled(!ok)
        })
        .finally(() => {
          setLoading(false)
        })
    }

    setOpenModal(undefined)
  }

  const handleOnChange = (isChecked: boolean) => {
    if (loading) {
      return
    }

    setOpenModal(isChecked ? 'enable' : 'disable')
  }

  const closeModal = () => { setOpenModal(undefined) }

  return (
    <>
      {showToggle && (
        <FlexItem>
          <Card>
            <CardBody>
              <EnforceSSOSwitch
                isChecked={isSSOEnabled}
                isDisabled={toggleDisabled}
                isLoading={loading}
                onChange={handleOnChange}
              />
            </CardBody>
          </Card>
        </FlexItem>
      )}
      <FlexItem>
        {!table.count ? <AuthenticationProvidersEmptyState newHref={table.newHref} /> : (
          <Card>
            {/* eslint-disable-next-line react/jsx-props-no-spreading */}
            <AuthenticationProvidersTable {...table} />
          </Card>
        )}
      </FlexItem>

      {openModal === 'enable' && (
        <Modal
          isOpen
          actions={[
            <Button key="confirm" variant="primary" onClick={enforceSSO}>Disable password-based authentication</Button>,
            <Button key="cancel" variant="link" onClick={closeModal}>Cancel</Button>
          ]}
          title="Are you sure?"
          variant={ModalVariant.small}
          onClose={closeModal}
        >
          Yes, I want to terminate current password-based sessions and disable password-based
          sign-ins for all users including myself
        </Modal>
      )}

      {openModal === 'disable' && (
        <Modal
          isOpen
          actions={[
            <Button key="confirm" variant="primary" onClick={disableSSO}>Enable password-based authentication</Button>,
            <Button key="cancel" variant="link" onClick={closeModal}>Cancel</Button>
          ]}
          title="Are you sure?"
          variant={ModalVariant.small}
          onClose={closeModal}
        >
          Yes, re-enable password-based sign-ins for all users including myself
        </Modal>
      )}
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const Wrapper = (props: Props, containerId: string): void => { createReactWrapper(<AccountAuthenticationProviders {...props} />, containerId) }

export type { Props }
export { AccountAuthenticationProviders, Wrapper }
