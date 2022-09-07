import * as React from 'react';
import { useState, useEffect } from 'react'
import {
  Form,
  ActionGroup,
  Button,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import {
  BuyerSelect,
  ProductSelect,
  ApplicationPlanSelect,
  ServicePlanSelect
} from 'NewApplication'
import { UserDefinedField } from 'Common'
import { BuyerLogic } from 'Logic'
import { createReactWrapper, CSRFToken } from 'utilities'
import * as flash from 'utilities/alert'

import type { Buyer, Product, ServicePlan, ApplicationPlan } from 'NewApplication/types'
import type { FieldDefinition } from 'Types'

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
};

const NewApplicationForm = (
  {
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
    error,
  }: Props,
): React.ReactElement => {
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
        method='post'
        action={url}
        onSubmit={e => setLoading(true)}
      >
        <CSRFToken />
        <input name='utf8' type='hidden' value='✓' />

        {buyers ? (
          <BuyerSelect
            buyer={buyer}
            buyers={buyers}
            buyersCount={buyersCount}
            onSelectBuyer={setBuyer}
            buyersPath={buyersPath && `${buyersPath}.json`}
          />
          // $FlowExpectedError[incompatible-use] either buyers or defaultBuyer is always defined
        ) : <input type="hidden" name="account_id" value={defaultBuyer.id} />}

        {products && (
          <ProductSelect
            product={product}
            products={products}
            productsCount={productsCount}
            onSelectProduct={setProduct}
            isDisabled={!buyer}
            productsPath={productsPath && `${productsPath}.json`}
          />
        )}

        {servicePlansAllowed && (
          <ServicePlanSelect
            servicePlan={servicePlan}
            servicePlans={product ? product.servicePlans : null}
            onSelect={setServicePlan}
            isPlanContracted={isServiceSubscribedToBuyer}
            isDisabled={!buyer || !product || !servicePlan}
            serviceSubscriptionsPath={buyer ? serviceSubscriptionsPath.replace(':id', String(buyer.id)) : ''}
            createServicePlanPath={product ? createServicePlanPath.replace(':id', String(product.id)) : ''}
          />
        )}

        <ApplicationPlanSelect
          appPlan={appPlan}
          product={product}
          onSelect={setAppPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(
            ':id',
            product ? String(product.id) : ''
          )}
        />

        {definedFields && definedFields.map(f => (
          <UserDefinedField
            validationErrors={validationErrors[f.id]}
            fieldDefinition={f}
            value={definedFieldsState[f.id]}
            onChange={handleOnDefinedFieldChange(f.id)}
            key={f.id} />
        ))}

        <ActionGroup>
          <Button
            variant='primary'
            type='submit'
            isDisabled={!isFormComplete || loading}
          >
              Create application
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

const NewApplicationFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewApplicationForm {...props} />, containerId)

export { NewApplicationForm, NewApplicationFormWrapper }
