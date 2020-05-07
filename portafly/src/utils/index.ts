export type Action<P> = {
  type: string,
  payload?: P
}

export type ActionHandlers<S> = Record<string, (state: S, action: Action<S>) => S>

const createReducer = (handlers: ActionHandlers<any>) => (
  (state: any, action: Action<any>): any => (
    handlers.hasOwnProperty(action.type) ? handlers[action.type](state, action) : state
  )
)
const combineReducers = (reducerSlices: Record<string, any>) => (
  (prevState: any, action: Action<any>) => Object.keys(reducerSlices).reduce(
    (nextState, nextProp) => ({
      ...nextState,
      [nextProp]: reducerSlices[nextProp](prevState[nextProp], action)
    }),
    prevState
  ))

export { createReducer, combineReducers }
