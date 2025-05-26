import { useEffect, useState } from 'react'
import {
  ActionGroup,
  Button,
  Card,
  CardBody,
  Form,
  PageSection,
  PageSectionVariants,
  Text,
  TextContent
} from '@patternfly/react-core'

import { toast } from 'utilities/toast'
import { UserDefinedField } from 'Common/components/UserDefinedField'
import { BuyerLogic } from 'Logic/BuyerLogic'
import { ApplicationPlanSelect } from 'NewApplication/components/ApplicationPlanSelect'
import { BuyerSelect } from 'NewApplication/components/BuyerSelect'
import { ProductSelect } from 'NewApplication/components/ProductSelect'
import { ServicePlanSelect } from 'NewApplication/components/ServicePlanSelect'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FieldDefinition } from 'Types'
import type { Plan, Buyer, Product } from 'NewApplication/types'

import './NewApplicationForm.scss'

interface Props {
  createApplicationPath: string;
  createApplicationPlanPath: string;
  createServicePlanPath: string;
  serviceSubscriptionsPath: string;
  product?: Product;
  products?: Product[];
  productsCount?: number;
  productsPath?: string;
  servicePlansAllowed?: boolean;
  buyer?: Buyer;
  buyers?: Buyer[];
  buyersCount?: number;
  buyersPath?: string;
  definedFields?: FieldDefinition[];
  validationErrors: Record<string, string[] | undefined>;
  error?: string;
}

const emptyArray = [] as never[]

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
  definedFields = emptyArray,
  validationErrors,
  error
}) => {
  const [buyer, setBuyer] = useState<Buyer | null>(defaultBuyer ?? null)
  const [product, setProduct] = useState<Product | null>(defaultProduct ?? null)
  const [servicePlan, setServicePlan] = useState<Plan | null>(null)
  const [appPlan, setAppPlan] = useState<Plan | null>(defaultProduct?.defaultAppPlan ?? null)
  const [loading, setLoading] = useState<boolean>(false)

  const definedFieldsInitialState = definedFields.reduce<Record<string, ''>>((state, field) => {
    state[field.id] = ''
    return state
  }, {})
  const [definedFieldsState, setDefinedFieldsState] = useState<Record<string, string>>(definedFieldsInitialState)
  const handleOnDefinedFieldChange = (id: string) => (value: string) => {
    setDefinedFieldsState(state => ({ ...state, [id]: value }))
  }

  const resetServicePlan = () => {
    let plan: Plan | null = null

    if (buyer && product) {
      const contractedServicePlan = new BuyerLogic(buyer).getContractedServicePlan(product)
      plan = contractedServicePlan ?? product.defaultServicePlan ?? product.servicePlans[0]
    }

    setServicePlan(plan)
  }

  const resetAppPlan = () => {
    let plan: Plan | null = null

    if (product) {
      // FIXME: when there is no default plan and buyer cannot select plan, it will be null and disabled.
      plan = product.defaultAppPlan
    }

    setAppPlan(plan)
  }

  useEffect(() => {
    setProduct(defaultProduct ?? null)
    resetServicePlan()
    resetAppPlan()
  }, [buyer])

  useEffect(() => {
    resetServicePlan()
    resetAppPlan()
  }, [product])

  const url = buyer ? createApplicationPath.replace(':id', String(buyer.id)) : createApplicationPath

  const isServiceSubscribedToBuyer = Boolean(buyer && product && new BuyerLogic(buyer).isSubscribedTo(product))

  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- FIXME
  const buyerValid = buyer && (buyer.id !== undefined || buyer !== null)
  const servicePlanValid = !servicePlansAllowed || servicePlan
  const definedFieldsValid = definedFields.length === 0 || definedFields.every(f => !f.required || definedFieldsState[f.id] !== '')
  const isFormComplete = Boolean(buyer && product && servicePlanValid && appPlan && buyerValid && definedFieldsValid)

  if (error) {
    toast(error, 'danger')
  }

  return (
    <>
      <PageSection variant={PageSectionVariants.light}>
        <TextContent>
          <Text component="h1">Create application</Text>
        </TextContent>
      </PageSection>

      <PageSection>
        <Card>
          <CardBody>
            <Form
              isWidthLimited
              acceptCharset="UTF-8"
              action={url}
              method="post"
              onSubmit={() => { setLoading(true) }}
            >
              <CSRFToken />
              <input name="utf8" type="hidden" value="✓" />

              {buyers ? (
                <BuyerSelect
                  buyer={buyer}
                  buyers={buyers}
                  buyersCount={buyersCount}
                  buyersPath={buyersPath && `${buyersPath}.json`}
                  onSelectBuyer={setBuyer}
                />
              // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Either 'buyers' or 'defaultBuyer' is always defined
              ) : <input name="account_id" type="hidden" value={defaultBuyer!.id} />}

              {products && (
                <ProductSelect
                  isDisabled={!buyer}
                  product={product}
                  products={products}
                  productsCount={productsCount}
                  productsPath={productsPath && `${productsPath}.json`}
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
                  product?.id.toString() ?? ''
                )}
                product={product}
                onSelect={setAppPlan}
              />

              {definedFields.map(f => (
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
                  type="submit"
                  variant="primary"
                >
                  Create application
                </Button>
              </ActionGroup>
            </Form>
          </CardBody>
        </Card>
      </PageSection>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const NewApplicationFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<NewApplicationForm {...props} />, containerId) }

export type { Props }
export { NewApplicationForm, NewApplicationFormWrapper }
