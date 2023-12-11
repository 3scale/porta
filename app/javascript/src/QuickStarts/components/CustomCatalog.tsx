/* eslint-disable @typescript-eslint/no-non-null-assertion */

import { useContext, useMemo } from 'react'
import {
  QuickStartCatalogHeader,
  QuickStartCatalogSection,
  QuickStartContext,
  QuickStartTile,
  getQuickStartStatus,
  LoadingBox
} from '@patternfly/quickstarts'
import {
  Gallery,
  GalleryItem,
  Text,
  TextContent
} from '@patternfly/react-core'

import type {
  QuickStart,
  QuickStartContextValues } from '@patternfly/quickstarts'

import './QuickStartContainer.scss'

export const CustomCatalog: React.FC = () => {
  const { activeQuickStartID, allQuickStartStates, allQuickStarts, loading } =
    useContext<QuickStartContextValues>(QuickStartContext)

  // eslint-disable-next-line @typescript-eslint/naming-convention -- Following PF team guidelines
  const CatalogWithSections = useMemo(
    () => (
      <>
        <QuickStartCatalogSection>
          <TextContent>
            <Text className="catalog" component="h2">3scale API Management features</Text>
          </TextContent>
          <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
            {allQuickStarts!
              .filter((quickStart: QuickStart) => quickStart.metadata.threescaleAPIManagementFeatures)
              .map((quickStart: QuickStart) => {
                const {
                  metadata: { name: id }
                } = quickStart
                return (
                  <GalleryItem key={id} className="pfext-quick-start-catalog__gallery-item">
                    <QuickStartTile
                      isActive={id === activeQuickStartID}
                      quickStart={quickStart}
                      status={getQuickStartStatus(allQuickStartStates!, id)}
                    />
                  </GalleryItem>
                )
              })}
          </Gallery>
        </QuickStartCatalogSection>
        <QuickStartCatalogSection>
          <TextContent>
            <Text className="catalog" component="h2">Common instance for creating and tracking APIs</Text>
          </TextContent>
          <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
            {allQuickStarts!
              .filter((quickStart: QuickStart) => quickStart.metadata.commonInstance)
              .map((quickStart: QuickStart) => {
                const {
                  metadata: { name: id }
                } = quickStart
                return (
                  <GalleryItem key={id} className="pfext-quick-start-catalog__gallery-item">
                    <QuickStartTile
                      isActive={id === activeQuickStartID}
                      quickStart={quickStart}
                      status={getQuickStartStatus(allQuickStartStates!, id)}
                    />
                  </GalleryItem>
                )
              })}
          </Gallery>
        </QuickStartCatalogSection>
        <QuickStartCatalogSection>
          <TextContent>
            <Text className="catalog" component="h2">Basic API integration setup</Text>
          </TextContent>
          <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
            {allQuickStarts!
              .filter((quickStart: QuickStart) => quickStart.metadata.basicAPIIntegrationSetup)
              .map((quickStart: QuickStart) => {
                const {
                  metadata: { name: id }
                } = quickStart
                return (
                  <GalleryItem key={id} className="pfext-quick-start-catalog__gallery-item">
                    <QuickStartTile
                      isActive={id === activeQuickStartID}
                      quickStart={quickStart}
                      status={getQuickStartStatus(allQuickStartStates!, id)}
                    />
                  </GalleryItem>
                )
              })}
          </Gallery>
        </QuickStartCatalogSection>
      </>
    ),
    [activeQuickStartID, allQuickStartStates, allQuickStarts]
  )

  const quickStartCatalog = useMemo(() => {
    return CatalogWithSections
  }, [CatalogWithSections, allQuickStarts!.length])

  if (loading) {
    return <LoadingBox />
  }

  return (
    <>
      <QuickStartCatalogHeader hint="Learn how to create, import, and run applications with step-by-step instructions and tasks." title="Quick starts" />
      {quickStartCatalog}
    </>
  )
}
