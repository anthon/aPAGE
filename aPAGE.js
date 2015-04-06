// Generated by CoffeeScript 1.8.0
(function() {
  var A;

  A = function(selector, options) {
    var activate, fetchHashAndFire, fire, halt, init, onClick, onResize, onScroll, onTouchEnd, onTouchMove, onTouchStart, paintTriggers, scroll, setHash, setup, _blocker, _body, _current_index, _current_scroll_top, _current_target, _elements, _is_active, _scroller, _scrolling, _settings, _sliding, _touch_y, _triggers;
    _is_active = false;
    _touch_y = 0;
    _elements = [];
    _triggers = [];
    _current_scroll_top = 0;
    _current_index = 0;
    _current_target = null;
    _scroller = null;
    _sliding = false;
    _scrolling = false;
    _blocker = null;
    _body = null;
    _settings = {
      id: 'aPAGE',
      duration: 500,
      fill: true,
      halted: false,
      hashed: true,
      trigger_delta: 72
    };
    init = function(selector, options) {
      var key, value;
      for (key in options) {
        value = options[key];
        _settings[key] = value;
      }
      _body = document.querySelector(selector);
      _triggers = document.querySelectorAll('[data-apage="' + _settings.id + '"]');
      setup();
      if (!_settings.halted) {
        return activate();
      }
    };
    setup = function() {
      var element, elements, i, _i, _ref;
      document.body.style.overflow = 'hidden';
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
      _body.insertBefore(_scroller, _elements[0]);
      return window.addEventListener('resize', onResize);
    };
    activate = function() {
      var i, _i, _ref;
      if (!_is_active) {
        _body.addEventListener('wheel', onScroll);
        _body.addEventListener('touchmove', onTouchMove);
        _body.addEventListener('touchstart', onTouchStart);
        _body.addEventListener('touchend', onTouchEnd);
        if (_settings.hashed) {
          window.addEventListener('hashchange', fetchHashAndFire);
        }
        for (i = _i = 0, _ref = _triggers.length; _i < _ref; i = _i += 1) {
          _triggers[i].addEventListener('click', onClick);
        }
        if (_current_target) {
          paintTriggers(_current_target);
        } else {
          if (_settings.hashed) {
            fetchHashAndFire();
          } else {
            fire(_elements[0]);
          }
        }
        return _is_active = true;
      }
    };
    onResize = function() {
      return scroll();
    };
    onScroll = function(e) {
      var delta, has_overflow, has_reached_overflow, overflow, scrollTop, scrolling_down, target_index;
      if (!_sliding) {
        delta = e.deltaY;
        overflow = Math.round(_current_target.scrollHeight - _current_target.offsetHeight);
        scrollTop = Math.round(_current_target.scrollTop);
        scrolling_down = delta > 0;
        has_overflow = overflow !== 0;
        if (has_overflow) {
          has_reached_overflow = (scrollTop === overflow && scrolling_down) || (scrollTop === 0 && !scrolling_down);
          if (!has_reached_overflow) {
            _scrolling = true;
            clearTimeout(_blocker);
            _blocker = setTimeout(function() {
              return _scrolling = false;
            }, 400);
            return false;
          }
        }
        if (!_scrolling && (!has_overflow || has_reached_overflow)) {
          delta = e.deltaY;
          if (Math.abs(delta) > _settings.trigger_delta) {
            if (delta > 0) {
              target_index = _current_index === _elements.length - 1 ? _elements.length - 1 : _current_index + 1;
            } else {
              target_index = _current_index === 0 ? 0 : _current_index - 1;
            }
            return fire(target_index);
          }
        }
      }
    };
    onTouchMove = function(e) {
      var delta, has_overflow, has_reached_overflow, overflow, scrollTop, scrolling_down;
      e.stopPropagation();
      delta = e.changedTouches[0].pageY - _touch_y;
      overflow = Math.round(_current_target.scrollHeight - _current_target.offsetHeight);
      scrollTop = Math.round(_current_target.scrollTop);
      scrolling_down = delta < 0;
      has_overflow = overflow !== 0;
      if (has_overflow) {
        has_reached_overflow = (scrollTop === overflow && scrolling_down) || (scrollTop === 0 && !scrolling_down);
        if (has_reached_overflow) {
          return e.preventDefault();
        } else {
          _scrolling = true;
          clearTimeout(_blocker);
          return _blocker = setTimeout(function() {
            return _scrolling = false;
          }, 400);
        }
      } else {
        return e.preventDefault();
      }
    };
    onTouchStart = function(e) {
      return _touch_y = e.changedTouches[0].pageY;
    };
    onTouchEnd = function(e) {
      var delta, target_index;
      if (!_scrolling) {
        delta = e.changedTouches[0].pageY - _touch_y;
        if (Math.abs(delta) > _settings.trigger_delta) {
          if (delta < 0) {
            target_index = _current_index === _elements.length - 1 ? _elements.length - 1 : _current_index + 1;
          } else {
            target_index = _current_index === 0 ? 0 : _current_index - 1;
          }
          return fire(target_index);
        }
      }
    };
    fetchHashAndFire = function(e) {
      var hash_array, target_id, target_index, target_node;
      hash_array = window.location.hash.split(':');
      if (hash_array[0] !== '') {
        if (hash_array[1]) {
          if (hash_array[0].replace('#', '') !== _settings.id) {
            return _current_target = _elements[0];
          }
          target_id = hash_array[1];
        } else {
          target_id = hash_array[0];
        }
        target_node = document.getElementById(target_id);
        target_index = _elements.indexOf(target_node);
        if (target_index === -1) {
          return _current_target = _elements[0];
        }
      } else {
        target_index = 0;
      }
      if (e) {
        e.preventDefault();
      }
      fire(target_index);
      if (e) {
        return false;
      }
    };
    onClick = function(e) {
      var target, target_id, trigger;
      trigger = e.currentTarget;
      target_id = trigger.dataset['apageTarget'];
      target = document.getElementById(target_id);
      if (target !== -1) {
        return fire(target);
      }
    };
    fire = function(el) {
      _current_index = isNaN(el) ? _elements.indexOf(el) : parseInt(el);
      _current_target = _elements[_current_index];
      if (!_current_target) {
        _current_target = _elements[0];
      }
      if (_settings.hashed) {
        setHash();
      }
      return scroll();
    };
    setHash = function() {
      var hash;
      hash = _current_target.id ? _current_target.id : _current_index;
      if (_settings.id) {
        hash = _settings.id + ':' + hash;
      }
      return window.location.hash = hash;
    };
    paintTriggers = function(target) {
      var i, trigger, _i, _ref;
      for (i = _i = 0, _ref = _triggers.length; _i < _ref; i = _i += 1) {
        _triggers[i].className = _triggers[i].className.replace('active', '').trim();
      }
      if (target) {
        trigger = document.querySelectorAll('[data-apage="' + _settings.id + '"][data-apage-target="' + target.id + '"]');
        if (trigger[0]) {
          return trigger[0].className += ' active';
        }
      }
    };
    scroll = function() {
      var current_margin, offset_top, rect, style;
      _sliding = true;
      rect = _current_target.getBoundingClientRect();
      offset_top = rect.top;
      style = _scroller.currentStyle || window.getComputedStyle(_scroller);
      current_margin = Math.abs(parseInt(style.marginTop.replace('px', '')));
      _scroller.style.marginTop = '-' + Math.abs(Math.abs(current_margin) + offset_top) + 'px';
      _current_target.scrollTop = 0;
      paintTriggers(_current_target);
      return setTimeout(function() {
        return _sliding = false;
      }, _settings.duration);
    };
    halt = function() {
      var i, _i, _ref;
      if (_is_active) {
        _body.removeEventListener('wheel', onScroll);
        document.body.removeEventListener('touchmove', onTouchMove);
        _body.removeEventListener('touchstart', onTouchStart);
        _body.removeEventListener('touchend', onTouchEnd);
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
