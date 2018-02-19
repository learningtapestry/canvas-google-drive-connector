App.gdriveList = function(container) {
  var state = {folder_id: 'root', parents: [], index: 0};

  var fetchFolder = function() {
    container.empty();
    container.html('<div class="loader">Loading...</div>');

    $.ajax({
      type: 'POST',
      url: '/lti/gdrive-list',
      data: { folder_id: state.folder_id },
      headers: { 'X_CSRF_TOKEN': App.csrf_token },
      cache: false,
      success: function (resp) {
        container.html(resp);
        if (!state.parents[state.index - 1]) container.find('.gdrivelist-back').hide();
        bindEvents();
      }
    });

  }

  var bindEvents = function() {
    container.find('.gdrivelist-back a').on('click', function(e) {
      var el = $(e.target);
      state.folder_id = state.parents[state.index - 1];
      state.parents = state.parents.slice(0, state.index - 1);
      state.index -= 1;
      fetchFolder();
    });

    container.find('.gdrivelist-folder').on('click', function(e) {
      var el = $(e.target);
      state.parents.push(state.folder_id);
      state.folder_id = el.data('gdrive-id');
      state.index += 1;
      fetchFolder();
    });

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

  fetchFolder();
};
