// @flow

import * as React from 'react'
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
  servicePlansAllowed?: boolean,
  product?: Product,
  mostRecentlyUpdatedProducts?: Product[],
  productsCount?: number,
  productsPath?: string,
  buyer?: Buyer,
  buyersCount?: number,
  buyersPath?: string,
  mostRecentlyCreatedBuyers?: Buyer[],
  definedFields?: FieldDefinition[],
  validationErrors: {[string]: string[] | void},
  error?: string
}

const NewApplicationForm = ({
  buyer: defaultBuyer,
  mostRecentlyCreatedBuyers,
  buyersCount = 0,
  buyersPath,
  createApplicationPath,
  createApplicationPlanPath,
  createServicePlanPath,
  serviceSubscriptionsPath,
  servicePlansAllowed = false,
  product: defaultProduct,
  mostRecentlyUpdatedProducts,
  productsCount = 0,
  productsPath,
  definedFields,
  validationErrors,
  error
}: Props): React.Node => {
  const [buyer, setBuyer] = useState<Buyer | null>(defaultBuyer || null)
  const [product, setProduct] = useState<Product | null>(defaultProduct || null)
  const [servicePlan, setServicePlan] = useState<ServicePlan | null>(null)
  const [appPlan, setAppPlan] = useState<ApplicationPlan | null>(defaultProduct?.defaultAppPlan || null)
  const [loading, setLoading] = useState<boolean>(false)

  const definedFieldsInitialState = definedFields ? definedFields.reduce((state, field) => {
    state[field.id] = ''
    return state
  }, {}) : {}
  const [definedFieldsState, setDefinedFieldsState] = useState<{[string]: string}>(definedFieldsInitialState)
  const handleOnDefinedFieldChange = (id) => (value) => {
    setDefinedFieldsState(state => ({ ...state, [id]: value }))
  }

  const resetServicePlan = () => {
    let plan = null

    if (buyer !== null && product !== null) {
      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan || null
      plan = contractedServicePlan
    }

    setServicePlan(plan)
  }

  const resetAppPlan = () => {
    if (product && !product.buyerCanSelectPlan) {
      setAppPlan(product.defaultAppPlan || null)
    } else {
      setAppPlan(null)
    }
  }

  useEffect(() => {
    const product = defaultProduct || null

    setProduct(product)
    resetServicePlan()
    resetAppPlan()
  }, [buyer])

  useEffect(() => {
    resetServicePlan()
    if (product && !product.buyerCanSelectPlan) {
      setAppPlan(product.defaultAppPlan || null)
    } else {
      setAppPlan(null)
    }
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', buyer.id) : createApplicationPath

  const contractedServicePlan = (buyer && product) ? new BuyerLogic(buyer).getContractedServicePlan(product) : null

  const buyerValid = buyer && (buyer.id !== undefined || buyer !== null)
  const servicePlanValid = !servicePlansAllowed || servicePlan !== null || contractedServicePlan !== null
  const definedFieldsValid = definedFields === undefined || definedFields.every(f => !f.required || definedFieldsState[f.id] !== '')
  const isFormComplete = buyer !== null &&
    product !== null &&
    servicePlanValid &&
    appPlan !== null &&
    buyerValid &&
    definedFieldsValid

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

        {mostRecentlyCreatedBuyers ? (
          <BuyerSelect
            buyer={buyer}
            mostRecentlyCreatedBuyers={mostRecentlyCreatedBuyers}
            buyersCount={buyersCount}
            onSelectBuyer={setBuyer}
            buyersPath={buyersPath ? `${buyersPath}.json` : ''}
          />
          // $FlowExpectedError[incompatible-use] either buyers or defaultBuyer is always defined
        ) : <input type="hidden" name="account_id" value={defaultBuyer.id} />}

        {mostRecentlyUpdatedProducts && (
          <ProductSelect
            product={product}
            mostRecentlyUpdatedProducts={mostRecentlyUpdatedProducts}
            productsCount={productsCount}
            onSelectProduct={setProduct}
            productsPath={productsPath ? `${productsPath}.json` : ''}
            isDisabled={buyer === null}
          />
        )}

        {servicePlansAllowed && (
          <ServicePlanSelect
            servicePlan={contractedServicePlan || servicePlan}
            servicePlans={product ? product.servicePlans : []}
            onSelect={setServicePlan}
            showHint={product !== null && buyer !== null}
            isPlanContracted={contractedServicePlan !== null}
            isDisabled={product === null || contractedServicePlan !== null || buyer === null}
            serviceSubscriptionsPath={buyer ? serviceSubscriptionsPath.replace(':id', buyer.id) : ''}
            createServicePlanPath={product ? createServicePlanPath.replace(':id', product.id) : ''}
          />
        )}

        <ApplicationPlanSelect
          appPlan={appPlan}
          product={product}
          onSelect={setAppPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(
            ':id',
            product ? product.id : ''
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
              Create Application
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

const NewApplicationFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewApplicationForm {...props} />, containerId)

export { NewApplicationForm, NewApplicationFormWrapper }
