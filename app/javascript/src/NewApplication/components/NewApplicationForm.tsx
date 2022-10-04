import { useEffect, useState } from 'react'
import {
  ActionGroup,
  Button,
  Form,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import * as flash from 'utilities/alert'
import { UserDefinedField } from 'Common/components/UserDefinedField'
import { BuyerLogic } from 'Logic/BuyerLogic'
import { ApplicationPlanSelect } from 'NewApplication/components/ApplicationPlanSelect'
import { BuyerSelect } from 'NewApplication/components/BuyerSelect'
import { ProductSelect } from 'NewApplication/components/ProductSelect'
import { ServicePlanSelect } from 'NewApplication/components/ServicePlanSelect'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FieldDefinition } from 'Types'
import type { ApplicationPlan, Buyer, Product, ServicePlan } from 'NewApplication/types'

import './NewApplicationForm.scss'

type Props = {
  createApplicationPath: string,
  createApplicationPlanPath: string,
  createServicePlanPath: string,
  serviceSubscriptionsPath: string,
  product?: Product,
  products?: Product[],
  productsCount?: number,
  productsPath?: string,
  servicePlansAllowed?: boolean,
  buyer?: Buyer,
  buyers?: Buyer[],
  buyersCount?: number,
  buyersPath?: string,
  definedFields?: FieldDefinition[],
  validationErrors: {
    [key: string]: string[] | undefined
  },
  error?: string
}

const NewApplicationForm: React.FunctionComponent<Props> = ({
  buyer: defaultBuyer,
  buyers,
  buyersCount = 0,
  buyersPath,
  createApplicationPath,
  createApplicationPlanPath,
  createServicePlanPath,
  serviceSubscriptionsPath,
  servicePlansAllowed = false,
  product: defaultProduct,
  products,
  productsCount = 0,
  productsPath,
  definedFields,
  validationErrors,
  error
}) => {
  const [buyer, setBuyer] = useState<Buyer | null>(defaultBuyer || null)
  const [product, setProduct] = useState<Product | null>(defaultProduct || null)
  const [servicePlan, setServicePlan] = useState<ServicePlan | null>(null)
  const [appPlan, setAppPlan] = useState<ApplicationPlan | null>(defaultProduct?.defaultAppPlan || null)
  const [loading, setLoading] = useState<boolean>(false)

  const definedFieldsInitialState = definedFields ? definedFields.reduce<Record<string, any>>((state, field) => {
    state[field.id] = ''
    return state
  }, {}) : {}
  const [definedFieldsState, setDefinedFieldsState] = useState<{
    [key: string]: string
  }>(definedFieldsInitialState)
  const handleOnDefinedFieldChange = (id: string) => (value: string) => {
    setDefinedFieldsState(state => ({ ...state, [id]: value }))
  }

  const resetServicePlan = () => {
    let plan = null

    if (buyer && product) {
      const contractedServicePlan = new BuyerLogic(buyer).getContractedServicePlan(product)
      plan = contractedServicePlan || product.defaultServicePlan || product.servicePlans[0] || null
    }

    setServicePlan(plan)
  }

  const resetAppPlan = () => {
    let plan = null

    if (product) {
      // FIXME: when there is no default plan and buyer cannot select plan, it will be null and disabled.
      plan = product.defaultAppPlan || null
    }

    setAppPlan(plan)
  }

  useEffect(() => {
    const product = defaultProduct || null

    setProduct(product)
    resetServicePlan()
    resetAppPlan()
  }, [buyer])

  useEffect(() => {
    resetServicePlan()
    resetAppPlan()
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', String(buyer.id)) : createApplicationPath

  const isServiceSubscribedToBuyer = Boolean(buyer && product && new BuyerLogic(buyer).isSubscribedTo(product))

  const buyerValid = buyer && (buyer.id !== undefined || buyer !== null)
  const servicePlanValid = !servicePlansAllowed || servicePlan
  const definedFieldsValid = !definedFields || definedFields.every(f => !f.required || definedFieldsState[f.id] !== '')
  const isFormComplete = Boolean(buyer && product && servicePlanValid && appPlan && buyerValid && definedFieldsValid)

  if (error) {
    flash.error(error)
  }

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        acceptCharset='UTF-8'
        action={url}
        method='post'
        onSubmit={() => setLoading(true)}
      >
        <CSRFToken />
        <input name='utf8' type='hidden' value='✓' />

        {buyers ? (
          <BuyerSelect
            buyer={buyer}
            buyers={buyers}
            buyersCount={buyersCount}
            buyersPath={buyersPath ? buyersPath : `${buyersPath}.json`}
            onSelectBuyer={setBuyer}
          />
        ) : <input name="account_id" type="hidden" value={(defaultBuyer as Buyer).id} />}

        {products && (
          <ProductSelect
            isDisabled={!buyer}
            product={product}
            products={products}
            productsCount={productsCount}
            productsPath={productsPath ? productsPath : `${productsPath}.json`}
            onSelectProduct={setProduct}
          />
        )}

        {servicePlansAllowed && (
          <ServicePlanSelect
            createServicePlanPath={product ? createServicePlanPath.replace(':id', String(product.id)) : ''}
            isDisabled={!buyer || !product || !servicePlan}
            isPlanContracted={isServiceSubscribedToBuyer}
            servicePlan={servicePlan}
            servicePlans={product ? product.servicePlans : null}
            serviceSubscriptionsPath={buyer ? serviceSubscriptionsPath.replace(':id', String(buyer.id)) : ''}
            onSelect={setServicePlan}
          />
        )}

        <ApplicationPlanSelect
          appPlan={appPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(
            ':id',
            product ? String(product.id) : ''
          )}
          product={product}
          onSelect={setAppPlan}
        />

        {definedFields && definedFields.map(f => (
          <UserDefinedField
            key={f.id}
            fieldDefinition={f}
            validationErrors={validationErrors[f.id]}
            value={definedFieldsState[f.id]}
            onChange={handleOnDefinedFieldChange(f.id)}
          />
        ))}

        <ActionGroup>
          <Button
            isDisabled={!isFormComplete || loading}
            type='submit'
            variant='primary'
          >
              Create application
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const NewApplicationFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewApplicationForm {...props} />, containerId)

export { NewApplicationForm, NewApplicationFormWrapper, Props }
