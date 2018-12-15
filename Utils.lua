local json = require("json")

local Utils = {}

function Utils.createClass(class, constructor, parent)
	--object metatable
	class.__index = class
	class.new = function(self, ...)
		if self==class then
			--create new self
			self = {}
			setmetatable(self, class)
		end
		self = constructor(self, ...) or self
		return self
	end

	--set parent class
	if parent then
		setmetatable(class, parent)
	end
	
	return class
end

function Utils.shuffleTable(t)
	for i=1,#t do
		local j = math.random(i, #t)
		t[i],t[j] = t[j],t[i]
	end
end

local function tostring2(elem)
	if type(elem)=='string' then
		return "'" .. elem .. "'"
	else
		return tostring(elem)
	end
end

function Utils.printTable(elem, hist, tabs)
	hist = hist or {}
	tabs = tabs or 0
	if type(elem)~='table' then
		print(tostring2(elem))
	else
		if not hist[elem] then
			hist[elem] = true
			print(tostring2(elem) .. ' {')
			tabs = tabs + 1
			for i,e in pairs(elem) do
				io.write(string.rep('\t', tabs) .. '[' .. tostring2(i) .. '] ')
				printR(e, hist, tabs)
			end
			tabs = tabs - 1
			print(string.rep('\t', tabs) .. '}')
		else
			print(tostring2(elem) .. ' {...}')
		end
	end
end
printR = Utils.printTable

function Utils.saveTable(filename, table)
	local path = system.pathForFile(filename, system.DocumentsDirectory)
	print("path", path)
	local file, errorMsg = io.open(path, "w")
	if file then
		file:write(json.encode(table))
		file:close()
	else
		error(errorMsg)
	end
end

function Utils.loadTable(filename)
	--try to open file
	local path = system.pathForFile(filename, system.DocumentsDirectory)
	local file, errorMsg = io.open(path, "r")

	--if not there, try to open default file
	if not file then
		path = system.pathForFile("default/" .. filename)
		file, errorMsg = io.open(path, "r")
	end

	if file then
		local table = json.decode(file:read("*a"))
		file:close()
		return table or {}
	end
	return {}
end

do
	local listeners = {}
	function Utils.listen(event, method, ...)
		if type(event)~="table" then
			event = {event}
		end

		--listener tables
		local lastListeners = listeners
		for _, index in ipairs(event) do
			lastListeners[index] = lastListeners[index] or {}
			lastListeners = lastListeners[index]
		end

		--method
		local param = {...}
		table.insert(lastListeners, function(...)
			local newParams = {}
			for _, p in ipairs(param) do
				table.insert(newParams, p)
			end
			for _, p in ipairs({...}) do
				table.insert(newParams, p)
			end
			method(unpack(newParams))
		end)
	end

	function Utils.notify(event, ...)
		if type(event)~="table" then
			event = {event}
		end

		--listener tables
		local lastListeners = listeners
		for _, index in ipairs(event) do
			--go to next level
			lastListeners = lastListeners[index]

			--stop if none
			if not lastListeners then
				break
			end

			--call all listeners on this level
			for _, listener in ipairs(lastListeners) do
				listener(event, ...)
			end
		end
	end
end

return Utils