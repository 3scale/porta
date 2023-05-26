import { ApplicationPlansIndexPageWrapper } from 'Plans/components/ApplicationPlansIndexPage'
import { AccountPlansIndexPageWrapper } from 'Plans/components/AccountPlansIndexPage'
import { ServicePlansIndexPageWrapper } from 'Plans/components/ServicePlansIndexPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props as ServicePlansIndexPageProps } from 'Plans/components/ServicePlansIndexPage'
import type { Props as ApplicationPlansIndexPageProps } from 'Plans/components/ApplicationPlansIndexPage'
import type { Props as AccountPlansIndexPageProps } from 'Plans/components/AccountPlansIndexPage'

document.addEventListener('DOMContentLoaded', () => {
  const applicationPlansIndexContainerId = 'application-plans-index-container'
  const servicePlansIndexContainerId = 'service-plans-index-container'
  const accountPlansIndexContainerId = 'account-plans-index-container'

  const applicationPlansIndexContainer = document.getElementById(applicationPlansIndexContainerId)
  const servicePlansIndexContainer = document.getElementById(servicePlansIndexContainerId)
  const accountPlansIndexContainer = document.getElementById(accountPlansIndexContainerId)

  // TODO: implement lazy imports for react components
  if (applicationPlansIndexContainer?.dataset) {
    const { dataset } = applicationPlansIndexContainer
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const props = safeFromJsonString<ApplicationPlansIndexPageProps>(dataset.plansIndex)!
    ApplicationPlansIndexPageWrapper({ ...props }, applicationPlansIndexContainerId)

  } else if (servicePlansIndexContainer?.dataset) {
    const { dataset } = servicePlansIndexContainer
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const props = safeFromJsonString<ServicePlansIndexPageProps>(dataset.plansIndex)!
    ServicePlansIndexPageWrapper({ ...props }, servicePlansIndexContainerId)

  } else if (accountPlansIndexContainer?.dataset) {
    const { dataset } = accountPlansIndexContainer
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const props = safeFromJsonString<AccountPlansIndexPageProps>(dataset.plansIndex)!
    AccountPlansIndexPageWrapper({ ...props }, accountPlansIndexContainerId)
  }
})
