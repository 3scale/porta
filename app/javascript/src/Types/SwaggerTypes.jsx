// @flow

export type Primitive = string | number | boolean

export type AccountData = {
 [string]: Array<{ name: string, value: string }>
}

export type ParamArraySchema = {
 type: 'array',
 items: { type: Primitive }
}
export type ParamEnumSchema = {
 enum: Array<Primitive>,
 items: { type: Primitive }
}

export type Examples = Array<{
 summary: string,
 value: string
}>

export type Param = {
 in: string,
 name: string,
 description?: string,
 required?: boolean,
 schema?: Primitive | ParamArraySchema | ParamEnumSchema,
 examples?: Examples,
 'x-data-threescale-name': string
}

export type PathOperationObject = {
  [string]: string,
  servers?: {},
  responses?: {},
  parameters?: Array<Param>,
  ...
}

export type PathItemObject = {
  [string]: string | PathOperationObject,
  parameters?: Array<Param>
}

export type ResponseBody = {
 paths: {
   [string]: {
     parameters?: Array<Param>,
     get?: {
      parameters?: Array<Param>,
      [string]: string | {}
     },
     [string]: string | {}
   }
 },
 [string]: string | {}
}

export type SwaggerResponse = {
 body: ResponseBody | string,
 data: string,
 headers: {},
 obj: {},
 ok: boolean,
 status: number,
 statusText: string,
 text: string,
 url: string
}
