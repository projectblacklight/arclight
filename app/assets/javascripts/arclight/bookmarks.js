import CheckboxSubmit from 'blacklight/checkbox_submit'

Blacklight.onLoad(function () {
  document.documentElement.addEventListener('turbo:frame-load', () => {
    console.log('turbo:load')
    document.querySelectorAll('form.bookmark-toggle').forEach((element) => {
      if (element.querySelectorAll('.checkbox').length > 0) return;
      new CheckboxSubmit(element).render()
    })
  });
});
