A = (selector,options)->
	_is_active = false
	_touch_y = 0
	_elements = []
	_triggers = []
	_current_scroll_top = 0
	_current_index = 0
	_current_target = null
	_scroller = null
	_sliding = false
	_scrolling = false
	_blocker = null
	_body = null
	_settings =
		id: 'aPAGE'
		duration: 500
		fill: true
		halted: false
		hashed: true
		trigger_delta: 72

	init = (selector,options)->
		for key,value of options
			_settings[key] = value
		_body = document.querySelector selector
		_triggers = document.querySelectorAll '[data-apage="'+_settings.id+'"]'
		setup()
		if not _settings.halted then activate()

	setup = ->
		_body.style.overflow = 'hidden'
		_body.style.transform = 'translateZ(0)'
		# Initialise elements
		elements = _body.childNodes
		for i in [0...elements.length] by 1
			element = elements[i]
			if element.nodeType isnt 3
				elements[i].style.position = 'relative'
				if _settings.fill
					element = elements[i]
				_elements.push element
		# Append scroller
		_scroller = document.createElement 'div'
		_scroller.style.transition = 'margin-top '+(_settings.duration/1000)+'s ease-in-out'
		_body.insertBefore _scroller, _elements[0]
		# Activate resizer
		window.addEventListener 'resize', onResize

	activate = ->
		# console.log 'Trying to activate "'+_settings.id+'"...'
		if not _is_active
			_body.addEventListener 'wheel', onScroll
			# Deactivating overscroll
			document.body.addEventListener 'touchmove', onBodyTouchMove
			_body.addEventListener 'touchstart', onTouchStart
			_body.addEventListener 'touchend', onTouchEnd
			if _settings.hashed then window.addEventListener 'hashchange', fetchHashAndFire
			for i in [0..._triggers.length] by 1
				_triggers[i].addEventListener 'click', onClick
			if _current_target
				paintTriggers _current_target
			else
				if _settings.hashed
					fetchHashAndFire()
				else
					fire _elements[0]
			_is_active = true
			# console.log '"'+_settings.id+'" activated.'

	onResize = ->
		scroll()

	onScroll = (e)->
		if not _sliding
			delta = e.deltaY
			overflow = Math.round(_current_target.scrollHeight - _current_target.offsetHeight)
			scrollTop = Math.round(_current_target.scrollTop)
			scrolling_down = delta > 0
			has_overflow = overflow isnt 0
			if has_overflow
				has_reached_overflow = (scrollTop is overflow and scrolling_down) or (scrollTop is 0 and not scrolling_down)
				if not has_reached_overflow
					_scrolling = true
					clearTimeout _blocker
					_blocker = setTimeout ->
						_scrolling = false
					,400
					return false
			if not _scrolling and (not has_overflow or has_reached_overflow)
				delta = e.deltaY
				if Math.abs(delta) > _settings.trigger_delta
					if delta > 0
						target_index = if _current_index is _elements.length-1 then _elements.length-1 else _current_index+1
					else
						target_index = if _current_index is 0 then 0 else _current_index-1
					fire target_index

	onBodyTouchMove = (e)->
		if not _scrolling and not _current_target.contains e.target
			e.stopPropagation()
			return false
		delta = e.changedTouches[0].pageY - _touch_y
		overflow = Math.round(_current_target.scrollHeight - _current_target.offsetHeight)
		scrollTop = Math.round(_current_target.scrollTop)
		scrolling_down = delta < 0
		has_overflow = overflow isnt 0
		if has_overflow
			has_reached_overflow = (scrollTop is overflow and scrolling_down) or (scrollTop is 0 and not scrolling_down)
			if not has_reached_overflow
				_scrolling = true
				clearTimeout _blocker
				_blocker = setTimeout ->
					_scrolling = false
				,1000

	onTouchStart = (e)->
		_touch_y = e.changedTouches[0].pageY

	onTouchEnd = (e)->
		if not _scrolling
			delta = e.changedTouches[0].pageY - _touch_y
			if Math.abs(delta) > _settings.trigger_delta
				if delta < 0
					target_index = if _current_index is _elements.length-1 then _elements.length-1 else _current_index+1
				else
					target_index = if _current_index is 0 then 0 else _current_index-1
				fire target_index

	fetchHashAndFire = (e)->
		hash_array = window.location.hash.split(':')
		if hash_array[0] isnt ''
			if hash_array[1]
				if hash_array[0].replace('#','') isnt _settings.id then return _current_target = _elements[0]
				target_id = hash_array[1]
			else
				target_id = hash_array[0]
			target_node = document.getElementById target_id
			target_index = _elements.indexOf target_node
			if target_index is -1 then return _current_target = _elements[0]
		else
			target_index = 0
		if e then e.preventDefault()
		fire target_index
		if e then return false

	onClick = (e)->
		trigger = e.currentTarget
		target_id = trigger.dataset['apageTarget']
		target = document.getElementById target_id
		if target isnt -1
			fire target

	fire = (el)->
		_current_index = if isNaN(el) then _elements.indexOf el else parseInt(el)
		_current_target = _elements[_current_index]
		if not _current_target then _current_target = _elements[0]
		if _settings.hashed then setHash()
		scroll()

	setHash = ->
		hash = if _current_target.id then _current_target.id else _current_index
		if _settings.id then hash = _settings.id+':'+hash
		window.location.hash = hash

	paintTriggers = (target)->
		# Reset active triggers
		for i in [0..._triggers.length] by 1
			_triggers[i].className = _triggers[i].className.replace('active','').trim()
		# Get trigger and apply .active
		if target
			trigger = document.querySelectorAll '[data-apage="'+_settings.id+'"][data-apage-target="'+target.id+'"]'
			if trigger[0] then trigger[0].className += ' active'

	scroll = ->
		_sliding = true
		rect = _current_target.getBoundingClientRect()
		offset_top = rect.top
		style = _scroller.currentStyle || window.getComputedStyle _scroller
		current_margin = Math.abs(parseInt(style.marginTop.replace('px','')))
		_scroller.style.marginTop = '-'+Math.abs(Math.abs(current_margin)+offset_top)+'px'

		_current_target.scrollTop = 0
		paintTriggers _current_target

		setTimeout ->
			_sliding = false
		,_settings.duration

	halt = ->
		if _is_active
			_body.removeEventListener 'wheel', onScroll
			document.body.removeEventListener 'touchmove', onBodyTouchMove
			_body.removeEventListener 'touchstart', onTouchStart
			_body.removeEventListener 'touchend', onTouchEnd
			for i in [0..._triggers.length] by 1
				_triggers[i].removeEventListener 'click', onClick
			paintTriggers null
			_is_active = false
			# console.log '"'+_settings.id+'" halted.'

	init(selector,options)

	return {
		halt: halt
		activate: activate
	}

window.aPAGE = (selector,options)->
	new A(selector,options)