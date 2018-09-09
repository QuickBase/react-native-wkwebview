'use strict';

import React from 'react';
import ReactNative, {
  NativeModules
} from 'react-native';

import WKWebView from './WKWebView';

const WKCookieManager = NativeModules.WKCookieManager;

export {WKWebView, WKCookieManager};
