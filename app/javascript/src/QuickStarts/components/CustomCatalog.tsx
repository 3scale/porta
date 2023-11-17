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
            <Text className="catalog" component="h2">Learn about 3scale features</Text>
          </TextContent>
          <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
            {allQuickStarts!
              .filter((quickStart: QuickStart) => quickStart.metadata.learnAbout3scaleFeatures)
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
            <Text className="catalog" component="h2">Common instances</Text>
          </TextContent>
          <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
            {allQuickStarts!
              .filter((quickStart: QuickStart) => quickStart.metadata.commonInstances)
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
            <Text className="catalog" component="h2">Learning resources</Text>
          </TextContent>
          <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
            {allQuickStarts!
              .filter((quickStart: QuickStart) => quickStart.metadata.learningResources)
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
