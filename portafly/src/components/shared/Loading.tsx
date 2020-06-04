import * as React from 'react'
import {
  EmptyState,
  EmptyStateIcon,
  EmptyStateVariant,
  PageSection,
  Title,
  Spinner
} from '@patternfly/react-core'
import { useTranslation } from 'i18n/useTranslation'

export const Loading: React.FunctionComponent = () => {
  const { t } = useTranslation('shared')
  return (
    <PageSection aria-label={t('loading.aria_label')}>
      <EmptyState variant={EmptyStateVariant.full}>
        <EmptyStateIcon variant="container" component={Spinner} />
        <Title headingLevel="h2" size="lg">{t('loading.title')}</Title>
      </EmptyState>
    </PageSection>
  )
}
