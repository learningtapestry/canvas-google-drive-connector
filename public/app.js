(function() {
  var pageIs = function(selector) { return document.querySelector(selector); };

  // googleauth/success
  var initGoogleAuthSuccess = function() {
    setTimeout(window.close, 5000);
  };

  // googleauth/authorize
  var initGoogleAuthAuthorize = function() {
    var btn = document.querySelector('.googleauth-btn');
    var nxt = document.querySelector('.googleauth-next');
    btn.onclick = function () {
      btn.classList.add('hide');
      setTimeout(function () { nxt.classList.add('show') }, 500);
    };
  };

  // Start page initializers
  document.addEventListener("DOMContentLoaded", function(event) {
    if (pageIs('.googleauth.success')) initGoogleAuthSuccess();
    if (pageIs('.googleauth.authorize')) initGoogleAuthAuthorize();
  });
})();
