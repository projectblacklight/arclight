(function (global) {
  var CollectionNavigation;

  CollectionNavigation = {
    init: function (el, page = 1) {
      var $el = $(el);
      var data = $el.data();
      // Add a placeholder so flashes of text are not as significant
      var placeholder = '<div class="al-hierarchy-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
      placeholder = new Array(3).join(placeholder);
      $el.html(placeholder);
      $.ajax({
        url: data.arclight.path,
        data: {
          'f[component_level_isim][]': data.arclight.level,
          'f[has_online_content_ssim][]': data.arclight.access,
          'f[collection_sim][]': data.arclight.name,
          'f[parent_ssim][]': data.arclight.parent,
          page: page,
          search_field: data.arclight.search_field,
          view: data.arclight.view || 'hierarchy'
        }
      }).done(function (response) {
        var resp = $.parseHTML(response);
        var $doc = $(resp);
        var showDocs = $doc.find('article.document');
        var newDocs = $doc.find('#documents');
        var sortPerPage = $doc.find('#sortAndPerPage');
        var pageEntries = sortPerPage.find('.page-entries');
        var numberEntries = parseInt(pageEntries.find('strong').last().text().replace(/,/g, ''), 10);

        // Hide these until we re-enable in the future
        sortPerPage.find('.result-type-group').hide();
        sortPerPage.find('.search-widgets').hide();

        if (!isNaN(numberEntries)) {
          $('[data-arclight-online-content-tab-count]').html(
            $(
              '<span class="badge badge-pill badge-secondary al-online-content-badge">'
                + numberEntries
                + '<span class="sr-only">components</span></span>'
            )
          );
        }

        sortPerPage.find('a').on('click', function (e) {
          var pages = [];
          var $target = $(e.target);
          e.preventDefault();
          pages = /page=(\d+)&/.exec($target.attr('href'));
          if (pages) {
            CollectionNavigation.init($el, pages[1]);
          } else {
            // Case where the "first" page
            CollectionNavigation.init($el);
          }
        });

        $el.hide().html('').append(sortPerPage).append(newDocs)
          .fadeIn(500);
        if (showDocs.length > 0) {
          $el.trigger('navigation.contains.elements');
        }
        Blacklight.doBookmarkToggleBehavior();
      });
    }
  };

  global.CollectionNavigation = CollectionNavigation;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('.al-contents').each(function (i, element) {
    CollectionNavigation.init(element); // eslint-disable-line no-undef
  });

  $('.al-contents').on('navigation.contains.elements', function (e) {
    var toEnable = $('[data-hierarchy-enable-me]');
    var srOnly = $('h2[data-sr-enable-me]');
    toEnable.removeClass('disabled');
    toEnable.text(srOnly.data('hasContents'));
    srOnly.text(srOnly.data('hasContents'));

    $(e.target).find('.collapse').on('show.bs.collapse', function (ee) {
      var $newTarget = $(ee.target);
      $newTarget.find('.al-contents').each(function (i, element) {
        CollectionNavigation.init(element); // eslint-disable-line no-undef
        // Turn off additional ajax requests on show
        $newTarget.off('show.bs.collapse');
      });
    });
  });
});
