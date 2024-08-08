const additionalPaths = [
  "app/javascript/src"
];
const cachePath = "tmp/cache/webpack";
const devServerPort = 3035;
const devServerManifestPublicPath = `http://localhost:${devServerPort}/packs/`;
const esbuildTarget = [
  'chrome119',
  'firefox120',
  'edge119'
];
const publicOutputPath = "packs";
const publicRootPath = "public";
const sourceEntryPath = "packs";
const sourcePath = "app/javascript";

module.exports = {
  additionalPaths,
  cachePath,
  devServerManifestPublicPath,
  devServerPort,
  esbuildTarget,
  publicOutputPath,
  publicRootPath,
  sourceEntryPath,
  sourcePath,
};
