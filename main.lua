--[[

	SLATE
	scrapSavage's Lovely Advanced Text Editor
	
	Changing this file with auto updates enabled will overwrite changes.

--]]

local gui
local code_editor

local focused_file = 1

local open_files = {}

local focused = false

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

local save_button
local run_button
local term_button

menuitem({
	id=0,
	label="Help",
	action=function()
		local help = fetch("https://raw.githubusercontent.com/scrapSavage/SLATE/main/help.txt")
		store("help.txt",help,{})
		add(open_files,{path=pwd().."help.txt",name="help.txt",state=fetch("help.txt")})
		set_active_tab(#open_files)
	end
})
menuitem({
	id=1,
	label="Close active tab",
	action=function()
		if focused_file-1==0 then
			if #open_files<2 then
				exit()
			else
				deli(open_files,focused_file)
				focused_file = 1
				code_editor:set_text(open_files[focused_file].state)
			end
		else
			deli(open_files,focused_file)
			focused_file-=1
			code_editor:set_text(open_files[focused_file].state)
		end
	end
})

function _init()
	store("/ram/cart/untitled.txt","",{})
	add(open_files,{path="/ram/cart/untitled.txt",name="untitled.txt",state=fetch("/ram/cart/untitled.txt")})
	gui = create_gui()
	code_editor = gui:attach_text_editor({
		x=0,y=14,
		width=150,
		height=200,
		width_rel=1,
		height_rel=1,
		show_line_numbers=true,
		syntax_highlighting=true,
		markup=false,
		embed_pods=true,
		has_search=true
	})
	code_editor:attach_scrollbars({autohide=true})
	
	-- quick buttons
	
	--save
	save_button = gui:attach{
		cursor = "pointer",
		x = 0, y = 0,
		width=10, height=10,
		draw = function(self)
		end,
		tap = function(self)
			open_files[focused_file].state = table.concat(code_editor:get_text(),"\n")
			store(open_files[focused_file].path,open_files[focused_file].state,{})
			notify("Saved "..open_files[focused_file].path)
			self.y=0
		end,
		click = function(self)
			self.y=1
		end
	}
	--run
	run_button = gui:attach{
		cursor = "pointer",
		x = 10, y = 0,
		width=10, height=10,
		draw = function(self)
		end,
		tap = function(self)
			create_process(open_files[focused_file].path)
			self.y=0
		end,
		click = function(self)
			self.y=1
		end
	}
	--term
	term_button = gui:attach{
		cursor = "pointer",
		x = 20, y = 0,
		width=10, height=10,
		draw = function(self)
		end,
		tap = function(self)
			notify("This button doesn't do anything yet.")
			self.y=0
		end,
		click = function(self)
			self.y=1
		end
	}
	
	--clicking tabs
	gui:attach{
		cursor = "pointer",
		x=32, y=0,
		width=1000, height=10,
		tap = function(self)
			if get_tab_at_mouse() then
				set_active_tab(get_tab_at_mouse())
			end
		end
	}
end

function get_tab_at_mouse()
	local offset = 0
	for i=1,#open_files do
		local file = open_files[i]
		if mouse_aabb(32+offset,0,32+offset+txtw(file.name)+2,10) then
			return i
		end
		offset+=txtw(file.name)+4
	end
	return false
end

-- ternary doesn't seem to be working (or I'm doing it wrong)
-- please let me know
function tern(con,a,b)
	if con then return a end
	return b
end

function tab(x,w,yoff,sel,txt)
	rectfill(x,3+yoff,x+w,10,tern(sel,16,1))
	line(x+1,2+yoff,x+w-1,2+yoff)
	print(txt,x+2,3+yoff,7)
end

function txtw(txt)
	return print(txt,0,-1000)
end

function mouse_aabb(x1,y1,x2,y2)
	local mx,my = mouse()
	return (mx>=x1 and mx<=x2 and my>=y1 and my<=y2 and focused)
end

function _draw()
	gui:update_all()
	gui:draw_all()
	window({
		title=(open_files[focused_file].path.." - SLATE")
	})
	rectfill(0,0,1000,10,12)
	rectfill(0,11,1000,13,16)
	spr(button_gfx.save,1,2+save_button.y)
	spr(button_gfx.run,10,2+run_button.y)
	spr(button_gfx.term,19,2+term_button.y)
	local offset = 0
	for i=1,#open_files do
		local file = open_files[i]
		local foc = i==focused_file
		tab(32+offset,txtw(file.name)+2,tern(foc,-1,0),foc,file.name)
		offset+=txtw(file.name)+4
	end
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

on_event("gained_focus",function(msg)
	focused=true
end)

on_event("lost_focus",function(msg)
	focused=false
end)
