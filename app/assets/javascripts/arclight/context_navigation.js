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

/**
 * Models the "Expand"/"Collapse" button, and provides an onClick event handler
 * for the jQuery element
 * @class
 */
class ExpandButton {
  /**
   * This adds a "collapsed" class to all of the <li> children, as well as
   * updates the text for the <button> element
   * @param {Event} event - the event propagated in response to clicking on the
   *   <button>
   */
  static handleClick(event) {
    const $element = $(event.target);
    $element.parent().children('li').toggleClass('collapsed');
    $element.toggleClass('collapsed');

    const containerText = $element.hasClass('collapsed') ? this.collapseText : this.expandText;
    $element.text(containerText);
  }

  /**
   * @constructor
   */
  constructor() {
    const parentUl = $('ul.parent');
    this.collapseText = parentUl[0].dataset.dataCollapse;
    this.expandText = parentUl[0].dataset.dataExpand;

    this.$el = $(`<button class="my-3 btn btn-secondary btn-sm">${this.expandText}</button>`);
    ExpandButton.handleClick = ExpandButton.handleClick.bind(this);
    this.$el.click(ExpandButton.handleClick);
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

  /**
   * Constructs a <ul> container element with an ElementButton instance appended
   * within it
   * @returns {jQuery}
   */
  buildExpandContainer() {
    const $container = $('<ul class="pl-0 prev-siblings"></ul>');
    const button = new ExpandButton();
    $container.append(button.$el);
    return $container;
  }

  /**
   * Highlights the <li> element for the current Document and appends <li> the sibling documents for a given Document element
   * @param {NavigationDocument[]} newDocs - the NavigationDocument objects for
   *   each resulting Solr Document
   * @param {number} originalDocumentIndex
   * @param {jQuery} parentLi
   */
  updateSiblings(newDocs, originalDocumentIndex, parentLi) {
    newDocs[originalDocumentIndex].setAsHighlighted();

    // Hide all but the first previous sibling
    const prevSiblingDocs = newDocs.slice(0, originalDocumentIndex - 1);
    let nextSiblingDocs = [];

    if (prevSiblingDocs.length > 1 && originalDocumentIndex > 0) {
      const hiddenPrevSiblingDocs = prevSiblingDocs.slice(0, -1);
      hiddenPrevSiblingDocs.forEach(siblingDoc => {
        siblingDoc.collapse();
      });

      const prevSiblingContainer = this.buildExpandContainer();
      const renderedPrevSiblingItems = prevSiblingDocs.map(doc => doc.render()).join('');

      prevSiblingContainer.append(renderedPrevSiblingItems);
      parentLi.before(prevSiblingContainer);

      nextSiblingDocs = newDocs.slice(originalDocumentIndex);
    } else {
      nextSiblingDocs = newDocs;
    }

    const renderedNextSiblingItems = nextSiblingDocs.map(newDoc => newDoc.render()).join('');

    // Insert the rendered sibling documents before the <li> elements
    parentLi.before(renderedNextSiblingItems).fadeIn(500);
  }

  /**
   * Inserts <li> elements for parents (e. g. components or collections) for the
   *   current Document and appends <li> for each of these
   * @param {NavigationDocument[]} newDocs - the NavigationDocument objects for
   *   each resulting Solr Document
   * @param {string[]} originalParents - the IDs for the Solr Documents of each
   *   ancestor
   * @param {string} parent - the ID for the immediate parent (ancestor)
   * @param {jQuery} parentLi - the <li> used to generate the <ul> for the
   * context - this is consistently the *last* element in the <ul>
   */
  updateParents(newDocs, originalParents, parent, parentLi) {
    // Case where this is a parent list and needs to be filed correctly
    //
    // Otherwise, retrieve the parent...
    const parentIndex = originalParents.indexOf(parent);

    // The first parent is always used to consistently construct the doc ID
    const firstParent = originalParents[0];
    const nextParent = originalParents[parentIndex + 1];
    const currentId = `${firstParent}${nextParent}`;

    const newDocIndex = newDocs.findIndex(doc => doc.id === currentId);

    // Update the docs before the item
    // Retrieves the documents up to and including the "new document"
    const beforeDocs = newDocs.slice(0, newDocIndex);
    let renderedBeforeDocs;
    if (beforeDocs.length > 1) {
      beforeDocs.forEach(function (parentDoc) {
        parentDoc.collapse();
      });
      renderedBeforeDocs = beforeDocs.map(newDoc => newDoc.render()).join('');
      const prevParentContainer = this.buildExpandContainer();
      prevParentContainer.append(renderedBeforeDocs);
    } else {
      renderedBeforeDocs = beforeDocs.map(newDoc => newDoc.render()).join('');
    }

    parentLi.before(renderedBeforeDocs).fadeIn(500);

    let itemDoc = newDocs.slice(newDocIndex, newDocIndex + 1);
    let renderedItemDoc = itemDoc.map(doc => doc.render()).join('');

    // Update the item
    const $itemDoc = $(renderedItemDoc);
    // Update the id, add classes of the classes. Prepend the current children.
    parentLi.attr('id', $itemDoc.attr('id'));
    parentLi.addClass($itemDoc.attr('class'));

    parentLi.prepend($itemDoc.children()).fadeIn(500);

    // Update the docs after the item
    const afterDocs = newDocs.slice(newDocIndex + 1, newDocs.length);
    const renderedAfterDocs = afterDocs.map(newDoc => newDoc.render()).join('');

    // Insert the documents after the current
    parentLi.after(renderedAfterDocs).fadeIn(500);
  }

  /**
   * Update the ancestors for <li> elements
   * @param {jQuery} $li - the <li> element for the current, highlighted
   *   Document in the <ul> context list of collections, components, and
   *   containers
   */
  updateListSiblings($li) {
    const prevSiblings = $li.prevAll('.al-collection-context');
    /**
     * @todo This should be deduplicated and refactored - perhaps a Class
     *   derived from ExpandButton?
     */
    if (prevSiblings.length > 1) {
      const hiddenNextSiblings = prevSiblings.slice(0, -1);
      hiddenNextSiblings.toggleClass('collapsed');

      // This all needs to be refactored
      const $button = $('<button class="my-3 btn btn-secondary btn-sm">Expand</button>');
      $button.handleClick = event => {
        const highlighted = $(this.parentLi).siblings('.al-hierarchy-highlight');
        let targeted = highlighted.prevAll('.al-collection-context');
        targeted = targeted.slice(0, -1);
        targeted.toggleClass('collapsed');
        const collapsed = targeted.hasClass('collapsed');
        const updatedText = collapsed ? 'Expand' : 'Collapse';
        const $target = $(event.target);
        $target.text(updatedText);
      };
      $button.handleClick = $button.handleClick.bind($button);
      $button.click($button.handleClick);

      const lastHiddenNextSibling = hiddenNextSiblings[hiddenNextSiblings.length - 1];
      $button.insertAfter(lastHiddenNextSibling);
    }

    const nextSiblings = $li.nextAll('.al-collection-context');
    if (nextSiblings.length > 1) {
      const hiddenNextSiblings = nextSiblings.slice(1);
      hiddenNextSiblings.toggleClass('collapsed');

      // This all needs to be refactored
      const $button = $('<button class="my-3 btn btn-secondary btn-sm">Expand</button>');
      $button.handleClick = event => {
        const highlighted = $(this.parentLi).siblings('.al-hierarchy-highlight');
        let targeted = highlighted.nextAll('.al-collection-context');
        targeted = targeted.slice(1);
        targeted.toggleClass('collapsed');
        const collapsed = targeted.hasClass('collapsed');
        const updatedText = collapsed ? 'Expand' : 'Collapse';
        const $target = $(event.target);
        $target.text(updatedText);
      };
      $button.handleClick = $button.handleClick.bind($button);
      $button.click($button.handleClick);

      const lastHiddenNextSibling = hiddenNextSiblings[0];
      $button.insertBefore(lastHiddenNextSibling);
    }
  }

  /**
   * This updates the elements in the View DOM using an AJAX response containing
   *   the HTML of a server-rendered View template.
   * It is this which is primarily used to populate the <ul> element with
   *   children for the navigation context, containing <li> elements for
   *   collections, components, and containers.
   * @param {string} response - the AJAX response body
   */
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
      this.updateSiblings(newDocs, originalDocumentIndex, that.parentLi);
    } else {
      this.updateParents(
        newDocs,
        that.data.arclight.originalParents,
        that.data.arclight.parent,
        that.parentLi
      );
    }
    that.truncateItems();
    Blacklight.doBookmarkToggleBehavior();

    // Select the <li> element for the current document
    const highlighted = that.parentLi.siblings('.al-hierarchy-highlight');
    this.updateListSiblings(highlighted);
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
