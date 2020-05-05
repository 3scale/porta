export type Action = {
  type: string,
  payload?: any
}
export type State = Record<string, any>
export type ActionHandlers = Record<string, (state: State, action: Action) => State>

const createReducer = (handlers: ActionHandlers) => (
  (state: Record<string, any>, action: Action): State => (
    handlers.hasOwnProperty(action.type) ? handlers[action.type](state, action) : state
  )
)
const combineReducers = (reducerSlices: Record<string, any>) => (
  (prevState: State, action: Action) => Object.keys(reducerSlices).reduce(
    (nextState, nextProp) => ({
      ...nextState,
      [nextProp]: reducerSlices[nextProp](prevState[nextProp], action)
    }),
    prevState
  ))

export { createReducer, combineReducers }
