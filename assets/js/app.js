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
  }
};

$(function() {
  App.csrf_token = $('meta[name="_csrf"]').attr('content');

  App.initialize({
    '.googleauth.authorize': 'googleauthAuthorize',
    '.googleauth.success': 'googleauthSuccess',
    '.course-navigation': 'gdriveList'
  });
});
