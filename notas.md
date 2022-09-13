https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/app/javascript/src/ChangePassword/components/ChangePasswordHooks.jsx#L87

  This condition will always return 'false' since the types 'boolean' and 'string' have no overlap.ts(2367)

https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/app/javascript/src/ChangePassword/components/ChangePasswordHooks.jsx#L8
https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/app/javascript/src/ChangePassword/components/ChangePasswordHooks.jsx#L24

  Type '{ minimum: number; message: string; }' is not assignable to type 'ValidatorOption'.
  Object literal may only specify known properties, but 'minimum' does not exist in type 'ValidatorOption'. Did you mean to write 'minimun'?ts(2322)

https://github.com/3scale/porta/blob/e7845856a42cc58a85376568c11b1df72e5cb56b/spec/javascripts/LoginPage/Login3scaleForm.spec.jsx#L40

  Cannot invoke an object which is possibly 'undefined'.ts(2722)

  Nota: esto es de hecho mal. onChange es opcional, entonces TS se queja. Lo ideal sería de alguna manera forzar un typo o decirle que onChange existe para el proposito de nuestro test, sin embargo no parece posible hacerlo de manera legible sin introducir 203224 casteos. La solucion más facil parece ser añadir un null-check y punto.
  UPDATE: resulta que el null check assertion '!' era la solucion correcta. Entonces eslint se queja pero ponemos un eslintrc para spec/javascripts deshabilitando esa regla y punto.

https://github.com/3scale/porta/blob/6a049b5184f93ccc4f8f8aff8bb85750c7dbdff3/app/javascript/packs/add_backend_usage.js#L1

  Para que funcione la herramienta de migración, el fichero debe usar @flow. Dentro de la carpeta packs tenemos muchos archivos que no lo usan, habrá que hacerlos a mano.