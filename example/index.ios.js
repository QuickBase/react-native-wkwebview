import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View
} from 'react-native';
import {WKWebView, WKCookieManager} from 'react-native-wkwebview-reborn';

export default class example extends Component {
  constructor(props) {
        super(props);
        this.state = {source: { uri: 'https://example.org/', cookies: {'testInitial' : 'from constructor'}}};
  }

  async setCookie(){
    let rand = Math.random()
    await WKCookieManager.setCookie("test", "value set from setCookie() " + rand, 600, "https://example.org/" )
    this.setState({source: { uri: 'https://example.org/?'+rand }});
  }

  async getCookie(){
    let val = await WKCookieManager.getCookie("test", "https://example.org/");
    console.log("GET COOKIE test = " + val);
    this.webview.reload()
  }

  async clearCookie(){
    let rand = Math.random()
    await WKCookieManager.clearCookies("https://example.org/")
    console.log("clearCookie")
    this.setState({source: { uri: 'https://example.org/?'+rand }});
  }

  async clearAllCookies(){
    let rand = Math.random()
    await WKCookieManager.clearAllCookies()
    console.log("clearAllCookies")
    this.setState({source: { uri: 'https://example.org/?'+rand }});
  }

  render() {
    return (
      <View style={{ flex: 1, marginTop: 20 }}>
        <WKWebView style={{ backgroundColor: '#ff0000' }}
          contentInsetAdjustmentBehavior="always"
          userAgent="MyFancyWebView"
          hideKeyboardAccessoryView={false}
          ref={(c) => this.webview = c}
          sendCookies={true}
          source={this.state.source}
          onMessage={(e) => console.log(e.nativeEvent)}
          injectedJavaScript="window.postMessage('Hello from WkWebView'); setTimeout(function(){alert(document.cookie); console.log(document.cookie);}, 1000);"
        />
        <Text style={{ fontWeight: 'bold', padding: 10 }} onPress={this.setCookie.bind(this)}>Set Cookie</Text>
        <Text style={{ fontWeight: 'bold', padding: 10 }} onPress={this.getCookie.bind(this)}>Get Cookie</Text>
        <Text style={{ fontWeight: 'bold', padding: 10 }} onPress={this.clearCookie.bind(this)}>Clear Cookie</Text>
        <Text style={{ fontWeight: 'bold', padding: 10 }} onPress={this.clearAllCookies.bind(this)}>Clear All Cookies</Text>
        <Text style={{ fontWeight: 'bold', padding: 10 }} onPress={() => this.webview.reload()}>Reload</Text>
        <Text style={{ fontWeight: 'bold', padding: 10 }} onPress={() => this.webview.postMessage("Hello from React Native")}>Post Message</Text>
      </View>
    );
  }
}

AppRegistry.registerComponent('example', () => example);
