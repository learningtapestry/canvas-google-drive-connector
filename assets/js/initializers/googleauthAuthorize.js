App.googleauthAuthorize = function() {
  var btn = $('.googleauth-btn'), nxt = $('.googleauth-next');
  btn.on('click', function () {
    btn.addClass('hide');
    setTimeout(function () { nxt.addClass('show') }, 500);
  });
};
