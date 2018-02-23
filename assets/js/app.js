//= require vendor/zepto
//= require_self
//= require_tree ./initializers

window.App = {
  initialize: function (opts) {
    var app = this;
    $.each(opts, function (el, fn) {
      var $el = $(el);
      if ($el.length > 0 && app[fn]) app[fn]($el);
    });
  },
  post: function(url, data, cb) {
    $.ajax({
      type: 'POST',
      url: url, data: data,
      cache: false,
      headers: { 'X_CSRF_TOKEN': App.csrf_token },
      success: cb
    });
  }
};

$(function() {
  App.csrf_token = $('meta[name="_csrf"]').attr('content');

  App.initialize({
    '.googleauth.authorize': 'googleauthAuthorize',
    '.googleauth.success': 'googleauthSuccess',
    '.file-browser': 'gdriveList'
  });
});
