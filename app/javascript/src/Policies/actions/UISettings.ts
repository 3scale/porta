import { Action } from 'redux'

export type UIComponent = 'chain' | 'registry' | 'policyConfig';

export type ShowUIComponentAction = Action<'SHOW_UI_COMPONENT'> & {
  component: UIComponent
};
export function showUiComponent (component: UIComponent): ShowUIComponentAction {
  return { type: 'SHOW_UI_COMPONENT', component }
}

export type HideUIComponentAction = Action<'HIDE_UI_COMPONENT'> & {
  component: UIComponent
};
export function hideUiComponent (component: UIComponent): HideUIComponentAction {
  return { type: 'HIDE_UI_COMPONENT', component }
}

export type UIComponentTransitionAction = Action<'UI_COMPONENT_TRANSITION'> & {
  hide: UIComponent,
  show: UIComponent
};
export function uiComponentTransition ({ hide, show }: { hide: UIComponent, show: UIComponent }): UIComponentTransitionAction {
  return { type: 'UI_COMPONENT_TRANSITION', hide, show }
}
