// @flow

import React, { useState, useEffect } from 'react'

import {
  Form,
  FormGroup,
  FormSelect,
  ActionGroup,
  Button,
  PageSection,
  PageSectionVariants
} from '@patternfly/react-core'
import {
  ProductFormSelector,
  ApplicationPlanSelect,
  APP_PLAN_PLACEHOLDER,
  ServicePlanSelect,
  SERVICE_PLAN_PLACEHOLDER,
  NameInput,
  DescriptionInput
} from 'Applications'
import { CSRFToken } from 'utilities/utils'
import { toFormSelectOption } from 'utilities/patternfly-utils'

import type { Buyer, Product, ServicePlan, ApplicationPlan } from 'Applications/types'

import './NewApplicationForm.scss'

const BUYER_PLACEHOLDER: Buyer = { disabled: true, id: '-1', name: 'Select an Account', contractedProducts: [], servicePlans: [], createApplicationPath: '' }
const PRODUCT_PLACEHOLDER: Product = { disabled: true, id: -1, name: 'Select a Product', appPlans: [], servicePlans: [], defaultServicePlan: null }

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
  console.log({buyer,
    createApplicationPath,
    servicePlansAllowed,
    products,
    createApplicationPlanPath})
  // const [buyer, setBuyer] = useState(buyers[0])
  const [product, setProduct] = useState<Product>(PRODUCT_PLACEHOLDER)
  const [appPlan, setAppPlan] = useState<ApplicationPlan>(APP_PLAN_PLACEHOLDER)
  const [servicePlan, setServicePlan] = useState<ServicePlan>(SERVICE_PLAN_PLACEHOLDER)
  const [name, setName] = useState<string>('')
  const [description, setDescription] = useState<string>('')
  const [loading, setLoading] = useState<boolean>(false)

  const buyerValid = buyer && (buyer.id !== undefined || buyer.id !== BUYER_PLACEHOLDER.id)
  const servicePlanValid = !servicePlansAllowed || servicePlan.id !== SERVICE_PLAN_PLACEHOLDER.id
  const isFormComplete = name &&
    buyerValid &&
    product !== PRODUCT_PLACEHOLDER &&
    appPlan !== APP_PLAN_PLACEHOLDER &&
    servicePlanValid

  // useEffect(() => {
  //   if (buyer !== BUYER_PLACEHOLDER) {
  //     setProduct(PRODUCT_PLACEHOLDER)
  //     setAppPlan(APP_PLAN_PLACEHOLDER)
  //   }
  // }, [buyer])

  useEffect(() => {
    if (product !== PRODUCT_PLACEHOLDER) {
      setAppPlan(APP_PLAN_PLACEHOLDER)

      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan
      setServicePlan(contractedServicePlan || SERVICE_PLAN_PLACEHOLDER)
    }
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', buyer.id) : createApplicationPath

  const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
  const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan

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
          <FormGroup
            label="Account"
            isRequired
            fieldId="account_id"
          >
            <FormSelect
              value={undefined}
              onChange={(id) => console.log('setBuyer(buyers.find(a => a.id === id))')}
              id="account_id"
              name="account_id"
            >
              {/* {buyers.map((b) => (
                <FormSelectOption isDisabled={b.disabled} key={b.id} value={b.id} label={b.name} />
              ))} */}
              {/* $FlowFixMe */}
              {[BUYER_PLACEHOLDER].map(toFormSelectOption)}
            </FormSelect>
          </FormGroup>
        )}

        {/* Product (fancy selector) */}
        <ProductFormSelector
          products={products}
          onSelect={console.log}
        />

        <FormGroup
          // Not to be submitted
          isRequired
          label="Product"
          fieldId="product"
        >
          <FormSelect
            isDisabled={!buyer || buyer === BUYER_PLACEHOLDER}
            value={product.id}
            onChange={(id: string) => setProduct(products.find(p => p.id === Number(id)) || PRODUCT_PLACEHOLDER)}
            id="product"
          >
            {/* $FlowFixMe */}
            {[PRODUCT_PLACEHOLDER, ...products].map(toFormSelectOption)}
          </FormSelect>
        </FormGroup>

        {servicePlansAllowed && (
          <ServicePlanSelect
            isRequired={contractedServicePlan === null}
            isDisabled={product === PRODUCT_PLACEHOLDER || contractedServicePlan !== null}
            servicePlans={product.servicePlans}
            servicePlan={servicePlan}
            setServicePlan={setServicePlan}
          />
        )}

        <ApplicationPlanSelect
          isDisabled={product === PRODUCT_PLACEHOLDER}
          appPlans={product.appPlans}
          appPlan={appPlan}
          setAppPlan={setAppPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(':id', product.id.toString())}
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
