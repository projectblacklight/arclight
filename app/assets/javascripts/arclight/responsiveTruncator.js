/*
 * jQuery Responsive Truncator Plugin
 *
 * Forked from https://github.com/jkeck/responsiveTruncator
 *
 * VERSION 0.0.2
 *
* */
import jQuery from 'jquery'

(function ($) {
  $.fn.responsiveTruncate = function (options) {
    function addTruncation(el) {
      el.each(function () {
        if ($('.responsiveTruncate', $(this)).length === 0) {
          const parent = $(this);
          const fontSize = $(this).css('font-size');
          const lineHeight = $(this).css('line-height') ? $(this).css('line-height').replace('px', '') : Math.floor(parseInt(fontSize.replace('px', ''), 10) * 1.5);
          const settings = $.extend({
            lines: 3,
            height: null,
            more: 'more',
            less: 'less'
          }, options);
          let truncateHeight;
          if (settings.height) {
            truncateHeight = settings.height;
          } else {
            truncateHeight = (lineHeight * settings.lines);
          }
          if (parent.height() > truncateHeight) {
            const origContent = parent.html();
            parent.html("<div style='height: " + truncateHeight + "px; overflow: hidden;' class='responsiveTruncate'></div>");
            const truncate = $('.responsiveTruncate', parent);
            truncate.html(origContent);
            truncate.after("<a class='responsiveTruncatorToggle' href='#'>" + settings.more + '</a>');
            let toggleLink = $('.responsiveTruncatorToggle', parent);
            toggleLink.click(function () {
              var text = toggleLink.text() === settings.more ? settings.less : settings.more;
              toggleLink.text(text);
              if (parseInt(truncate.height(), 10) <= parseInt(truncateHeight, 10)) {
                truncate.css({ height: '100%' });
              } else {
                truncate.css({ height: truncateHeight });
              }
              return false;
            });
          }
        }
      });
    }

    function removeTruncation(el) {
      el.each(function () {
        if ($('.responsiveTruncate', $(this)).length > 0) {
          $(this).html($('.responsiveTruncate', $(this)).html());
          $('.responsiveTruncatorToggle', $(this)).remove();
        }
      });
    }

    const $this = this;
    $(window).bind('resize', function () {
      removeTruncation($this);
      addTruncation($this);
    });

    addTruncation($this);
  };
}(jQuery));
