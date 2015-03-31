A = (selector,options)->
	_is_active = false
	_trigger_delta = 72
	_elements = []
	_triggers = []
	_current_scroll_top = 0
	_current_index = 0
	_current_target = null
	_scroller = null
	_scrolling = false
	_body = null
	_settings =
		id: 'aPAGE'
		duration: 500
		fill: true
		halted: false
		hashed: true

	init = (selector,options)->
		for key,value of options
			_settings[key] = value
		_body = document.querySelector selector
		_triggers = document.querySelectorAll '[data-'+_settings.id.toLowerCase()+'-target]'
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

	activate = ->
		# console.log 'Trying to activate "'+_settings.id+'"...'
		if not _is_active
			_body.addEventListener 'wheel', onScroll
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

	onScroll = (e)->
		if not _scrolling
			delta = e.deltaY
			overflow = _current_target.scrollHeight - _current_target.clientHeight
			scrollTop = _current_target.scrollTop
			if overflow is 0 or (scrollTop is overflow and delta > _trigger_delta) or (scrollTop is 0 and delta < -_trigger_delta) 
				scroll_top = _body.scrollTop
				delta = e.deltaY
				if Math.abs(delta) > _trigger_delta
					if delta > 0
						target_index = if _current_index is _elements.length-1 then _elements.length-1 else _current_index+1
					else
						target_index = if _current_index is 0 then 0 else _current_index-1
					fire target_index

	fetchHashAndFire = (e)->
		hash_array = window.location.hash.split(':')
		if hash_array[1]
			if hash_array[0].replace('#','') isnt _settings.id then return _current_target = _elements[0]
			target_id = hash_array[1]
		else
			target_id = hash_array[0]
		if e then e.preventDefault()
		target_node = document.getElementById target_id
		target_index = _elements.indexOf target_node
		fire target_index
		if e then return false

	onClick = (e)->
		trigger = e.currentTarget
		target_id = trigger.dataset[_settings.id.toLowerCase()+'Target']
		target = document.getElementById target_id
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
			trigger = document.querySelectorAll '[data-'+_settings.id.toLowerCase()+'-target="'+target.id+'"]'
			if trigger[0] then trigger[0].className += ' active'

	scroll = ->
		_scrolling = true
		rect = _current_target.getBoundingClientRect()
		offset_top = rect.top
		style = _scroller.currentStyle || window.getComputedStyle _scroller
		current_margin = Math.abs(parseInt(style.marginTop.replace('px','')))
		_scroller.style.marginTop = '-'+Math.abs(Math.abs(current_margin)+offset_top)+'px'

		paintTriggers _current_target

		setTimeout ->
			_scrolling = false
		,_settings.duration

	halt = ->
		if _is_active
			_body.removeEventListener 'wheel', onScroll
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