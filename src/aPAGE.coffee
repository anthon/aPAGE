A =
	elements: []
	current_scroll_top: 0
	current_index: 0
	current_target: null
	scroller: null
	scrolling: false
	body: null
	settings:
		duration: 500
		fill: true

	init: (selector,options)->
		A.body = document.querySelector selector
		A.triggers = document.querySelectorAll '[data-apage-target]'
		for key,value of options
			this.settings[key] = value
		A.setup()
		A.activate()

	setup: ->
		A.body.style.overflow = 'hidden'
		A.body.style.transform = 'translateZ(0)'
		# Initialise elements
		elements = A.body.childNodes
		for i in [0...elements.length] by 1
			element = elements[i]
			if element.nodeType isnt 3
				elements[i].style.position = 'relative'
				if A.settings.fill
					element = elements[i]
				A.elements.push element
		# Append scroller
		A.scroller = document.createElement 'div'
		A.scroller.style.transition = 'margin-top '+(A.settings.duration/1000)+'s ease-in-out'
		A.body.insertBefore A.scroller, A.elements[0]

	activate: ->
		document.addEventListener 'wheel', this.onScroll
		for i in [0...A.triggers.length] by 1
			A.triggers[i].addEventListener 'click', this.onClick
		A.scrollTo A.elements[0]

	onScroll: (e)->
		if not A.scrolling
			scroll_top = A.body.scrollTop
			delta = e.deltaY
			if Math.abs(delta) > 42
				if delta > 0
					target_index = if A.current_index is A.elements.length-1 then A.elements.length-1 else A.current_index+1
					A.scrollTo A.elements[target_index]
				else
					target_index = if A.current_index is 0 then 0 else A.current_index-1
					A.scrollTo A.elements[target_index]
				A.current_index = target_index

	onClick: (e)->
		trigger = e.currentTarget
		target_id = trigger.dataset.apageTarget
		target = document.getElementById target_id
		A.scrollTo target

	paintTriggers: (trigger)->
		# Reset active triggers
		for i in [0...A.triggers.length] by 1
			A.triggers[i].className = A.triggers[i].className.replace('active','').trim()
		# Get trigger and apply .active
		trigger.className += ' active'

	scrollTo: (el)->
		A.scrolling = true
		A.current_target = el
		rect = A.current_target.getBoundingClientRect()
		offset_top = rect.top
		style = A.scroller.currentStyle || window.getComputedStyle A.scroller
		current_margin = Math.abs(parseInt(style.marginTop.replace('px','')))
		A.scroller.style.marginTop = '-'+(Math.abs(current_margin)+offset_top)+'px'

		trigger = document.querySelectorAll '[data-apage-target="'+A.current_target.id+'"]'
		if trigger[0] then A.paintTriggers trigger[0]

		setTimeout ->
			A.scrolling = false
		,A.settings.duration

window.aPAGE = (selector,options)->
	A.init(selector,options)