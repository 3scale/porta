const devServerPort = 3035;

module.exports = {
  additionalPaths: [
    "app/javascript/src",
  ],
  cachePath: "tmp/cache/webpack",
  devServerPort,
  devServerManifestPublicPath: `http://localhost:${devServerPort}/packs/`,
  esbuildTarget: [ // See https://access.redhat.com/articles/2798521
    'chrome119',
    'firefox120',
    'edge119',
  ],
  publicOutputPath: "packs",
  publicRootPath: "public",
  sourceEntryPath: "packs",
  sourcePath: "app/javascript",
};
