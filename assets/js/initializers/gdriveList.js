App.gdriveList = function(container) {
  $.ajax({
    type: 'POST',
    url: '/lti/gdrive-list',
    data: {parent_id: 'root'},
    headers: {'X_CSRF_TOKEN': App.csrf_token},
    cache: false,
    success: function(resp) {
      container.html(resp)
    },
    error: function(err) {
      alert('Failed loading the google drive folder');
    }
  });
};
