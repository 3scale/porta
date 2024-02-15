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

type CustomQuickStart = (QuickStart & {
  metadata: QuickStart['metadata'] & {
    category: string;
  };
})

export const CustomCatalog: React.FC = () => {
  const { activeQuickStartID, allQuickStartStates, allQuickStarts, loading } =
    useContext<QuickStartContextValues>(QuickStartContext)

  const sections = (allQuickStarts as CustomQuickStart[]).reduce<Record<string, CustomQuickStart[]>>((previousSections, quickstart) => {
    const { category } = quickstart.metadata
    if (!Array.isArray(previousSections[category])) {
      previousSections[category] = []
    }

    previousSections[category].push(quickstart)

    return previousSections
  }, {})

  // eslint-disable-next-line @typescript-eslint/naming-convention -- Following PF team guidelines
  const CatalogWithSections = useMemo(() => {
    return (
      <>
        {Object.keys(sections).map(key => (
          <QuickStartCatalogSection key={key}>
            <TextContent>
              <Text className="catalog" component="h2">{key}</Text>
            </TextContent>
            <Gallery hasGutter className="pfext-quick-start-catalog__gallery">
              {sections[key].map((quickStart) => {
                const {
                  metadata: { name: id }
                } = quickStart
                return (
                  <GalleryItem key={id} className="pfext-quick-start-catalog__gallery-item">
                    <QuickStartTile
                      isActive={id === activeQuickStartID}
                      quickStart={quickStart}
                      status={getQuickStartStatus(allQuickStartStates!, id!)}
                    />
                  </GalleryItem>
                )
              })}
            </Gallery>
          </QuickStartCatalogSection>
        ))}
      </>
    )
  }, [activeQuickStartID, allQuickStartStates, allQuickStarts])

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
