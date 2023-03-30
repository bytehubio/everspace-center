window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">
  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  window.ui = SwaggerUIBundle({
    url: window.location.origin + "/everscale-rfld/swagger",
    // urls: [{url: "http://127.0.0.1:8181/everscale/swagger", name: "Main"}, {url: "http://127.0.0.1:8181/everscale/swagger", name: "Main2"}],
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout",
    onComplete: function() {
      // console.log("ui");
      // console.log(ui);
      // ui.preauthorizeApiKey("api_key", "abcde12345");
      // ui.preauthorizeBasic("auth_basic", "username", "password");
      // ui.auth();
    },
    requestInterceptor: function (req) {
      req.headers = {
        // 'Authorization': 'Bearer ' + document.getElementById('bearer-code-input').value, 
        'Authorization': 'Bearer ' + 'qwerty', 
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };
      return req;
    }
  });

  //</editor-fold>
};
