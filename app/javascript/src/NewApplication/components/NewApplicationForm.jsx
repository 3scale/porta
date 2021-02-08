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
  DescriptionInput,
  SelectBuyerModal,
  SelectProductModal
} from 'NewApplication'
import { CSRFToken } from 'utilities/utils'

import type { Buyer, Product, ServicePlan, ApplicationPlan } from 'NewApplication/types'

import './NewApplicationForm.scss'

type Props = {
  createApplicationPath: string,
  createApplicationPlanPath: string,
  product?: Product,
  products?: Product[],
  servicePlansAllowed: boolean,
  buyer?: Buyer,
  buyers?: Buyer[]
}

const NewApplicationForm = ({
  buyer: defaultBuyer,
  buyers,
  createApplicationPath,
  servicePlansAllowed,
  product: defaultProduct,
  products,
  createApplicationPlanPath
}: Props) => {
  const [buyer, setBuyer] = useState<Buyer | null>(defaultBuyer || null)
  const [product, setProduct] = useState<Product | null>(defaultProduct || null)
  const [servicePlan, setServicePlan] = useState<ServicePlan | null>(null)
  const [appPlan, setAppPlan] = useState<ApplicationPlan | null>(null)
  const [name, setName] = useState<string>('')
  const [description, setDescription] = useState<string>('')

  const [loading, setLoading] = useState<boolean>(false)
  const [modalOpen, setModalOpen] = useState<boolean>(false)
  const [buyersModalOpen, setBuyersModalOpen] = useState<boolean>(false)

  const buyerValid = buyer && (buyer.id !== undefined || buyer !== null)
  const servicePlanValid = !servicePlansAllowed || servicePlan !== null
  const isFormComplete = buyer !== null &&
    product !== null &&
    servicePlanValid &&
    appPlan !== null &&
    name &&
    buyerValid

  useEffect(() => {
    const product = defaultProduct || null
    let servicePlan = null

    if (buyer !== null && product !== null) {
      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan
      servicePlan = contractedServicePlan
    }

    setProduct(product)
    setServicePlan(servicePlan)
    setAppPlan(null)
  }, [buyer])

  useEffect(() => {
    let servicePlan = null

    if (product !== null) {
      const contract = buyer && buyer.contractedProducts.find(p => p.id === product.id)
      const contractedServicePlan = (contract && contract.withPlan) || product.defaultServicePlan
      servicePlan = contractedServicePlan
    }

    setServicePlan(servicePlan)
    setAppPlan(null)
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', buyer.id) : createApplicationPath

  const contract = buyer && product && buyer.contractedProducts.find(p => p.id === product.id)
  const contractedServicePlan = (contract && contract.withPlan) || (product && product.defaultServicePlan)

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

        {buyers && (
          <>
            <BuyerSelect
              buyer={buyer}
              buyers={buyers}
              onSelect={setBuyer}
              onShowAll={() => setBuyersModalOpen(true)}
            />

            <SelectBuyerModal
              isOpen={buyersModalOpen}
              buyers={buyers}
              onSelectBuyer={b => {
                setBuyer(b)
                setBuyersModalOpen(false)
              }}
              onClose={() => setBuyersModalOpen(false)}
            />
          </>
        )}

        {products && (
          <>
            <ProductSelect
              product={product}
              products={products}
              onSelect={setProduct}
              onShowAll={() => setModalOpen(true)}
              isDisabled={buyer === null}
            />

            <SelectProductModal
              isOpen={modalOpen}
              products={products}
              onSelectProduct={p => {
                setProduct(p)
                setModalOpen(false)
              }}
              onClose={() => setModalOpen(false)}
            />
          </>
        )}

        {servicePlansAllowed && (
          <ServicePlanSelect
            servicePlan={servicePlan}
            servicePlans={product ? product.servicePlans : []}
            onSelect={setServicePlan}
            isRequired={contractedServicePlan === null}
            isDisabled={product === null || contractedServicePlan !== null || buyer === null}
          />
        )}

        <ApplicationPlanSelect
          appPlan={appPlan}
          appPlans={product ? product.appPlans : []}
          onSelect={setAppPlan}
          createApplicationPlanPath={createApplicationPlanPath.replace(
            ':id',
            product ? product.id.toString() : ''
          )}
          isDisabled={product === null}
        />

        <NameInput name={name} setName={setName} />

        <DescriptionInput
          description={description}
          setDescription={setDescription}
        />

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

export { NewApplicationForm }
