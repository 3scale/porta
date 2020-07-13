import React from 'react'
import { Loading } from 'components'
import { useTranslation } from 'i18n/useTranslation'
import {
  PageSection,
  Text,
  TextContent,
  Flex,
  FlexItem,
  Alert,
  Grid,
  GridItem
} from '@patternfly/react-core'
import { useAsync } from 'react-async'
import { getProduct } from 'dal/product'
import { ProductEditLink } from './ProductEditLink'
import { ProductDeleteButton } from './ProductDeleteButton'

interface Props {
  productId: string
}

const ProductOverviewPage: React.FunctionComponent<Props> = ({ productId }) => {
  const { t } = useTranslation('product')

  const { data: product, error, isPending } = useAsync(getProduct, { productId })

  return (
    <div className="product-page">
      <PageSection variant="light">
        {product && (
          <>
            <Flex>
              <FlexItem>
                <TextContent>
                  <Text component="h1">{product.name}</Text>
                </TextContent>
              </FlexItem>
              <FlexItem align={{ default: 'alignRight' }}>
                <ProductEditLink product={product} />
              </FlexItem>
              <FlexItem>
                <ProductDeleteButton product={product} />
              </FlexItem>
            </Flex>
            <br />
          </>
        )}

        {isPending && <Loading />}
        {error && <Alert variant="danger" title={error.message} />}
        {product && (
        <Grid hasGutter>
          <GridItem rowSpan={2} span={2}>{t('system_name.label')}</GridItem>
          <GridItem rowSpan={2} span={10}>{product.systemName}</GridItem>

          <GridItem rowSpan={2} span={2}>{t('description')}</GridItem>
          <GridItem rowSpan={2} span={10}>{product.description}</GridItem>
        </Grid>
        )}
      </PageSection>
    </div>
  )
}

// Default export needed for React.lazy
// eslint-disable-next-line import/no-default-export
export default ProductOverviewPage
