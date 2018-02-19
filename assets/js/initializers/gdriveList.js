App.gdriveList = function(container) {
  $.ajax({
    type: 'POST',
    url: '/lti/gdrive-list',
    data: {parent_id: 'root'},
    headers: {'X_CSRF_TOKEN': App.csrf_token},
    cache: false,
    success: function(resp) {
      container.html(resp)
      bindEvents();
    }
  });

  var bindEvents = function() {
    container.find('.gdrivelist-file').on('click', function(e) {
      var el = $(e.target);
      if (el.is('.selected .gdrivelist-actions a')) return;

      e.preventDefault();

      container.find('.gdrivelist-file.selected').removeClass('selected');
      container.find('.gdrivelist-file .gdrivelist-actions').remove();

      el.toggleClass('selected');
      el.append(`<span class="gdrivelist-actions"><a href="${el.data('link')}" target="_blank">Open</a></span>`);
    });
  }
};
