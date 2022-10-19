"use strict";
exports.__esModule = true;
require("@babel/polyfill");
require("core-js/es7/object");
var RequestPasswordWrapper_1 = require("LoginPage/RequestPasswordWrapper");
var json_utils_1 = require("utilities/json-utils");
document.addEventListener('DOMContentLoaded', function () {
    var containerId = 'pf-request-page-container';
    var container = document.getElementById(containerId);
    if (!container) {
        throw new Error('The target ID was not found: ' + containerId);
    }
    var requestPageProps = (0, json_utils_1.safeFromJsonString)(container.dataset.requestProps);
    (0, RequestPasswordWrapper_1.RequestPasswordWrapper)(requestPageProps, containerId);
});
