A = (selector,options)->
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

	init = (selector,options)->
		for key,value of options
			_settings[key] = value
		_body = document.querySelector selector
		_triggers = document.querySelectorAll '[data-'+_settings.id.toLowerCase()+'-target]'
		setup()
		activate()

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
		_body.addEventListener 'wheel', onScroll
		for i in [0..._triggers.length] by 1
			_triggers[i].addEventListener 'click', onClick
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

	paintTriggers = (trigger)->
		# Reset active triggers
		for i in [0..._triggers.length] by 1
			_triggers[i].className = _triggers[i].className.replace('active','').trim()
		# Get trigger and apply .active
		if trigger then trigger.className += ' active'

	scrollTo = (el)->
		_current_index = if typeof el is 'number' then el else _elements.indexOf el
		_current_target = if typeof el is 'number' then _elements[el] else el
		_scrolling = true
		rect = _current_target.getBoundingClientRect()
		offset_top = rect.top
		style = _scroller.currentStyle || window.getComputedStyle _scroller
		current_margin = Math.abs(parseInt(style.marginTop.replace('px','')))
		_scroller.style.marginTop = '-'+(Math.abs(current_margin)+offset_top)+'px'

		trigger = document.querySelectorAll '[data-'+_settings.id.toLowerCase()+'-target="'+_current_target.id+'"]'
		if trigger[0] then paintTriggers trigger[0]

		setTimeout ->
			_scrolling = false
		,_settings.duration

	halt = ->
		_body.removeEventListener 'wheel', onScroll
		for i in [0..._triggers.length] by 1
			_triggers[i].removeEventListener 'click', onClick
		paintTriggers null

	init(selector,options)

window.aPAGE = (selector,options)->
	new A(selector,options)