-- local variables for API functions. any changes to the line below will be lost on re-generation
local bit_band, client_camera_angles, client_create_interface, client_exec, client_eye_position, client_key_state, client_screen_size, client_set_event_callback, client_trace_bullet, client_trace_line, client_userid_to_entindex, database_read, database_write, entity_get_all, entity_get_classname, entity_get_local_player, entity_get_players, entity_get_prop, entity_hitbox_position, entity_is_alive, entity_is_dormant, entity_is_enemy, entity_set_prop, globals_curtime, math_abs, math_atan, math_cos, math_floor, math_min, math_rad, math_random, math_sin, math_sqrt, panorama_loadstring, string_format, print, table_getn, ui_get, ui_new_color_picker, ui_new_hotkey, ui_new_checkbox, ui_new_label, ui_new_slider, ui_reference, ui_set, ui_set_visible, pairs = bit.band, client.camera_angles, client.create_interface, client.exec, client.eye_position, client.key_state, client.screen_size, client.set_event_callback, client.trace_bullet, client.trace_line, client.userid_to_entindex, database.read, database.write, entity.get_all, entity.get_classname, entity.get_local_player, entity.get_players, entity.get_prop, entity.hitbox_position, entity.is_alive, entity.is_dormant, entity.is_enemy, entity.set_prop, globals.curtime, math.abs, math.atan, math.cos, math.floor, math.min, math.rad, math.random, math.sin, math.sqrt, panorama.loadstring, string.format, print, table.getn, ui.get, ui.new_color_picker, ui.new_hotkey, ui.new_checkbox, ui.new_label, ui.new_slider, ui.reference, ui.set, ui.set_visible, pairs

local surface = require 'gamesense/surface'
local vector = require 'vector'
local ffi = require 'ffi'


ffi.cdef[[	
    typedef void*(__thiscall* get_client_entity_t_128481294812948)(void*, int);

	struct CCSGOPlayerAnimstate_128481294812948 {
		char pad[3];
		char m_bForceWeaponUpdate;
		char pad1[91];
		void* m_pBaseEntity;
		void* m_pActiveWeapon;
		void* m_pLastActiveWeapon;
		float m_flLastClientSideAnimationUpdateTime;
		int m_iLastClientSideAnimationUpdateFramecount;
		float m_flAnimUpdateDelta;
		float m_flEyeYaw;
		float m_flPitch;
		float m_flGoalFeetYaw;
		float m_flCurrentFeetYaw;
		float m_flCurrentTorsoYaw;
		float m_flUnknownVelocityLean;
		float m_flLeanAmount;
		char pad2[4];
		float m_flFeetCycle;
		float m_flFeetYawRate;
		char pad3[4];
		float m_fDuckAmount;
		float m_fLandingDuckAdditiveSomething;
		char pad4[4];
		float m_vOriginX;
		float m_vOriginY;
		float m_vOriginZ;
		float m_vLastOriginX;
		float m_vLastOriginY;
		float m_vLastOriginZ;
		float m_vVelocityX;
		float m_vVelocityY;
		char pad5[4];
		float m_flUnknownFloat1;
		char pad6[8];
		float m_flUnknownFloat2;
		float m_flUnknownFloat3;
		float m_flUnknown;
		float m_flSpeed2D;
		float m_flUpVelocity;
		float m_flSpeedNormalized;
		float m_flFeetSpeedForwardsOrSideWays;
		float m_flFeetSpeedUnknownForwardOrSideways;
		float m_flTimeSinceStartedMoving;
		float m_flTimeSinceStoppedMoving;
		bool m_bOnGround;
		bool m_bInHitGroundAnimation;
		float m_flTimeSinceInAir;
        float m_flLastOriginZ;
        float m_flLastOriginZ;
		float m_flHeadHeightOrOffsetFromHittingGroundAnimation;
	};
]]

local entity_list = ffi.cast(ffi.typeof("void***"), client_create_interface("client.dll", "VClientEntityList003"))
local get_client_entity = ffi.cast("get_client_entity_t_128481294812948", entity_list[0][3])









---------------------------------------------------------------------------------------------------------------------------ui

ui_new_label("lua", "b", "-adderall-")
local antiaim = ui_new_checkbox("lua", "b", "anti-aim freestanding")
local autobuy_awp = ui_new_hotkey("lua", "b", "awp autobuy", false)
local legitaa = ui_new_hotkey("lua", "b", "legit anti-aim bind", false)
local edge_yaw = ui_new_hotkey("lua", "b", "edge yaw", false)
local old_animfixe = ui_new_checkbox("lua", "b", "old animfix")

local new_limit = ui_new_slider("aa", "fake lag", "Limit", 1, 14, 14, true, "", 1, true)

ui_new_label("lua", "b", "indicator 1 color")
local indicator1_color = ui_new_color_picker("lua", "b", "on color", 76, 127, 198, 255)
ui_new_label("lua", "b", "indicator 2 color")
local indicator2_color = ui_new_color_picker("lua", "b", "off color", 255,255,255,255)
ui_new_label("lua", "b", "on hotkey color")
local on_hotkey_color = ui_new_color_picker("lua", "b", "on hotkey color", 76, 127, 198, 255)
ui_new_label("lua", "b", "off hotkey color")
local off_hotkey_color = ui_new_color_picker("lua", "b", "off hotkey color", 255,255,255,255)


local pitch, yaw_base = ui_reference("aa", "anti-aimbot angles", "pitch"), ui_reference("aa", "anti-aimbot angles", "yaw base")
local get_lby = ui_reference("aa", "anti-aimbot angles", "lower body yaw target")
local fd = ui_reference("rage", "other", "duck peek assist")
local dt,dt_h = ui_reference("rage", "other", "double tap")
local os, os_h = ui_reference("aa", "other", "on shot anti-aim")
local fake_lag_limit = ui_reference("aa", "fake lag", "limit")
local legs = ui_reference("aa", "other", "leg movement")
local maxprcs = ui_reference("misc", "settings", "sv_maxusrcmdprocessticks")
local yaw, yawv = ui_reference("aa", "anti-aimbot angles", "yaw")
local edge = ui_reference("aa", "anti-aimbot angles", "edge yaw")
local slowmotion_check,slowmotion = ui_reference("AA", "other", "slow motion")
local byaw, byaw_value = ui_reference("aa", "anti-aimbot angles", "body yaw")
local fake_yaw = ui_reference("aa", "anti-aimbot angles", "fake yaw limit")

ui_set_visible(fake_lag_limit, false)

ui_set_visible(maxprcs, true)
ui_set(maxprcs, 21)
-------------------------------------------------------------------------------------------------------------------------end of ui


-------------------------------------------------------------------------------math
local function angle_to_vec(pitch, yaw)
	local p, y = math_rad(pitch), math_rad(yaw)
	local sp, cp, sy, cy = math_sin(p), math_cos(p), math_sin(y), math_cos(y)
	return cp*cy, cp*sy, -sp
end

local function vec3_dot(ax, ay, az, bx, by, bz)
	return ax*bx + ay*by + az*bz
end

local function vec3_normalize(x, y, z)
	local len = math_sqrt(x * x + y * y + z * z)
	if len == 0 then
		return 0, 0, 0
	end
	local r = 1 / len
	return x*r, y*r, z*r
end

local function get_fov_cos(ent, vx,vy,vz, lx,ly,lz)
	local ox,oy,oz = entity_get_prop(ent, "m_vecOrigin")
	if ox == nil then
		return -1
	end
	
	-- get direction to player
	local dx,dy,dz = vec3_normalize(ox-lx, oy-ly, oz-lz)
	return vec3_dot(dx,dy,dz, vx,vy,vz)
end

local function GetClosestPoint(A, B, P)
	local a_to_p = { P[1] - A[1], P[2] - A[2] }
	local a_to_b = { B[1] - A[1], B[2] - A[2] }
	local ab = a_to_b[1]^2 + a_to_b[2]^2
	local dots = a_to_p[1]*a_to_b[1] + a_to_p[2]*a_to_b[2]
	local t = dots / ab

	return { A[1] + a_to_b[1]*t, A[2] + a_to_b[2]*t }
end

local function Angle_Vector(angle_x, angle_y)
	local sp, sy, cp, cy = nil
	sy = math_sin(math_rad(angle_y));
	cy = math_cos(math_rad(angle_y));
	sp = math_sin(math_rad(angle_x));
	cp = math_cos(math_rad(angle_x));
	return cp * cy, cp * sy, -sp;
end

local function CalcAngle(localplayerxpos, localplayerypos, enemyxpos, enemyypos)
	local relativeyaw = math_atan( (localplayerypos - enemyypos) / (localplayerxpos - enemyxpos) )
	return relativeyaw * 180 / math.pi
end

local function get_velocity(player)
	local x,y,z = entity_get_prop(player, "m_vecVelocity")
	if x == nil then return end
	return math_sqrt(x*x + y*y + z*z)
end

local function entity_has_c4(ent)
	local bomb = entity_get_all("CC4")[1]
	return bomb ~= nil and entity_get_prop(bomb, "m_hOwnerEntity") == ent
end

local function distance3d(x1, y1, z1, x2, y2, z2)
	return math_sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1))
end

--------------------------------------------------------------------------------------------------end of math

--------------------------------------------------------------------------------------------------antiaim functions


---storing some important variables
local next_angle = 0
local abf_time = 0
local last_angle_nig = nil
local enemies = {}

--fix for enemies
local function on_player_spawned()
    enemies = entity_get_players(true)
end
    
--get target function
local function get_target()
	local plocal = entity_get_local_player()
	if plocal == nil then return "[error] cant find local player " end
	local lx,ly,lz = entity_get_prop(plocal, "m_vecOrigin")
	if lx == nil then return "[error] cant find X origin of local player" end



	local pitch, yaw = client_camera_angles()
	local vx, vy, vz = angle_to_vec(pitch, yaw)
	enemies = entity_get_players(true)
	local closest_fov_cos = -1
	enemyclosesttocrosshair = nil
	for i=1, #enemies do
		local idx = enemies[i]
		if entity_is_alive(idx) then
			local fov_cos = get_fov_cos(idx, vx,vy,vz, lx,ly,lz)

			if fov_cos > closest_fov_cos then
				closest_fov_cos = fov_cos
				enemyclosesttocrosshair = idx
			end
		end
	end
	return enemyclosesttocrosshair
end

--safe head
local function DoFreestanding(enemy, ...)
	local lx, ly, lz = entity_get_prop(entity_get_local_player(), "m_vecOrigin")
	local viewangle_x, viewangle_y, roll = client_camera_angles()
	local headx, heady, headz = entity_hitbox_position(entity_get_local_player(), 0)
	local enemyx, enemyy, enemyz = entity_get_prop(enemy, "m_vecOrigin")
	local bestangle = nil
	local lowest_dmg = math.huge

	if(entity_is_alive(enemy)) then
		local yaw = CalcAngle(lx, ly, enemyx, enemyy)
		for i,v in pairs({...}) do
			local dir_x, dir_y, dir_z = Angle_Vector(0, (yaw + v))
			local end_x = lx + dir_x * 55
			local end_y = ly + dir_y * 55
			local end_z = lz + 80

			local index, damage = client_trace_bullet(enemy, enemyx, enemyy, enemyz + 70, end_x, end_y, end_z,true)
			local index2, damage2 = client_trace_bullet(enemy, enemyx, enemyy, enemyz + 70, end_x + 12, end_y, end_z,true) --test
			local index3, damage3 = client_trace_bullet(enemy, enemyx, enemyy, enemyz + 70, end_x - 12, end_y, end_z,true) --test

			if(damage < lowest_dmg) then
				lowest_dmg = damage
				if(damage2 > damage) then
					lowest_dmg = damage2
				end
				if(damage3 > damage) then
					lowest_dmg = damage3
				end
				if(lx - enemyx > 0) then
					bestangle = v
				else
					bestangle = v * -1
				end
			elseif(damage == lowest_dmg) then
				return 0
			end
		end
	end
	return bestangle
end

------------------------aa on use
local function aa_on_use(c)
	if not ui_get(antiaim) then return end
	local plocal = entity_get_local_player()
		
	local distance = 100
	local bomb = entity_get_all("CPlantedC4")[1]
	local bomb_x, bomb_y, bomb_z = entity_get_prop(bomb, "m_vecOrigin")

	if bomb_x ~= nil then
		local player_x, player_y, player_z = entity_get_prop(plocal, "m_vecOrigin")
		distance = distance3d(bomb_x, bomb_y, bomb_z, player_x, player_y, player_z)
	end
	
	local team_num = entity_get_prop(plocal, "m_iTeamNum")
	local defusing = team_num == 3 and distance < 62

	local on_bombsite = entity_get_prop(plocal, "m_bInBombZone")

	local has_bomb = entity_has_c4(plocal)
	local trynna_plant = on_bombsite ~= 0 and team_num == 2 and has_bomb and false
	
	local px, py, pz = client_eye_position()
	local pitch, yaw = client_camera_angles()

	local sin_pitch = math_sin(math_rad(pitch))
	local cos_pitch = math_cos(math_rad(pitch))
	local sin_yaw = math_sin(math_rad(yaw))
	local cos_yaw = math_cos(math_rad(yaw))

	local dir_vec = { cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch }

	local fraction, entindex = client_trace_line(plocal, px, py, pz, px + (dir_vec[1] * 8192), py + (dir_vec[2] * 8192), pz + (dir_vec[3] * 8192))

	local using = true

	classnames = {
		"CWorld",
		"CCSPlayer",
		"CFuncBrush"
	}

	if entindex ~= nil then
		for i=0, #classnames do
			if entity_get_classname(entindex) == classnames[i] then
				using = false
			end
		end
	end

	if not using and not trynna_plant and not defusing then
		c.in_use = 0
	end
end
------------------------end
--anti bruteforce fucntion
local function on_bullet_impact(c)
	if entity_is_alive(entity_get_local_player()) then
		local ent = client_userid_to_entindex(c.userid)
		if not entity_is_dormant(ent) and entity_is_enemy(ent) and ent == get_target() then
			local ent_shoot = { entity_get_prop(ent, "m_vecOrigin") }
			ent_shoot[3] = ent_shoot[3] + entity_get_prop(ent, "m_vecViewOffset[2]")
			local player_head = { entity_hitbox_position(entity_get_local_player(), 0) }
			local closest = GetClosestPoint(ent_shoot, { c.x, c.y, c.z }, player_head)
			local delta = { player_head[1]-closest[1], player_head[2]-closest[2] }
			local delta_2d = math_sqrt(delta[1]^2+delta[2]^2)

			if math_abs(delta_2d) < 120  then
				abf_time = globals_curtime() + 5
				next_angle = next_angle + 1
				if next_angle > 4 then next_angle = 1 end
				last_angle_nig = ui_get(byaw_value)
			end
		end
	end
end 
local function on_player_hit(e)
	if client_userid_to_entindex(e.userid) == entity_get_local_player() then
		abf_time = globals_curtime() + 5 
		next_angle = next_angle + 1
		if next_angle > 4 then next_angle = 1 end
		last_angle_nig = ui_get(byaw_value)
	end
end

------------------------------legitaa
local function legit(aa)
	local not_using = DoFreestanding(get_target(), -90, 90)

	if not_using ~= 0 and not_using ~= nil then
		mode = not_using
	end

	if ui_get(legitaa) then
		ui_set(yaw_base, "local view")
		ui_set(pitch, "off")
		ui_set(yawv, 180)
		ui_set(fake_yaw, 60)
		ui_set(byaw, "static")
		ui_set(byaw_value, mode == 90 and 90 or -90)
		ui_set(get_lby, (ui_get(dt) and ui_get(dt_h)) and "eye yaw" or "opposite")
	end
end
------------------------------end

------------------------------------------------------------------------------------------------------------------------main aa function
local  function antiaimos(e)
	--main check

	local plocal = entity_get_local_player()
	if not ui_get(antiaim)  or  plocal == nil or ui_get(legitaa) then
		return
	end


	--setup
	ui_set(yaw_base, "at targets")
	ui_set(pitch, "minimal")
	ui_set(edge, ui_get(edge_yaw))
	ui_set(yawv, 0)
	ui_set(fake_yaw, 59)
	ui_set(byaw, "Static")
	ui_set(get_lby, "eye yaw")


	--jitter if target is nill(target doesnt exist) 
	if get_target() == nil then
		ui_set(byaw, "jitter")
		ui_set(byaw_value, 0)
		ui_set(fake_yaw, 60)
		ui_set(get_lby, "eye yaw")
		return
	end

	--anti bruteforce
	if abf_time >= globals_curtime() then
		ui_set(byaw, "static")
		ui_set(fake_yaw, 59)
		if next_angle ==1 then 
			ui_set(byaw_value, last_angle_nig > 0 and -18 or 13)
		elseif next_angle ==  2 then
			ui_set(byaw_value, last_angle_nig > 0 and -30 or 30)
		elseif next_angle == 3 then
			ui_set(byaw_value, last_angle_nig > 0 and -17 or 30)	
		elseif next_angle == 4 then 
			ui_set(byaw_value, last_angle_nig > 0 and 15 or -30)
		end

		
		return
	else
		next_angle = 0
	end

	--getting mode and storing it
	local not_using = DoFreestanding(get_target(), -90, 90)
	local mode
	if  not_using ~= 0 and not_using ~= nil then
	    mode = not_using
	end

	--------flags
	local flags = entity_get_prop(plocal, "m_fFlags")
	local my_team = entity_get_prop(plocal, "m_iTeamNum")

	local is_t, is_ct = my_team == 2, my_team == 3
	local in_air = (bit_band(flags, 1) == 0) or e.in_jump == 1
    local ducking = e.in_duck == 1
	local is_slowwalking = ui_get(slowmotion)
	local is_moving =  get_velocity(entity_get_local_player()) > 5
	local is_staying = get_velocity(entity_get_local_player()) < 5
	---------end

	--main aa

	if is_t then  ------------------------------------------------t
		if in_air then 
			if client_key_state(0x10) then 								------in air without speed
				ui_set(byaw_value, mode == -90 and 20 or -20)
			else                                                                     ------in air with speed
				ui_set(byaw_value, mode == -90 and -15 or -10)
			end
		else
			if is_staying then 
				if ducking then 												------staying and ducking
					ui_set(byaw_value, mode == -90 and -37 or 8)
				else																	------staying
					ui_set(byaw_value, mode == -90 and -40 or 40)
				end
			elseif is_moving then
				if is_slowwalking then 											--slowwalking
					ui_set(byaw_value, mode == -90 and 19 or -19)
				else																		--moving
					ui_set(byaw_value, mode == -90 and -15 or 11)
				end	
			end
		end
	elseif is_ct then --ct 
		if in_air then 
			if client_key_state(0x10) then  								------in air without speed
				ui_set(byaw_value, mode == -90 and -11 or 21)
			else                                                                     ------in air with speed
				ui_set(byaw_value, mode == -90 and -10 or 9)
			end
		else
			if is_staying then 
				if ducking then									 						------staying and ducking
					ui_set(byaw_value, mode == -90 and -21 or 21)
				else																			------staying
					ui_set(byaw_value, mode == -90 and -40 or 40)
				end
			elseif is_moving then
				if is_slowwalking then  											--slowwalking
					ui_set(byaw_value, mode == -90 and 10 or -14)
				else																		--moving

				end
			end
		end
	end

end
---------------------------------------------------------------------------------------------------------------------------end of aa

--------------------------------------------------------------------------------------------------------------------------ideal tick

local function idealtick()
    local should = ui_get(dt_h) and ui_get(dt) and not ui_get(fd)
	if should then 
		ui_set(fake_lag_limit, 1) 
	else
		ui_set(fake_lag_limit, ui_get(new_limit))
	end 
end

--------------------------------------------------------------------------------------------------------------------------end

---------------------------------------------------------------------------------------------------------------------------indicators
local font = surface.create_font("Verdana", 12,0, { 0x200})
local function indicators()
	if not ui_get(antiaim)  or  not entity_is_alive(entity_get_local_player())then return end

	local x123,y123 = client_screen_size()
	local x, y = x123/2, y123/2
	local r1,g1,b1
	local r,g,b
	local ro,go,bo
	local re,ge,be
	if ui_get(dt) and ui_get(dt_h) then 
		r1,g1,b1 = ui_get(on_hotkey_color)
	else
		r1,g1,b1 = ui_get(off_hotkey_color)
	end

	if ui_get(os) and ui_get(os_h) then 
		r,g,b = ui_get(on_hotkey_color)
	else
		r,g,b = ui_get(off_hotkey_color)
	end

	
	local ro,go,bo
	local re,ge,be
	--credits to rave
	angle = math_floor(math_min(57, math_abs(entity_get_prop(entity_get_local_player(), "m_flPoseParameter", 11)) *10)+0.5)

	if not ui_get(legitaa) then 
		if angle > 5 then 
			ro,go,bo =ui_get(indicator1_color)
			re,ge,be = ui_get(indicator2_color)
		elseif angle == 5 then 
			ro,go,bo = ui_get(indicator2_color)
			re,ge,be =ui_get(indicator2_color)
		elseif angle < 5 then
			ro,go,bo =ui_get(indicator2_color)
			re,ge,be =ui_get(indicator1_color)
		end
	else
		if angle > 5 then 
			ro,go,bo =  ui_get(indicator2_color)
			re,ge,be =  ui_get(indicator1_color)
		elseif angle == 5 then 
			ro,go,bo = ui_get(indicator2_color)
			re,ge,be =  ui_get(indicator2_color)
		elseif angle < 5 then
			ro,go,bo = ui_get(indicator1_color)
			re,ge,be = ui_get(indicator2_color)
		end
	end

	surface.draw_text(x - surface.get_text_size(font, "add") ,y+40, ro,go,bo, 255, font, "add")
	surface.draw_text(x  ,y+40, re,ge,be, 255, font, "erall")
	surface.draw_text(x - surface.get_text_size(font, "dt")/2, y+50, r1,g1,b1,255, font, "dt")
	surface.draw_text(x - surface.get_text_size(font, "os")/2, y+60, r,g,b,255, font, "os")





	local ar = {"always slide", "never slide"}
	ui_set(legs, ar[math_random(1,#ar)])
end

-------------------------------------------------------------------------------------------------------------------------end

--autobuy
local function awp_autobuy()
	if ui_get(autobuy_awp) then client_exec("buy awp") end
end
--end

---------------------------------------------------------------------------------------------------------------------------callbacks
local function main()
    --aa
    client_set_event_callback("setup_command", antiaimos)
    --legit aa
    client_set_event_callback("setup_command", legit)
    --indicators
    client_set_event_callback("paint", indicators)
    --enemy list fix
    client_set_event_callback("player_spawned", on_player_spawned)
	--aa on use
	client_set_event_callback("setup_command", aa_on_use)
    --anti bruteforce
    client_set_event_callback("bullet_impact", on_bullet_impact)
	client_set_event_callback("player_hurt", on_player_hit)
	--ideal tick
	client_set_event_callback("setup_command", idealtick)
	--autobuy
	client_set_event_callback("round_prestart", awp_autobuy)

end

--main func
main()

--(pasted shit but it looks nice) old anim
client_set_event_callback('predict_command', function()
	if not ui_get(old_animfixe) then return end

    local local_player = entity_get_local_player()
  
    entity_set_prop(local_player, "m_flPoseParameter", 1, 6)

    local player_ptr = ffi.cast("void***", get_client_entity(entity_list, local_player))
	local animstate_ptr = ffi.cast("char*" , player_ptr) + 0x3914
    local animstate = ffi.cast("struct CCSGOPlayerAnimstate_128481294812948**", animstate_ptr)[0]

end)


---------------------jes jes ty kookot
