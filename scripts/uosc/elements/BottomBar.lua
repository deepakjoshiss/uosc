local Element = require('elements/Element')

---@class BottomBar : Element
local BottomBar = class(Element)

function BottomBar:new() return Class.new(self) --[[@as BottomBar]] end
function BottomBar:init()
	Element.init(self, 'bottombar')
	self.opacity = 1
end

function BottomBar:update_dimensions()

	self.size = state.fullormaxed and 120 or 80
	self.blur = state.fullormaxed and 105 or 70
	self.font_size = math.floor(20 * options.font_scale)
	self.ax = Elements.window_border.size
	self.ay = display.height - Elements.window_border.size - self.size * 1.25
	self.bx = display.width - Elements.window_border.size
	self.by = display.height - Elements.window_border.size
	self.pos_y = display.height + 5
end

function BottomBar:on_prop_border() self:update_dimensions() end
function BottomBar:on_prop_fullormaxed() self:update_dimensions() end
function BottomBar:on_display() self:update_dimensions() end

function BottomBar:render()
	local visibility = self:get_visibility()

	if visibility <= 0 or self.opacity <= 0 then return end

	local ass = assdraw.ass_new()
	ass:new_event()
	ass:pos(0, 0)
	ass:append(string.format('{\\rDefault\\an7\\blur%d\\bord%d\\1c&H000000&\\3c&H000000&}', self.blur, self.size))
	ass:opacity(self.opacity * visibility)
	ass:draw_start()
	ass:move_to(self.ax, self.pos_y)
    ass:line_to(self.bx, self.pos_y)
	ass:draw_stop()
	return ass
end

return BottomBar
