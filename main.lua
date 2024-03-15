local gui
local code_editor

window({
	x=90,
	y=35,
	width=300,
	height=200
})

menuitem({
		id=0,
		label="\^:0038383800387C00 Preferences",
		action=function()
		end
})

function _init()
	gui = create_gui()
	code_editor = gui:attach_text_editor({
		x=0,y=0,
		width=150,
		height=200,
		width_rel=1,
		height_rel=1,
		syntax_highlighting=true,
		show_line_numbers=true,
		markup=false,
		embed_pods=true,
		has_search=true
	})
	code_editor:attach_scrollbars({autohide=true})
end

function _draw()
	gui:update_all()
	gui:draw_all()
end
