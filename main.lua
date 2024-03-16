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

button_gfx = {
	save=userdata"[gfx]08080707700007077070070000700777777007077770070777700777777000000000[/gfx]",
	run=userdata"[gfx]08080700000007770000077777000777777007777700077700000700000000000000[/gfx]",
	term=userdata"[gfx]08080777777007000070070000700700007007777770000770000777777000000000[/gfx]"
}

menuitem({
		id=0,
		label="\^:0f19392121213f00 Open file",
		shortcut = "CTRL-O",
		action=function()
			local segs = split(open_files[focused_file],"/",false)
			local path = string.sub(open_files[focused_file], 1, -#segs[#segs] - 2) -- same folder as current file
			create_process("/system/apps/filenav.p64", {path = path, window_attribs= {workspace = "current", autoclose=true}})
		end
})

function _init()
	store("/ram/cart/untitled.txt","",{})
	add(open_files,{path="/ram/cart/untitled.txt",name="untitled.txt",state=fetch("/ram/cart/untitled.txt")})
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
		embed_pods=false,
		has_search=true
	})
	code_editor:attach_scrollbars({autohide=true})
	
	-- quick buttons
	
	--save
	gui:attach{
			cursor = "pointer",
			x = 0,
			y = 0,
			width=10,
			height=10,
			tap = function(self)
				open_files[focused_file].state = table.concat(code_editor:get_text(),"\n")
				store(open_files[focused_file].path,open_files[focused_file].state,{})
				notify("Saved "..open_files[focused_file].path)
			end
	}
	--run
	gui:attach{
			cursor = "pointer",
			x = 10,
			y = 0,
			width=10,
			height=10,
			tap = function(self)
				create_process(open_files[focused_file].path)
			end
	}
	--term
	gui:attach{
			cursor = "pointer",
			x = 20,
			y = 0,
			width=10,
			height=10,
			tap = function(self)
				notify("This button doesn't do anything yet.")
			end
	}

end

function _draw()
	gui:update_all()
	gui:draw_all()
	window({
		title=(open_files[focused_file].path.." - SLATE")
	})
	rectfill(0,0,1000,10,12)
	line(0,11,1000,11,16)
	spr(button_gfx.save,1,2)
	spr(button_gfx.run,10,2)
	spr(button_gfx.term,19,2)
end

function set_active_tab(idx)
	open_files[focused_file].state = table.concat(code_editor:get_text(),"\n")
	focused_file = idx
	code_editor:set_text(open_files[focused_file].state)
end

on_event("drop_items",function(msg)
	for i=1,#msg.items do
		local item = msg.items[i]
		notify(item.pod_type)
		if item.pod_type == "file_reference" then
			if item.attrib == "file" then
				notify("Added "..item.filename)
				add(open_files,{path=item.fullpath,name=item.filename,state=fetch(item.fullpath)})
				set_active_tab(#open_files)
			else
				notify("Not a file.")
			end
		else
			notify("Couldn't open "..item.filename)
		end
	end
end)
