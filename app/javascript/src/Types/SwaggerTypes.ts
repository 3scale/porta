export type AccountData = Record<string, Array<{
  name: string,
  value: string
}>>

// TODO: Rewrite all types below

export type Primitive = string | number | boolean;

export type ParamArraySchema = {
  type: 'array',
  items: {
    type: Primitive
  }
}

export type ParamEnumSchema = {
  enum: Array<Primitive>,
  items: {
    type: Primitive
  }
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
 ['x-data-threescale-name']: string
}

export type PathOperationObject = {
 servers?: Record<any, any>,
 responses?: Record<any, any>,
 parameters?: Array<Param>
}

export type PathItemObject = {
 parameters?: Array<Param>
}

export type ResponseBody = {
 paths: {
  [key: string]: {
   parameters?: Array<Param>,
   get?: {
    parameters?: Array<Param>,
    [key: string]: string | Record<any, any>
   },
   [key: string]: string | Record<any, any>
  }
 },
 [key: string]: string | Record<any, any>
}

export type SwaggerResponse = {
 body: ResponseBody | string,
 data: string,
 headers: Record<any, any>,
 obj: Record<any, any>,
 ok: boolean,
 status: number,
 statusText: string,
 text: string,
 url: string
}
