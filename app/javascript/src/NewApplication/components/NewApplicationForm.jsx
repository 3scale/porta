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
  ProductSelect,
  ApplicationPlanSelect,
  ServicePlanSelect,
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
  const [servicePlan, setServicePlan] = useState<ServicePlan | null>(null)
  const [appPlan, setAppPlan] = useState<ApplicationPlan | null>(null)
  const [name, setName] = useState<string>('')
  const [description, setDescription] = useState<string>('')

  const [loading, setLoading] = useState<boolean>(false)
  const [modalOpen, setModalOpen] = useState<boolean>(false)
  console.log(`Modal is ${modalOpen ? 'open' : 'close'}`)

  const buyerValid = buyer && (buyer.id !== undefined || buyer !== null)
  const servicePlanValid = !servicePlansAllowed || servicePlan !== null
  const isFormComplete = name &&
    buyerValid &&
    product !== null &&
    appPlan !== null &&
    servicePlanValid

  // useEffect(() => {
  //   if (buyer !== BUYER_PLACEHOLDER) {
  //     setProduct(PRODUCT_PLACEHOLDER)
  //     setAppPlan(APP_PLAN_PLACEHOLDER)
  //   }
  // }, [buyer])

  useEffect(() => {
    if (product !== null) {
      setAppPlan(null)

      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan
      setServicePlan(contractedServicePlan || null)
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
          isDisabled={!buyer}
        />

        {servicePlansAllowed && (
          <ServicePlanSelect
            servicePlan={servicePlan}
            servicePlans={product ? product.servicePlans : []}
            onSelect={setServicePlan}
            isRequired={contractedServicePlan === null}
            isDisabled={product === null || contractedServicePlan !== null}
          />
        )}

        <ApplicationPlanSelect
          appPlan={appPlan}
          appPlans={product ? product.appPlans : []}
          onSelect={setAppPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(':id', product ? product.id.toString() : '')}
          isDisabled={product === null}
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
