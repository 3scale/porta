// @flow

// eslint-disable-next-line flowtype/no-weak-types
const toJsonString = (val: Object): string => JSON.stringify(val, null, 2)

const fromJsonString = (json: string) => JSON.parse(json)

const safeFromJsonString = (json: string) => {
  try {
    return fromJsonString(json)
  } catch (err) {
    throw new Error(`That doesn't look like a valid json: ${json}`)
  }
}

export {
  toJsonString,
  fromJsonString,
  safeFromJsonString
}
