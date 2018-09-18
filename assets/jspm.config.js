SystemJS.config({
  devConfig: {
    "map": {
      "constants": "npm:jspm-nodelibs-constants@0.2.0",
      "crypto": "npm:jspm-nodelibs-crypto@0.2.0",
      "child_process": "npm:jspm-nodelibs-child_process@0.2.0",
      "clean-css": "npm:clean-css@3.4.10",
      "http": "npm:jspm-nodelibs-http@0.2.0",
      "https": "npm:jspm-nodelibs-https@0.2.1",
      "buffer": "npm:jspm-nodelibs-buffer@0.2.0",
      "core-js": "npm:core-js@2.4.1",
      "events": "npm:jspm-nodelibs-events@0.2.0",
      "module": "npm:jspm-nodelibs-module@0.2.0",
      "net": "npm:jspm-nodelibs-net@0.2.0",
      "os": "npm:jspm-nodelibs-os@0.2.0",
      "stream": "npm:jspm-nodelibs-stream@0.2.0",
      "string_decoder": "npm:jspm-nodelibs-string_decoder@0.2.0",
      "tls": "npm:jspm-nodelibs-tls@0.2.0",
      "transform-object-rest-spread": "npm:babel-plugin-transform-object-rest-spread@6.16.0",
      "transform-react-jsx": "npm:babel-plugin-transform-react-jsx@6.8.0",
      "tty": "npm:jspm-nodelibs-tty@0.2.0",
      "url": "npm:jspm-nodelibs-url@0.2.0",
      "util": "npm:jspm-nodelibs-util@0.2.1",
      "zlib": "npm:jspm-nodelibs-zlib@0.2.0"
    },
    "packages": {
      "npm:asn1.js@4.6.0": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "inherits": "npm:inherits@2.0.1",
          "minimalistic-assert": "npm:minimalistic-assert@1.0.0"
        }
      },
      "npm:browserify-aes@1.0.6": {
        "map": {
          "buffer-xor": "npm:buffer-xor@1.0.3",
          "cipher-base": "npm:cipher-base@1.0.2",
          "create-hash": "npm:create-hash@1.1.2",
          "evp_bytestokey": "npm:evp_bytestokey@1.0.0",
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:browserify-cipher@1.0.0": {
        "map": {
          "browserify-aes": "npm:browserify-aes@1.0.6",
          "browserify-des": "npm:browserify-des@1.0.0",
          "evp_bytestokey": "npm:evp_bytestokey@1.0.0"
        }
      },
      "npm:browserify-des@1.0.0": {
        "map": {
          "cipher-base": "npm:cipher-base@1.0.2",
          "des.js": "npm:des.js@1.0.0",
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:browserify-rsa@4.0.1": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "randombytes": "npm:randombytes@2.0.3"
        }
      },
      "npm:browserify-sign@4.0.0": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "browserify-rsa": "npm:browserify-rsa@4.0.1",
          "create-hash": "npm:create-hash@1.1.2",
          "create-hmac": "npm:create-hmac@1.1.4",
          "elliptic": "npm:elliptic@6.2.3",
          "inherits": "npm:inherits@2.0.1",
          "parse-asn1": "npm:parse-asn1@5.0.0"
        }
      },
      "npm:browserify-zlib@0.1.4": {
        "map": {
          "pako": "npm:pako@0.2.8",
          "readable-stream": "npm:readable-stream@2.1.4"
        }
      },
      "npm:cipher-base@1.0.2": {
        "map": {
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:create-ecdh@4.0.0": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "elliptic": "npm:elliptic@6.2.3"
        }
      },
      "npm:create-hash@1.1.2": {
        "map": {
          "cipher-base": "npm:cipher-base@1.0.2",
          "inherits": "npm:inherits@2.0.1",
          "ripemd160": "npm:ripemd160@1.0.1",
          "sha.js": "npm:sha.js@2.4.5"
        }
      },
      "npm:create-hmac@1.1.4": {
        "map": {
          "create-hash": "npm:create-hash@1.1.2",
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:crypto-browserify@3.11.0": {
        "map": {
          "browserify-cipher": "npm:browserify-cipher@1.0.0",
          "browserify-sign": "npm:browserify-sign@4.0.0",
          "create-ecdh": "npm:create-ecdh@4.0.0",
          "create-hash": "npm:create-hash@1.1.2",
          "create-hmac": "npm:create-hmac@1.1.4",
          "diffie-hellman": "npm:diffie-hellman@5.0.2",
          "inherits": "npm:inherits@2.0.1",
          "pbkdf2": "npm:pbkdf2@3.0.4",
          "public-encrypt": "npm:public-encrypt@4.0.0",
          "randombytes": "npm:randombytes@2.0.3"
        }
      },
      "npm:des.js@1.0.0": {
        "map": {
          "inherits": "npm:inherits@2.0.1",
          "minimalistic-assert": "npm:minimalistic-assert@1.0.0"
        }
      },
      "npm:diffie-hellman@5.0.2": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "miller-rabin": "npm:miller-rabin@4.0.0",
          "randombytes": "npm:randombytes@2.0.3"
        }
      },
      "npm:elliptic@6.2.3": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "brorand": "npm:brorand@1.0.5",
          "hash.js": "npm:hash.js@1.0.3",
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:evp_bytestokey@1.0.0": {
        "map": {
          "create-hash": "npm:create-hash@1.1.2"
        }
      },
      "npm:hash.js@1.0.3": {
        "map": {
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:miller-rabin@4.0.0": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "brorand": "npm:brorand@1.0.5"
        }
      },
      "npm:parse-asn1@5.0.0": {
        "map": {
          "asn1.js": "npm:asn1.js@4.6.0",
          "browserify-aes": "npm:browserify-aes@1.0.6",
          "create-hash": "npm:create-hash@1.1.2",
          "evp_bytestokey": "npm:evp_bytestokey@1.0.0",
          "pbkdf2": "npm:pbkdf2@3.0.4"
        }
      },
      "npm:pbkdf2@3.0.4": {
        "map": {
          "create-hmac": "npm:create-hmac@1.1.4"
        }
      },
      "npm:public-encrypt@4.0.0": {
        "map": {
          "bn.js": "npm:bn.js@4.11.3",
          "browserify-rsa": "npm:browserify-rsa@4.0.1",
          "create-hash": "npm:create-hash@1.1.2",
          "parse-asn1": "npm:parse-asn1@5.0.0",
          "randombytes": "npm:randombytes@2.0.3"
        }
      },
      "npm:sha.js@2.4.5": {
        "map": {
          "inherits": "npm:inherits@2.0.1"
        }
      },
      "npm:stream-http@2.3.0": {
        "map": {
          "builtin-status-codes": "npm:builtin-status-codes@2.0.0",
          "inherits": "npm:inherits@2.0.1",
          "readable-stream": "npm:readable-stream@2.1.4",
          "to-arraybuffer": "npm:to-arraybuffer@1.0.1",
          "xtend": "npm:xtend@4.0.1"
        }
      },
      "npm:clean-css@3.4.10": {
        "map": {
          "commander": "npm:commander@2.8.1",
          "source-map": "npm:source-map@0.4.4"
        }
      },
      "npm:commander@2.8.1": {
        "map": {
          "graceful-readlink": "npm:graceful-readlink@1.0.1"
        }
      },
      "npm:source-map@0.4.4": {
        "map": {
          "amdefine": "npm:amdefine@1.0.0"
        }
      },
      "npm:stream-browserify@2.0.1": {
        "map": {
          "inherits": "npm:inherits@2.0.1",
          "readable-stream": "npm:readable-stream@2.1.4"
        }
      },
      "npm:url@0.11.0": {
        "map": {
          "punycode": "npm:punycode@1.3.2",
          "querystring": "npm:querystring@0.2.0"
        }
      },
      "npm:babel-plugin-transform-react-jsx@6.8.0": {
        "map": {
          "babel-runtime": "npm:babel-runtime@6.18.0",
          "babel-plugin-syntax-jsx": "npm:babel-plugin-syntax-jsx@6.18.0",
          "babel-helper-builder-react-jsx": "npm:babel-helper-builder-react-jsx@6.18.0"
        }
      },
      "npm:readable-stream@2.1.4": {
        "map": {
          "inherits": "npm:inherits@2.0.1",
          "util-deprecate": "npm:util-deprecate@1.0.2",
          "string_decoder": "npm:string_decoder@0.10.31",
          "core-util-is": "npm:core-util-is@1.0.2",
          "process-nextick-args": "npm:process-nextick-args@1.0.7",
          "buffer-shims": "npm:buffer-shims@1.0.0",
          "isarray": "npm:isarray@1.0.0"
        }
      },
      "npm:buffer@4.7.1": {
        "map": {
          "isarray": "npm:isarray@1.0.0",
          "base64-js": "npm:base64-js@1.1.2",
          "ieee754": "npm:ieee754@1.1.6"
        }
      },
      "npm:jspm-nodelibs-crypto@0.2.0": {
        "map": {
          "crypto-browserify": "npm:crypto-browserify@3.11.0"
        }
      },
      "npm:jspm-nodelibs-stream@0.2.0": {
        "map": {
          "stream-browserify": "npm:stream-browserify@2.0.1"
        }
      },
      "npm:jspm-nodelibs-buffer@0.2.0": {
        "map": {
          "buffer-browserify": "npm:buffer@4.7.1"
        }
      },
      "npm:jspm-nodelibs-os@0.2.0": {
        "map": {
          "os-browserify": "npm:os-browserify@0.2.0"
        }
      },
      "npm:jspm-nodelibs-url@0.2.0": {
        "map": {
          "url-browserify": "npm:url@0.11.0"
        }
      },
      "npm:jspm-nodelibs-zlib@0.2.0": {
        "map": {
          "zlib-browserify": "npm:browserify-zlib@0.1.4"
        }
      },
      "npm:jspm-nodelibs-string_decoder@0.2.0": {
        "map": {
          "string_decoder-browserify": "npm:string_decoder@0.10.31"
        }
      },
      "npm:jspm-nodelibs-http@0.2.0": {
        "map": {
          "http-browserify": "npm:stream-http@2.3.0"
        }
      },
      "npm:babel-plugin-transform-object-rest-spread@6.16.0": {
        "map": {
          "babel-plugin-syntax-object-rest-spread": "npm:babel-plugin-syntax-object-rest-spread@6.13.0",
          "babel-runtime": "npm:babel-runtime@6.18.0"
        }
      },
      "npm:babel-helper-builder-react-jsx@6.18.0": {
        "map": {
          "babel-runtime": "npm:babel-runtime@6.18.0",
          "lodash": "npm:lodash@4.17.0",
          "babel-types": "npm:babel-types@6.18.0",
          "esutils": "npm:esutils@2.0.2"
        }
      },
      "npm:babel-types@6.18.0": {
        "map": {
          "babel-runtime": "npm:babel-runtime@6.18.0",
          "lodash": "npm:lodash@4.17.0",
          "esutils": "npm:esutils@2.0.2",
          "to-fast-properties": "npm:to-fast-properties@1.0.2"
        }
      },
      "npm:babel-runtime@6.18.0": {
        "map": {
          "regenerator-runtime": "npm:regenerator-runtime@0.9.6",
          "core-js": "npm:core-js@2.4.1"
        }
      }
    }
  },
  transpiler: "plugin-babel",
  babelOptions: {
    "plugins": [
      "transform-object-rest-spread",
      "transform-react-jsx"
    ]
  },
  packages: {
    "stats": {
      "defaultExtension": "es6",
      "main": "index",
      "meta": {
        "*.js": true
      }
    },
    "onboarding": {
      "defaultExtension": "es6",
      "main": "bubbles",
      "meta": {
        "*.js": true
      }
    },
    "dashboard": {
      "defaultExtension": "es6",
      "main": "index",
      "meta": {
        "*.js": true
      }
    },
    "utilities": {
      "defaultExtension": "es6",
      "meta": {
        "*.js": true
      }
    },
    "services": {
      "defaultExtension": "es6",
      "main": "index",
      "meta": {
        "*.js": true
      }
    }
  },
  meta: {
    "jquery-ui/ui/*": {
      "deps": [
        "jquery"
      ],
      "globals": {
        "jQuery": "jquery"
      }
    }
  },
  map: {
    "jspm-hot-reload": "@empty"
  }
});

SystemJS.config({
  packageConfigPaths: [
    "npm:@*/*.json",
    "npm:*.json",
    "github:*/*.json"
  ],
  map: {
    "css": "github:systemjs/plugin-css@0.1.32",
    "c3": "npm:c3@0.4.11",
    "decca": "npm:decca@2.2.2",
    "classnames": "npm:classnames@2.2.5",
    "assert": "npm:jspm-nodelibs-assert@0.2.0",
    "fetch": "github:github/fetch@0.9.0",
    "fs": "npm:jspm-nodelibs-fs@0.2.0",
    "jquery": "github:components/jquery@2.1.4",
    "jquery-ui": "github:components/jqueryui@1.11.4",
    "jspm-nodelibs-path": "npm:jspm-nodelibs-path@0.2.1",
    "jspm-nodelibs-util": "npm:jspm-nodelibs-util@0.2.1",
    "moment": "npm:moment@2.15.0",
    "moment-range": "npm:moment-range@2.2.0",
    "moment-timezone": "npm:moment-timezone@0.5.5",
    "numeral": "npm:numeral@1.5.3",
    "path": "npm:jspm-nodelibs-path@0.2.1",
    "plugin-babel": "npm:systemjs-plugin-babel@0.0.17",
    "pluralize": "npm:pluralize@1.2.1",
    "process": "npm:jspm-nodelibs-process@0.2.0",
    "select2": "github:select2/select2@4.0.1",
    "virtual-dom": "npm:virtual-dom@2.1.1",
    "vm": "npm:jspm-nodelibs-vm@0.2.0"
  },
  packages: {
    "github:components/jqueryui@1.11.4": {
      "map": {
        "jquery": "github:components/jquery@2.1.4"
      }
    },
    "github:select2/select2@4.0.1": {
      "map": {
        "jquery": "npm:jquery@2.2.1"
      }
    },
    "npm:error@4.4.0": {
      "map": {
        "camelize": "npm:camelize@1.0.0",
        "string-template": "npm:string-template@0.2.1",
        "xtend": "npm:xtend@4.0.1"
      }
    },
    "npm:ev-store@7.0.0": {
      "map": {
        "individual": "npm:individual@3.0.0"
      }
    },
    "npm:global@4.3.0": {
      "map": {
        "min-document": "npm:min-document@2.18.0",
        "node-min-document": "npm:min-document@2.18.0",
        "process": "npm:process@0.5.2"
      }
    },
    "npm:min-document@2.18.0": {
      "map": {
        "dom-walk": "npm:dom-walk@0.1.1"
      }
    },
    "npm:next-tick@0.2.2": {
      "map": {}
    },
    "npm:virtual-dom@2.1.1": {
      "map": {
        "browser-split": "npm:browser-split@0.0.1",
        "error": "npm:error@4.4.0",
        "ev-store": "npm:ev-store@7.0.0",
        "global": "npm:global@4.3.0",
        "is-object": "npm:is-object@1.0.1",
        "next-tick": "npm:next-tick@0.2.2",
        "x-is-array": "npm:x-is-array@0.1.0",
        "x-is-string": "npm:x-is-string@0.1.0"
      }
    },
    "npm:c3@0.4.11": {
      "map": {
        "d3": "npm:d3@3.5.17",
        "css": "github:systemjs/plugin-css@0.1.32"
      }
    },
    "npm:moment-timezone@0.5.5": {
      "map": {
        "moment": "npm:moment@2.15.0"
      }
    },
    "npm:decca@2.2.2": {
      "map": {
        "simpler-debounce": "npm:simpler-debounce@1.0.0",
        "virtual-dom": "npm:virtual-dom@2.1.1"
      }
    }
  }
});
