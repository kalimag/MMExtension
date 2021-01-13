local abs, floor, ceil, round, max, min = math.abs, math.floor, math.ceil, math.round, math.max, math.min
local i4, i2, i1, u4, u2, u1 = mem.i4, mem.i2, mem.i1, mem.u4, mem.u2, mem.u1
local mmver = offsets.MMVersion

-- In MM7 you may want to, but don't have to increase the number of columns in NPCDist.txt accordingly

local function mmv(...)
	local ret = select(mmver - 5, ...)
	assert(ret ~= nil)
	return ret
end

mem.ExtendGameStructure{'MapDoorSound', Size = 2,
	Refs = mmv({0x45552C, 0x455541, 0x4603F0}, {0x460CE9, 0x46F23F}, {0x447171, 0x45E5EA, 0x46DD17}),
	Fill = 0,
}

if mmver > 6 then
	mem.ExtendGameStructure{'MapFogChances', Size = 4,
		Refs = mmv(nil, {0x4894C6}, {0x488DC8}),
		Fill = 0,
	}
end

local NPCDistResize = mmver == 7 and mem.ExtendGameStructure{Size = 64,
	Struct = {
		['?ptr'] = 0x73A594,
		limit = 77,
	},
	Refs = {0x476B62, 0x476BD9, 0x4774F1, 0x47750A},  -- 0x476C22 is handled separately
} or nil

local patch = mmver == 7 and || do
	mem.asmpatch(0x454747, [[
		cmp ebx, [0x453FF0]
		jl absolute 0x453FF4
	]])
	
	mem.asmpatch(0x433B88, [[
		mov ecx, [0x4340CD]
		cmp eax, ecx
		jge absolute 0x4314C2
	]])

	mem.asmpatch(0x497F88, [[
		mov ecx, [0x4340CD]
		cmp eax, ecx
		jge absolute 0x497F84
	]])
		
	-- NPCDist.txt
	mem.asmpatch(0x476BC1, [[
		cmp ebx, [0x453FF0]
		jge absolute 0x476BDF
	]])
	
	mem.asmhook2(0x476BFC, [[
		cmp ecx, [0x453FF0]
	]])

	mem.asmpatch(0x476C20, [[
		mov eax, [0x4774F1]
		add eax, esi
		pop ecx
		push dword [0x453FF0]
	]])
	
	-- make caring of NPCDist.txt unaccessory
	mem.asmhook(0x4774FB, [[
		test ebx, ebx
		jnz @std
		mov ecx, 56
		idiv ecx
		mov eax, edx
		cmp eax, 38-3
		jl @f
		inc eax
		cmp eax, 51-3
		jl @f
		inc eax
	@@:
		jmp absolute 0x477516
	@std:
	]])
end

patch = patch or mmver == 8 and || do
	mem.asmpatch(0x451EB1, [[
		cmp ebx, [0x45175A]
		jl absolute 0x45175E
	]])
	mem.asmpatch(0x4313A9, [[
		cmp eax, [0x45175A]
		jge absolute 0x430368
	]])
	-- fix by Rodril
	mem.asmpatch(0x4949a0, [[
		cmp eax, [0x45175A]
		jge absolute 0x49499c
	]])
end

local function SetLenP(n, _, dp, ptr, size)
	if dp ~= 0 then
		mem.ChangeGameArray('MapStats', nil, nil, ptr + n*size)
	end
end

mem.ExtendGameStructure{'MapStats', Size = mmv(0x38, 0x44, 0x44),
	Refs = mmv(
		{0x40CAC1, 0x40EB6E, 0x40EBB7, 0x40ED24, 0x40EFEB, 0x419BF8, 0x41E55A, 0x41E5C2, 0x425E48, 0x425EEB, 0x42C6DF, 0x42C71B, 0x42E07A, 0x42E0A2, 0x42E0C0, 0x42E0F3, 0x42E648, 0x42F049, 0x4309DF, 0x4309FC, 0x43A197, 0x43A1B5, 0x43A202, 0x43A221, 0x43A323, 0x43A3DA, 0x43A3EC, 0x43A403, 0x43A542, 0x43A566, 0x43A654, 0x43A683, 0x43A70D, 0x43A714, 0x43A7EE, 0x43EA25, 0x43EA71, 0x448F4A, 0x45022A, 0x450243, 0x454F97, 0x454FAE, 0x455330, 0x455349, 0x45631A, 0x456333, 0x469DC4, 0x469DDD, 0x48A175, 0x48A18E, 0x4972A4, 0x49830A, 0x499904, 0x40C857, 0x40C87B, 0x40CA55, 0x40CA75},
		{0x410DBB, 0x410DCB, 0x410FB2, 0x413C39, 0x413C7A, 0x413D8F, 0x413F97, 0x41CC24, 0x42042E, 0x42045C, 0x42EC03, 0x42EC1C, 0x432F72, 0x43331B, 0x43349C, 0x4334B1, 0x4334CD, 0x4334FB, 0x4338D1, 0x433969, 0x433B9F, 0x433C1B, 0x4340A4, 0x4340D8, 0x438D72, 0x438E35, 0x438E4E, 0x444565, 0x444577, 0x44495D, 0x44496F, 0x4449C5, 0x4449D7, 0x444A8A, 0x444BCB, 0x444D38, 0x444D60, 0x444E05, 0x444F02, 0x444F80, 0x448D30, 0x448D7F, 0x45025C, 0x450275, 0x456DCA, 0x4603B0, 0x4603C7, 0x460B7F, 0x460B96, 0x46116E, 0x464945, 0x47A3EC, 0x47A404, 0x489482, 0x49594A, 0x49595C, 0x497F94, 0x4ABF59, 0x4ABF71, 0x4ABFC6, 0x4ABFE0, 0x4AC02A, 0x4AC0D1, 0x4B2A1F, 0x4B3518, 0x4B41EA, 0x4B69DF, 0x4B6A91, 0x4B6DE2, 0x4BE045, 0x4BE05A},
		{0x4121C9, 0x4121DC, 0x41336B, 0x4133A7, 0x41C145, 0x41F926, 0x41F936, 0x4307E0, 0x430BBA, 0x430D3D, 0x430D60, 0x430D79, 0x430D9F, 0x431186, 0x43120F, 0x4313B6, 0x431433, 0x4319B0, 0x4319D0, 0x4367C7, 0x4367DF, 0x441440, 0x441452, 0x441886, 0x441898, 0x4418FA, 0x44190C, 0x441A16, 0x441B68, 0x441D48, 0x441E1E, 0x441E97, 0x446160, 0x446193, 0x44D984, 0x44D998, 0x454661, 0x45DE1A, 0x45DE28, 0x45E499, 0x45E4B0, 0x45EA89, 0x462C8C, 0x4795DE, 0x4795F6, 0x47E2CC, 0x488DA8, 0x493C17, 0x493C29, 0x4949AA, 0x4AA3ED, 0x4AA400, 0x4AA45A, 0x4AA474, 0x4AA4BE, 0x4AA565, 0x4B1232, 0x4B1E34, 0x4B2C94, 0x4B5290, 0x4B52F0, 0x4B5656, 0x4D1827}
	),
	LimCountRefs = mmv({0x44671D}, {}, {}),
	LimEndRefs = mmv({0x42C708}, {0x4340CD}, {0x4319C5}),
	LimSizeRefs = mmv({0x446719, 0x446BD7, 0x446C02, 0x446B5E}, {0x453FEC, 0x454752, 0x4547D9, 0x4547FE}, {0x451756, 0x451EBD, 0x451F43, 0x451F68}),
	EndSize = 4,
	Custom = {
		SetLenP,
		|| if patch then
			patch()
			patch = nil
		end,
		NPCDistResize and |n| NPCDistResize(n)
	}
}

-- reading MapStats.txt
mem.autohook(mmv(0x4466F7, 0x453FD1, 0x45173B), function(d)
	local n = DataTables.ComputeRowCountInPChar(d.eax, mmv(26, 30, 30), 3) - 2
	if n == Game.MapStats.count then
		return
	end
	
	-- set new read limit
	mem.prot(true)
	if mmver == 6 then
		i4[0x446B62] = n
		i4[0x446728] = n - 1
	elseif mmver == 7 then
		i4[0x453FF0] = n
	else
		i4[0x45175A] = n
	end
	mem.prot(false)

	-- extend everything
	Game.MapStats.Resize(n)
	Game.MapDoorSound.Resize(n)
	if mmver > 6 then
		Game.MapFogChances.Resize(n)
	end
	if patch then
		patch()
		patch = nil
	end
	
	-- update address
	d[mmv('ebx', 'esi', 'esi')] = Game.MapStats['?ptr']
end)
