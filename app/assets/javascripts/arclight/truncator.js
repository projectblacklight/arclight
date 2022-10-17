function setupTruncation(container) {
  // target elements
  const contentOuter = container.querySelector('.content');
  const contentInner = Array.from(contentOuter.children);
  const button = container.querySelector('button');

  // calculate total scrollable inner height vs. observed outer height
  const outerHeight = contentOuter.clientHeight;
  const innerHeight = contentInner.map(e => e.scrollHeight).reduce((a, b) => a + b, 0);

  // truncation occurred if total inner height exceeds outer (observed) height.
  // if no longer truncated, reset the expanded state (e.g. on window resize).
  if (innerHeight > outerHeight) {
    container.classList.add('truncated');
  } else {
    container.classList.remove('truncated');
    contentOuter.classList.remove('expanded');
  }

  // add event binding to expand/collapse button
  button.addEventListener('click', () => container.classList.toggle('expanded'));
}

Blacklight.onLoad(() => {
  // activate on initial page load
  document.querySelectorAll('[data-arclight-truncate=true]').forEach(setupTruncation);

  // activate when the page is resized
  window.addEventListener('resize', () => {
    document.querySelectorAll('[data-arclight-truncate=true]').forEach(setupTruncation);
  });

  // activate when elements get loaded into context navigator
  const navigator = document.querySelector('.al-contents, .context-navigator');
  if (navigator) {
    navigator.addEventListener('navigation.contains.elements', event => {
      document.querySelectorAll('[data-toggle="tab"]').forEach(tab => {
        tab.addEventListener('shown.bs.tab', () => {
          document.querySelectorAll('[data-arclight-truncate=true]').forEach(setupTruncation);
        });
      });
      event.target.querySelectorAll('[data-arclight-truncate=true]').forEach(setupTruncation);
    });
  }
});
