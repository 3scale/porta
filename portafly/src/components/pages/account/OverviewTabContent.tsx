import React from 'react'

import {
  Card,
  PageSection,
  Alert,
  GridItem,
  Grid,
  CardBody
} from '@patternfly/react-core'
import { Loading, StateLabel } from 'components'
import { useTranslation } from 'i18n/useTranslation'
import { IAccountOverview } from 'types'

interface Props {
  isPending: boolean
  account?: IAccountOverview
  error?: Error
}

const OverviewTabContent: React.FunctionComponent<Props> = ({ isPending, account, error }) => {
  const { t } = useTranslation('accountOverview')

  return (
    <PageSection>
      {isPending && <Loading />}
      {error && <Alert variant="danger" title={error.message} />}
      {account && (
      <Card>
        <CardBody>
          <Grid hasGutter>
            <GridItem rowSpan={2} span={3}>{t('overview.organization_label')}</GridItem>
            <GridItem rowSpan={2} span={9}>{account.orgName}</GridItem>

            <GridItem rowSpan={4} span={3}>{t('overview.administrator_label')}</GridItem>
            <GridItem rowSpan={2} span={9}>{account.adminName}</GridItem>
            <GridItem rowSpan={2} span={9}>
              <a href={`mailto:${account.adminEmail}`}>{account.adminEmail}</a>
            </GridItem>

            <GridItem rowSpan={2} span={3}>{t('overview.signup_label')}</GridItem>
            <GridItem rowSpan={2} span={9}>{account.createdAt}</GridItem>

            <GridItem rowSpan={2} span={3}>{t('overview.state_label')}</GridItem>
            <GridItem rowSpan={2} span={9}><StateLabel state={account.state} /></GridItem>
          </Grid>
        </CardBody>
      </Card>
      )}
    </PageSection>
  )
}

export { OverviewTabContent }
