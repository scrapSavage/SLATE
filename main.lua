local gui
local code_editor

local focused_file = 1

local open_files = {}

window({
	x=90,
	y=35,
	width=300,
	height=200
})

menuitem({
		id=0,
		label="\^:0f19392121213f00 Open file",
		action=function()
		end
})

function _init()
	store("/ram/cart/untitled.txt","",{})
	add(open_files,"/ram/cart/untitled.txt")
	gui = create_gui()
	code_editor = gui:attach_text_editor({
		x=0,y=12,
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
	window({
		title=(open_files[focused_file].." - SLATE")
	})
end
