//= require vendor/zepto
//= require_self
//= require_tree ./initializers

window.App = {
  initialize: function (opts) {
    var app = this;
    $.each(opts, function (el, fn) { if ($(el).length > 0 && app[fn]) app[fn](); });
  }
};

$(function() {
  App.initialize({
    '.googleauth.authorize': 'googleauthAuthorize',
    '.googleauth.success': 'googleauthSuccess',
    '.gdrivelist': 'gdriveList'
  });
});
