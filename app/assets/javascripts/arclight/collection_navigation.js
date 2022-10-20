  const CollectionNavigation = {
    init: function (el, page = 1) {
      const data = JSON.parse(el.dataset.arclight)
      // Add a placeholder so flashes of text are not as significant
      var placeholder = '<div class="al-hierarchy-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
      placeholder = new Array(3).join(placeholder)
      el.innerHtml = placeholder

      const params = new URLSearchParams({
        'f[component_level_isim][]': data.level,
        'f[collection_sim][]': data.name,
        'f[parent_ssim][]': data.parent,
        page: page,
        search_field: data.search_field,
        view: data.view || 'hierarchy'
      });
      if (data.access) {
        params.append('f[has_online_content_ssim][]', data.access);
      }

      fetch(data.path + '?' + params)
      .then((response) => response.text())
      .then((body) => {
        const parser = new DOMParser()
        const doc = parser.parseFromString(body, 'text/html')
        const showDocs = doc.querySelectorAll('article.document') // The list of search results
        const newDocs = doc.querySelector('#documents') // The container that holds the search results
        const sortPerPage = doc.querySelector('#sortAndPerPage') // The row on the search page that has prev/next, per-page and relevance controls

        // Hide these until we re-enable in the future
        sortPerPage.querySelector('.result-type-group').hidden = true// Arclight's "Group by collection / All results"
        sortPerPage.querySelector('.search-widgets').hidden = true // Sort by and per-page widgets.

        sortPerPage.querySelectorAll('a').forEach((anchor) => {
          anchor.addEventListener('click', (e) => {
            // Make the previous and next links work via javascript and not as regular links
            e.preventDefault()
            const pages = /page=(\d+)&/.exec(e.target.getAttribute('href'));
            if (pages) {
              CollectionNavigation.init(el, pages[1])
            } else {
              // Case where the "first" page
              CollectionNavigation.init(el)
            }
          })
        })

        // Remove the placeholder and display the loaded docs.
        el.replaceChildren(sortPerPage, newDocs)
        if (showDocs.length > 0) {
          const event = new CustomEvent('navigation.contains.elements')
          el.dispatchEvent(event)
        }
      });
    }
  };

  Blacklight.onLoad(function () {
    'use strict';

    $('[data-controller="arclight-contents"]').each(function (i, element) {
      CollectionNavigation.init(element); // eslint-disable-line no-undef
    });

    $('[data-controller="arclight-contents"]').on('navigation.contains.elements', function (e) {
      $(e.target).find('.collapse').on('show.bs.collapse', function (ee) {
        var $newTarget = $(ee.target);
        $newTarget.find('[data-controller="arclight-contents"]').each(function (i, element) {
          CollectionNavigation.init(element); // eslint-disable-line no-undef
        // Turn off additional ajax requests on show
          $newTarget.off('show.bs.collapse');
        });
      });
    });
  });
