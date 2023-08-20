local Element = require('elements/Element')

---@alias PlayButtonProps {icon: string; on_click: function; anchor_id?: string; active?: boolean; badge?: string|number; foreground?: string; background?: string; tooltip?: string}

---@class PlayButton : Element
local PlayButton = class(Element)

function PlayButton:new() return Class.new(self) --[[@as PlayButton]] end

function PlayButton:init()
	Element.init(self, 'play_button')
	self.anchor_id = 'controls'
	self.icon = self:get_icon()
	-- self.tooltip = self:get_tooltip()
	self.active = false
	self.foreground = fg
	self.background = bg
	self.size = options.controls_size and options.controls_size * 1.5 or 48

	---@type fun()
	self.on_click = function()
		mp.command('script-binding uosc/playpause')
	end

	mp.observe_property('pause', 'bool', function(_, paused)
		self.icon = self:get_icon()
		-- self.tooltip = self:get_tooltip()
		request_render()
	end)
end

function PlayButton:get_icon()
	return state.pause and 'play_circle' or 'pause_circle'
end

function PlayButton:get_tooltip()
	return state.pause and 'Play' or 'Pause'
end

function PlayButton:on_coordinates() self.font_size = round((self.by - self.ay) * 0.7) end

function PlayButton:handle_cursor_down()
	-- We delay the callback to next tick, otherwise we are risking race
	-- conditions as we are in the middle of event dispatching.
	-- For example, handler might add a menu to the end of the element stack, and that
	-- than picks up this click event we are in right now, and instantly closes itself.
	mp.add_timeout(0.01, self.on_click)
end

function PlayButton:update_dimensions()
	local margin = options.controls_margin / 2
	local size = self.size
	local window_border = Elements.window_border.size

	self.ax = (display.width - window_border - size) / 2
	self.bx = self.ax + size
	self.by = (display.height - window_border) - margin
	self.ay = self.by - size
	self.font_size = round((self.by - self.ay) * 0.7)
end

function PlayButton:render()
	local visibility = self:get_visibility()
	if visibility <= 0 then return end
	if self.proximity_raw == 0 then
		cursor.on_primary_down = function() self:handle_cursor_down() end
	end

	local ass = assdraw.ass_new()
	local is_hover = self.proximity_raw == 0
	local is_hover_or_active = is_hover or self.active
	local foreground = self.active and self.background or self.foreground
	local background = self.active and self.foreground or self.background

	-- Background
	if is_hover_or_active then
		ass:rect(self.ax, self.ay, self.bx, self.by, {
			color = self.active and background or foreground,
			radius = self.size and self.size / 2 or 2,
			opacity = visibility * (self.active and 1 or 0.3),
		})
	end

	-- Tooltip on hover
	if is_hover and self.tooltip then ass:tooltip(self, self.tooltip) end

	-- Badge
	local icon_clip
	-- Icon
	local x, y = round(self.ax + (self.bx - self.ax) / 2), round(self.ay + (self.by - self.ay) / 2)
	ass:icon(x, y, self.font_size, self.icon, {
		color = foreground,
		border = self.active and 0 or options.text_border,
		border_color = background,
		opacity = visibility,
		clip = icon_clip,
	})

	return ass
end


function PlayButton:on_display() self:update_dimensions() end
function PlayButton:on_prop_border() self:update_dimensions() end
function PlayButton:on_prop_fullormaxed() self:update_dimensions() end

return PlayButton
