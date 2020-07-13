import React from 'react'
import { useTranslation } from 'i18n/useTranslation'
import { Button } from '@patternfly/react-core'
import { IProduct } from 'types'

interface Props {
  product: IProduct
}

const ProductEditLink: React.FunctionComponent<Props> = ({ product }) => {
  const { t } = useTranslation('product')

  return (
    <Button
      component="a"
      variant="secondary"
      href={`/products/${product?.id}/edit`}
      isInline
    >
      {t('button_edit')}
    </Button>
  )
}

export { ProductEditLink }
