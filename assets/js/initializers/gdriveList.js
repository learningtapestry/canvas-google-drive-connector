App.gdriveList = function(container) {
  var state = {folder_id: 'root', parents: [], index: 0};
  var browserType = container.data('browser-type');

  var fetchFolder = function() {
    clear();
    App.post('/lti/gdrive-list', { folder_id: state.folder_id, browser_type: browserType}, update);
  }

  var clear = function () {
    container.off('click');
    container.empty();
    container.html('<div class="loader">Loading...</div>');
  }

  var update = function (content) {
    container.html(content);
    if (!state.parents[state.index - 1]) container.find('.gdrivelist-back').hide();
    bindEvents();
  }

  var bindEvents = function() {
    container.find('.gdrivelist-back a').on('click', function (_e) {
      state.folder_id = state.parents[state.index - 1];
      state.parents = state.parents.slice(0, state.index - 1);
      state.index -= 1;
      fetchFolder();
    });

    container.find('.gdrivelist-folder').on('click', function (e) {
      state.parents.push(state.folder_id);
      state.folder_id = $(e.target).data('gdrive-id');
      state.index += 1;
      fetchFolder();
    });

    container.find('.gdrivelist-file').on('click', function (e) {
      var el = $(e.target);
      if (el.is('.selected .gdrivelist-actions .action')) return;

      e.preventDefault();
      container.find('.gdrivelist-file.selected').removeClass('selected');
      el.toggleClass('selected');
    });
  }

  fetchFolder();
};
