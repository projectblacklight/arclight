class NavigationDocument {
  constructor(el) {
    this.el = $(el);
  }

  get id() {
    return this.el.find('[data-document-id]').data().documentId;
  }

  setAsHighlighted() {
    this.el.find('li.al-collection-context').addClass('al-hierarchy-highlight');
  }

  collapse() {
    this.el.find('li.al-collection-context').addClass('collapsed');
  }

  render() {
    return this.el.html();
  }
}

class ContextNavigation {
  constructor(el) {
    this.el = $(el);
    this.data = this.el.data();
    this.parentLi = this.el.parent();
  }

  static placeholder() {
    const placeholder = '<div class="al-hierarchy-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
    return new Array(3).join(placeholder);
  }

  getData() {
    const that = this;
    // Add a placeholder so flashes of text are not as significant
    this.el.after(ContextNavigation.placeholder());

    $.ajax({
      url: this.data.arclight.path,
      data: {
        'f[component_level_isim][]': this.data.arclight.level,
        'f[has_online_content_ssim][]': this.data.arclight.access,
        'f[collection_sim][]': this.data.arclight.name,
        'f[parent_ssi][]': this.data.arclight.parent,
        search_field: this.data.arclight.search_field,
        view: 'collection_context'
      }
    }).done((response) => that.updateView(response));
  }

  updateView(response) {
    const that = this;
    var resp = $.parseHTML(response);
    var $doc = $(resp);
    var newDocs = $doc.find('#documents')
      .find('article')
      .toArray().map(el => new NavigationDocument(el));

    // Filter for only the <article> element which encodes the information for
    // the child or parent Solr Document
    const originalDocumentIndex = newDocs
      .findIndex(doc => doc.id === that.data.arclight.originalDocument);
    that.parentLi.find('.al-hierarchy-placeholder').remove();

    // Case where this is the sibling tree of the current document
    // If the response does contain any <article> elements for the child or
    // parent Solr Documents, then the documents are treated as sibling nodes
    if (originalDocumentIndex !== -1) {
      newDocs[originalDocumentIndex].setAsHighlighted();

      const prevSiblingDocs = newDocs.slice(0, originalDocumentIndex);
      let nextSiblingDocs = [];

      // If there are more than 1 siblings, hide them all but the first
      if (prevSiblingDocs.length > 1 && originalDocumentIndex > 0) {
        const hiddenPrevSiblingDocs = prevSiblingDocs.slice(0, -1);
        hiddenPrevSiblingDocs.forEach(function (siblingDoc) {
          siblingDoc.collapse();
        });

        // Add the "expand" button
        // @todo this needs to be refactored
        const parentUl = $('ul.parent');
        const collapseText = parentUl[0].dataset.dataCollapse;
        const expandText = parentUl[0].dataset.dataExpand;
        const $expandButton = $(`<button class="my-3 btn btn-secondary btn-sm">${expandText}</button>`);
        const prevSiblingContainer = $('<ul class="pl-0 prev-siblings"></ul>');
        prevSiblingContainer.append($expandButton);
        $expandButton.click((event) => {
          const $target = $(event.target);
          const children = $target.parent().children('li');
          const targetedChildren = children.slice(0, -1);
          targetedChildren.toggleClass('collapsed');
          $target.toggleClass('collapsed');
          const targetText = $target.hasClass('collapsed') ? collapseText : expandText;
          $target.text(targetText);
        });

        // Render the docs as <li> elements and append them to the DOM
        const renderedPrevSiblingItems = prevSiblingDocs.map(doc => doc.render()).join('');
        prevSiblingContainer.append(renderedPrevSiblingItems);
        that.parentLi.before(prevSiblingContainer);
        nextSiblingDocs = newDocs.slice(originalDocumentIndex);
      } else {
        nextSiblingDocs = newDocs;
      }

      const renderedNextSiblingItems = nextSiblingDocs.map(newDoc => newDoc.render()).join('');

      // Insert the rendered sibling documents before the <li> elements
      that.parentLi.before(renderedNextSiblingItems).fadeIn(500);
    } else {
      // Case where this is a parent list and needs to be filed correctly
      //
      // Otherwise, retrieve the parent...
      const parentIndex = that.data.arclight.originalParents.indexOf(that.data.arclight.parent);
      const currentId = `${that.data.arclight.originalParents[0]}${that.data.arclight.originalParents[parentIndex + 1]}`;
      const newDocIndex = newDocs.findIndex(doc => doc.id === currentId);

      // Update the docs before the item
      // TODO: Add a class or something that doesn't display these until the expando is clicked
      // Retrieves the documents up to and including the "new document"
      const beforeDocs = newDocs.slice(0, newDocIndex);

      let renderedBeforeDocs = beforeDocs.map(newDoc => newDoc.render()).join('');
      that.parentLi.before(renderedBeforeDocs).fadeIn(500);

      let itemDoc = newDocs.slice(newDocIndex, newDocIndex + 1);
      let renderedItemDoc = itemDoc.map(doc => doc.render()).join('');

      // Update the item
      const $itemDoc = $(renderedItemDoc);
      // Update the id, add classes of the classes. Prepend the current children.
      that.parentLi.attr('id', $itemDoc.attr('id'));
      that.parentLi.addClass($itemDoc.attr('class'));
      that.parentLi.prepend($itemDoc.children()).fadeIn(500);
      // Update the docs after the item
      const afterDocs = newDocs.slice(newDocIndex + 1, newDocs.length);
      const renderedAfterDocs = afterDocs.map(newDoc => newDoc.render()).join('');
      // Insert the documents after the current
      that.parentLi.after(renderedAfterDocs).fadeIn(500);
    }
    that.truncateItems();
    Blacklight.doBookmarkToggleBehavior();
  }

  // eslint-disable-next-line class-methods-use-this
  truncateItems() {
    $('[data-arclight-truncate="true"]').each(function (_, el) {
      $(el).responsiveTruncate({
        more: el.dataset.truncateMore,
        less: el.dataset.truncateLess
      });
    });
  }
}

Blacklight.onLoad(function () {
  $('.context-navigator').each(function (i, e) {
    const contextNavigation = new ContextNavigation(e);
    contextNavigation.getData();
  });
});
