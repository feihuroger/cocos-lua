--=======================================================================
-- File Name    : class.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : date
-- Description  : simulate a table to a class in c++
-- 					1. can use funciton declared in base class
-- 					2. can make the call order of (Init | Uninit) like (instructor | destructor)
-- Modify       : 
--=======================================================================

if not Class then
	Class = {}
end

local MetaTable = {
	__index = function(table, key)
		local v = rawget(table, key)
		if v then
			return v
		end
		local base_class = rawget(table, "_tbBase")
		if base_class then
			return base_class[key]
		end
	end
}

local function Init(self, ...)
	local init_list = {}
	local base_class = self._tbBase
	while base_class do
		local init_func = rawget(base_class, "_Init")
		if init_func then
			init_list[#init_list + 1] = {init_func, rawget(base_class, "__class_name")}
		end
		base_class = base_class._tbBase
	end
	for i = #init_list, 1, -1 do
		local func, name = unpack(init_list[i])
		if Class.is_debug == 1 then
			print("--",name, " Init..")
		end
		func(self, ...)
	end
	if Class.is_debug == 1 then
		print(rawget(self, "__class_name"), " Init..")
	end
	local init_func = rawget(self, "_Init")
	if not init_func then
		return 1
	end	
	return init_func(self, ...)
end

local function Uninit(self, ...)
	local uninit_func = rawget(self, "_Uninit")
	if Class.is_debug == 1 then
		print(rawget(self, "__class_name"), " Uninit..")
	end
	if uninit_func then		
		uninit_func(self, ...)
	end

	local uninit_list = {}
	local base_class = self._tbBase
	while base_class do
		local uninit_func = rawget(base_class, "_Uninit")
		if uninit_func then
			uninit_list[#uninit_list + 1] = {uninit_func, rawget(base_class, "__class_name")}
		end
		base_class = base_class._tbBase
	end
	for i = 1, #uninit_list do
		local func, name = unpack(uninit_list[i])
		if Class.is_debug == 1 then
			print("--",name, " Uninit..")
		end
		func(self, ...)
	end	
end

local function GetClassName(self)
	return self.__class_name
end

function Class:New(base_class, class_name)
	local new_class = { _tbBase = base_class }
	setmetatable(new_class, MetaTable)
	new_class.__class_name = class_name
	new_class.Init = Init
	new_class.Uninit = Uninit	
	new_class.GetClassName = GetClassName
	return new_class
end

function Class:EnableDebug(is_debug)
	self.is_debug = is_debug
end