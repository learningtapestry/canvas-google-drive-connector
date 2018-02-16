//= require vendor/zepto
//= require vendor/vue

(function() {
  var pageHas = function(selector) { return $(selector).length > 0; };

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

  // lti/gdrive-list
  var initGDriveList = function() {
    var folders = document.querySelectorAll('.gdrivelist-folder');
    for (var i = 0; i < folders.length; i++) {
      var folder = folders[i];
      folder.onclick = function() {

      };
    }
  };

  // Start page initializers
  document.addEventListener("DOMContentLoaded", function(event) {
    if (pageHas('.googleauth.success')) initGoogleAuthSuccess();
    if (pageHas('.googleauth.authorize')) initGoogleAuthAuthorize();
    if (pageHas('.gdrivelist')) initGDriveList();
  });
})();
