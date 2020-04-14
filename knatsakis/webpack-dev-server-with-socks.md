```diff
diff --git a/web/console/webpack.dev.js b/web/console/webpack.dev.js
index 49787b3c..38ff4ec8 100644
--- a/web/console/webpack.dev.js
+++ b/web/console/webpack.dev.js
@@ -3,6 +3,7 @@ const path = require("path")
 const { BundleAnalyzerPlugin } = require("webpack-bundle-analyzer")
 const HtmlWebpackPlugin = require("html-webpack-plugin")
 const common = require("./webpack.common.js")
+const SocksHttpsClient = require('socks5-https-client/lib/Agent');
 
 module.exports = env => {
   const plugins =
@@ -29,13 +30,14 @@ module.exports = env => {
       disableHostCheck: true,
       proxy: {
         "/api": {
-          target: "https://localhost:8443",
-          secure: false,
+	  agent: new SocksHttpsClient({socksHost: '127.0.0.1', socksPort: 9050}),
+          changeOrigin: true,
+          target: "https://dev.private.netdata.cloud"
         },
         "/sso": {
-          target: "http://localhost:3001",
-          pathRewrite: { "^/sso": "" },
-          secure: false,
+	  agent: new SocksHttpsClient({socksHost: '127.0.0.1', socksPort: 9050}),
+          changeOrigin: true,
+          target: "https://dev.private.netdata.cloud"
         },
       },
     },
```
