// Generated by CoffeeScript 1.8.0
(function() {
  var A;

  A = function(selector, options) {
    var activate, halt, init, onClick, onScroll, paintTriggers, scrollTo, setup, _body, _current_index, _current_scroll_top, _current_target, _elements, _is_active, _scroller, _scrolling, _settings, _triggers;
    _is_active = false;
    _elements = [];
    _triggers = [];
    _current_scroll_top = 0;
    _current_index = 0;
    _current_target = null;
    _scroller = null;
    _scrolling = false;
    _body = null;
    _settings = {
      id: 'aPAGE',
      duration: 500,
      fill: true,
      halted: false
    };
    init = function(selector, options) {
      var key, value;
      for (key in options) {
        value = options[key];
        _settings[key] = value;
      }
      _body = document.querySelector(selector);
      _triggers = document.querySelectorAll('[data-' + _settings.id.toLowerCase() + '-target]');
      setup();
      if (!_settings.halted) {
        return activate();
      }
    };
    setup = function() {
      var element, elements, i, _i, _ref;
      _body.style.overflow = 'hidden';
      _body.style.transform = 'translateZ(0)';
      elements = _body.childNodes;
      for (i = _i = 0, _ref = elements.length; _i < _ref; i = _i += 1) {
        element = elements[i];
        if (element.nodeType !== 3) {
          elements[i].style.position = 'relative';
          if (_settings.fill) {
            element = elements[i];
          }
          _elements.push(element);
        }
      }
      _scroller = document.createElement('div');
      _scroller.style.transition = 'margin-top ' + (_settings.duration / 1000) + 's ease-in-out';
      return _body.insertBefore(_scroller, _elements[0]);
    };
    activate = function() {
      var i, _i, _ref;
      if (!_is_active) {
        _body.addEventListener('wheel', onScroll);
        for (i = _i = 0, _ref = _triggers.length; _i < _ref; i = _i += 1) {
          _triggers[i].addEventListener('click', onClick);
        }
        _is_active = true;
        return scrollTo(_elements[0]);
      }
    };
    onScroll = function(e) {
      var delta, scroll_top, target_index;
      if (!_scrolling) {
        scroll_top = _body.scrollTop;
        delta = e.deltaY;
        if (Math.abs(delta) > 42) {
          if (delta > 0) {
            target_index = _current_index === _elements.length - 1 ? _elements.length - 1 : _current_index + 1;
          } else {
            target_index = _current_index === 0 ? 0 : _current_index - 1;
          }
          return scrollTo(target_index);
        }
      }
    };
    onClick = function(e) {
      var target, target_id, trigger;
      trigger = e.currentTarget;
      target_id = trigger.dataset[_settings.id.toLowerCase() + 'Target'];
      target = document.getElementById(target_id);
      return scrollTo(target);
    };
    paintTriggers = function(trigger) {
      var i, _i, _ref;
      for (i = _i = 0, _ref = _triggers.length; _i < _ref; i = _i += 1) {
        _triggers[i].className = _triggers[i].className.replace('active', '').trim();
      }
      if (trigger) {
        return trigger.className += ' active';
      }
    };
    scrollTo = function(el) {
      var current_margin, offset_top, rect, style, trigger;
      _current_index = typeof el === 'number' ? el : _elements.indexOf(el);
      _current_target = typeof el === 'number' ? _elements[el] : el;
      _scrolling = true;
      rect = _current_target.getBoundingClientRect();
      offset_top = rect.top;
      style = _scroller.currentStyle || window.getComputedStyle(_scroller);
      current_margin = Math.abs(parseInt(style.marginTop.replace('px', '')));
      _scroller.style.marginTop = '-' + (Math.abs(current_margin) + offset_top) + 'px';
      trigger = document.querySelectorAll('[data-' + _settings.id.toLowerCase() + '-target="' + _current_target.id + '"]');
      if (trigger[0]) {
        paintTriggers(trigger[0]);
      }
      return setTimeout(function() {
        return _scrolling = false;
      }, _settings.duration);
    };
    halt = function() {
      var i, _i, _ref;
      if (_is_active) {
        _body.removeEventListener('wheel', onScroll);
        for (i = _i = 0, _ref = _triggers.length; _i < _ref; i = _i += 1) {
          _triggers[i].removeEventListener('click', onClick);
        }
        paintTriggers(null);
        return _is_active = false;
      }
    };
    init(selector, options);
    return {
      halt: halt,
      activate: activate
    };
  };

  window.aPAGE = function(selector, options) {
    return new A(selector, options);
  };

}).call(this);
