// @flow

import React, { useState, useEffect } from 'react'

import {
  Form,
  ActionGroup,
  Button,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import {
  BuyerSelect,
  BUYER_PLACEHOLDER,
  ProductSelect,
  ApplicationPlanSelect,
  APP_PLAN_PLACEHOLDER,
  ServicePlanSelect,
  SERVICE_PLAN_PLACEHOLDER,
  NameInput,
  DescriptionInput
} from 'NewApplication'
import { CSRFToken } from 'utilities/utils'

import type { Buyer, Product, ServicePlan, ApplicationPlan } from 'NewApplication/types'

import './NewApplicationForm.scss'

type Props = {
  createApplicationPath: string,
  createApplicationPlanPath: string,
  products: Product[],
  servicePlansAllowed: boolean,
  buyer?: Buyer
}

const NewApplicationForm = ({
  buyer,
  createApplicationPath,
  servicePlansAllowed,
  products,
  createApplicationPlanPath
}: Props) => {
  // const [buyer, setBuyer] = useState(buyers[0])
  const [product, setProduct] = useState<Product | null>(null)
  const [appPlan, setAppPlan] = useState<ApplicationPlan>(APP_PLAN_PLACEHOLDER)
  const [servicePlan, setServicePlan] = useState<ServicePlan>(SERVICE_PLAN_PLACEHOLDER)
  const [name, setName] = useState<string>('')
  const [description, setDescription] = useState<string>('')
  const [loading, setLoading] = useState<boolean>(false)
  const [modalOpen, setModalOpen] = useState<boolean>(false)
  console.log(`Modal is ${modalOpen ? 'open' : 'close'}`)

  const buyerValid = buyer && (buyer.id !== undefined || buyer.id !== BUYER_PLACEHOLDER.id)
  const servicePlanValid = !servicePlansAllowed || servicePlan.id !== SERVICE_PLAN_PLACEHOLDER.id
  const isFormComplete = name &&
    buyerValid &&
    product !== null &&
    appPlan !== APP_PLAN_PLACEHOLDER &&
    servicePlanValid

  // useEffect(() => {
  //   if (buyer !== BUYER_PLACEHOLDER) {
  //     setProduct(PRODUCT_PLACEHOLDER)
  //     setAppPlan(APP_PLAN_PLACEHOLDER)
  //   }
  // }, [buyer])

  useEffect(() => {
    if (product !== null) {
      setAppPlan(APP_PLAN_PLACEHOLDER)

      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan
      setServicePlan(contractedServicePlan || SERVICE_PLAN_PLACEHOLDER)
    }
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', buyer.id) : createApplicationPath

  const contract = buyer && product && buyer.contractedProducts.find(p => p.id === product.id)
  const contractedServicePlan = (contract && contract.withPlan) || (product && product.defaultServicePlan)

  return (
    <PageSection variant={PageSectionVariants.light}>
      <Form
        acceptCharset="UTF-8"
        method="post"
        action={url}
        onSubmit={e => setLoading(true)}
      >
        <CSRFToken />
        <input name="utf8" type="hidden" value="✓"/>

        {!buyer && (
          <BuyerSelect />
        )}

        <ProductSelect
          product={product}
          products={products}
          onSelect={setProduct}
          onShowAll={() => setModalOpen(true)}
          isDisabled={!buyer || buyer === BUYER_PLACEHOLDER}
        />

        {servicePlansAllowed && (
          <ServicePlanSelect
            isRequired={contractedServicePlan === null}
            isDisabled={product === null || contractedServicePlan !== null}
            servicePlans={product ? product.servicePlans : []}
            servicePlan={servicePlan}
            setServicePlan={setServicePlan}
          />
        )}

        <ApplicationPlanSelect
          isDisabled={product === null}
          appPlans={product ? product.appPlans : []}
          appPlan={appPlan}
          setAppPlan={setAppPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(':id', product ? product.id.toString() : '')}
        />

        <NameInput name={name} setName={setName} />

        <DescriptionInput description={description} setDescription={setDescription} />

        <ActionGroup>
          <Button
            variant="primary"
            type="submit"
            isDisabled={!isFormComplete || loading}
          >
            Create Application
          </Button>
        </ActionGroup>
      </Form>
    </PageSection>
  )
}

export { NewApplicationForm }
