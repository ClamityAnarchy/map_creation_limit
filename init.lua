local timeouts = {}

local old_fill_map = minetest.registered_items["mcl_maps:empty_map"].on_place

local function fill_map(itemstack, player, pointed_thing)
	local new_stack = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
	if new_stack then
		return new_stack
	end

	local seconds = timeouts[player]
	if seconds then
		minetest.chat_send_player(player:get_player_name(), ""
			.. minetest.get_color_escape_sequence(mcl_colors.RED)
			.. "You can't create maps that quickly! Please wait "
			.. minetest.get_color_escape_sequence(mcl_colors.YELLOW)
			.. math.floor(seconds)
			.. minetest.get_color_escape_sequence(mcl_colors.RED)
			.. " seconds before creating another map."
		)
		return itemstack
	else
		timeouts[player] = tonumber(minetest.settings:get("map_creation_limit")) or 30
		return old_fill_map(itemstack, player, pointed_thing)
	end
end

minetest.override_item("mcl_maps:empty_map", {
	on_place = fill_map,
	on_secondary_use = fill_map,
})

minetest.register_on_leaveplayer(function(player)
	timeouts[player] = nil
end)

minetest.register_globalstep(function(dtime)
	local new_timeouts = {}
	for player, timeout in pairs(timeouts) do
		timeout = timeout - dtime
		if timeout < 0 then
			minetest.chat_send_player(player:get_player_name(), minetest.colorize(mcl_colors.GREEN, "You may now create a map again."))
		else
			new_timeouts[player] = timeout
		end
	end
	timeouts = new_timeouts
end)
