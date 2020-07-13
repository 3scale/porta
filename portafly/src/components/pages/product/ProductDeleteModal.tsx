import React, { useState } from 'react'
import { IProduct } from 'types'
import {
  Modal,
  Button,
  Text,
  TextContent,
  FormGroup,
  TextInput,
  Alert
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'
import { Trans } from 'react-i18next'
import { Redirect } from 'react-router'
import { useAsync } from 'react-async'
import { deleteProduct } from 'dal/product'

interface Props {
  product: IProduct
  isOpen?: boolean
  onClose: () => void
}

const ProductDeleteModal: React.FunctionComponent<Props> = ({
  product,
  isOpen,
  onClose
}) => {
  const { t } = useTranslation('product')
  const [name, setName] = useState('')

  const {
    isPending,
    error,
    run,
    isFulfilled
  } = useAsync({ deferFn: deleteProduct })

  const isButtonDisabled = name !== product.systemName || isPending

  const onClick = () => {
    run(product.id)
  }

  if (isFulfilled) {
    return <Redirect to="/products" />
  }

  return (
    <Modal
      title={t('modal.title', { product: product.name })}
      width="44%"
      isOpen={isOpen}
      onClose={onClose}
      // TODO: should be closable when loading?
      // showClose={!isPending}
      actions={[
        <Button
          key="delete"
          variant="danger"
          onClick={onClick}
          isDisabled={isButtonDisabled}
        >
          {t('shared:shared_elements.delete_button')}
        </Button>,
        <Button
          key="cancel"
          variant="link"
          onClick={onClose}
          isDisabled={isPending}
        >
          {t('shared:shared_elements.cancel_button')}
        </Button>
      ]}
    >
      <TextContent>
        <Text>
          <Trans t={t} i18nKey="modal.body" />
        </Text>
      </TextContent>
      <br />
      <FormGroup
        label={<Trans t={t} i18nKey="modal.confirmation" values={{ product: product.systemName }} />}
        fieldId="subject"
      >
        <TextInput
          value={name}
          type="text"
          onChange={setName}
          aria-label={t('modal.confirmation_aria_label')}
        />
      </FormGroup>
      {error && (
        <>
          <br />
          <Alert variant="danger" title={error.message} isInline />
        </>
      )}
    </Modal>
  )
}

export { ProductDeleteModal }
