import React from 'react'

import { PageSection, Alert } from '@patternfly/react-core'
import { useAsync } from 'react-async'
import { Loading, ApplicationsTabDataListTable } from 'components'
import { getAccountApplications } from 'dal/account'

interface Props {
  accountId: string
}

const ApplicationsTabContent: React.FunctionComponent<Props> = ({ accountId }) => {
  const { data: applications, error, isPending } = useAsync(getAccountApplications, { accountId })

  return (
    <PageSection>
      {isPending && <Loading />}
      {error && <Alert variant="danger" title={error.message} />}
      {applications && <ApplicationsTabDataListTable applications={applications} />}
    </PageSection>
  )
}

export { ApplicationsTabContent }
