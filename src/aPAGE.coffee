A = (selector,options)->
	_is_active = false
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
		if not _is_active
			_body.addEventListener 'wheel', onScroll
			for i in [0..._triggers.length] by 1
				_triggers[i].addEventListener 'click', onClick
			_is_active = true
			if _current_target
				paintTriggers _current_target
			else
				scrollTo _elements[0]

	onScroll = (e)->
		if not _scrolling
			scroll_top = _body.scrollTop
			delta = e.deltaY
			if Math.abs(delta) > 42
				if delta > 0
					target_index = if _current_index is _elements.length-1 then _elements.length-1 else _current_index+1
				else
					target_index = if _current_index is 0 then 0 else _current_index-1
				scrollTo target_index

	onClick = (e)->
		trigger = e.currentTarget
		target_id = trigger.dataset[_settings.id.toLowerCase()+'Target']
		target = document.getElementById target_id
		scrollTo target

	paintTriggers = (target)->
		# Reset active triggers
		for i in [0..._triggers.length] by 1
			_triggers[i].className = _triggers[i].className.replace('active','').trim()
		# Get trigger and apply .active
		if target
			trigger = document.querySelectorAll '[data-'+_settings.id.toLowerCase()+'-target="'+target.id+'"]'
			if trigger[0] then trigger[0].className += ' active'

	scrollTo = (el)->
		_current_index = if typeof el is 'number' then el else _elements.indexOf el
		_current_target = if typeof el is 'number' then _elements[el] else el
		_scrolling = true
		rect = _current_target.getBoundingClientRect()
		offset_top = rect.top
		style = _scroller.currentStyle || window.getComputedStyle _scroller
		current_margin = Math.abs(parseInt(style.marginTop.replace('px','')))
		_scroller.style.marginTop = '-'+(Math.abs(current_margin)+offset_top)+'px'

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

	init(selector,options)

	return {
		halt: halt
		activate: activate
	}

window.aPAGE = (selector,options)->
	new A(selector,options)