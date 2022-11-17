import { widget as makeWidgetRequest } from 'Dashboard'

export function loadAudienceWidget (widgetPath: string): void {
  makeWidgetRequest(widgetPath)
}
