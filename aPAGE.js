// Generated by CoffeeScript 1.8.0
(function() {
  var A;

  A = {
    elements: [],
    current_scroll_top: 0,
    current_index: 0,
    current_target: null,
    scroller: null,
    scrolling: false,
    body: null,
    settings: {
      duration: 500,
      fill: true
    },
    init: function(selector, options) {
      var key, value;
      A.body = document.querySelector(selector);
      A.triggers = document.querySelectorAll('[data-apage-target]');
      for (key in options) {
        value = options[key];
        this.settings[key] = value;
      }
      A.setup();
      return A.activate();
    },
    setup: function() {
      var element, elements, i, _i, _ref;
      A.body.style.overflow = 'hidden';
      A.body.style.transform = 'translateZ(0)';
      elements = A.body.childNodes;
      for (i = _i = 0, _ref = elements.length; _i < _ref; i = _i += 1) {
        element = elements[i];
        if (element.nodeType !== 3) {
          elements[i].style.position = 'relative';
          if (A.settings.fill) {
            element = elements[i];
          }
          A.elements.push(element);
        }
      }
      A.scroller = document.createElement('div');
      A.scroller.style.transition = 'margin-top ' + (A.settings.duration / 1000) + 's ease-in-out';
      return A.body.insertBefore(A.scroller, A.elements[0]);
    },
    activate: function() {
      var i, _i, _ref;
      document.addEventListener('wheel', this.onScroll);
      for (i = _i = 0, _ref = A.triggers.length; _i < _ref; i = _i += 1) {
        A.triggers[i].addEventListener('click', this.onClick);
      }
      return A.scrollTo(A.elements[0]);
    },
    onScroll: function(e) {
      var delta, scroll_top, target_index;
      if (!A.scrolling) {
        scroll_top = A.body.scrollTop;
        delta = e.deltaY;
        if (Math.abs(delta) > 42) {
          if (delta > 0) {
            target_index = A.current_index === A.elements.length - 1 ? A.elements.length - 1 : A.current_index + 1;
            A.scrollTo(A.elements[target_index]);
          } else {
            target_index = A.current_index === 0 ? 0 : A.current_index - 1;
            A.scrollTo(A.elements[target_index]);
          }
          return A.current_index = target_index;
        }
      }
    },
    onClick: function(e) {
      var target, target_id, trigger;
      trigger = e.currentTarget;
      target_id = trigger.dataset.apageTarget;
      target = document.getElementById(target_id);
      return A.scrollTo(target);
    },
    paintTriggers: function(trigger) {
      var i, _i, _ref;
      for (i = _i = 0, _ref = A.triggers.length; _i < _ref; i = _i += 1) {
        A.triggers[i].className = A.triggers[i].className.replace('active', '').trim();
      }
      return trigger.className += ' active';
    },
    scrollTo: function(el) {
      var current_margin, offset_top, rect, style, trigger;
      A.scrolling = true;
      A.current_target = el;
      rect = A.current_target.getBoundingClientRect();
      offset_top = rect.top;
      style = A.scroller.currentStyle || window.getComputedStyle(A.scroller);
      current_margin = Math.abs(parseInt(style.marginTop.replace('px', '')));
      A.scroller.style.marginTop = '-' + (Math.abs(current_margin) + offset_top) + 'px';
      trigger = document.querySelectorAll('[data-apage-target="' + A.current_target.id + '"]');
      if (trigger[0]) {
        A.paintTriggers(trigger[0]);
      }
      return setTimeout(function() {
        return A.scrolling = false;
      }, A.settings.duration);
    }
  };

  window.aPAGE = function(selector, options) {
    return A.init(selector, options);
  };

}).call(this);
