local storedThreads : {thread} = {}

local ThreadHandler = {} 

function Call(func : () -> (), ...)
	func(...)
end

function Thread(func : () -> (), ...)
	func(...)
	while true do
		table.insert(storedThreads, coroutine.running())
		Call(coroutine.yield())
	end
end

ThreadHandler.Defer = function(func : () -> (), ...) : thread
	local threadFound : thread = table.remove(storedThreads)
	
	if threadFound and coroutine.status(threadFound) ~= "suspended" then threadFound = nil end
	
	return task.defer(threadFound or Thread, func, ...)
end

ThreadHandler.Spawn = function(func : () -> (), ...) : thread
	local threadFound : thread = table.remove(storedThreads)
	
	if threadFound and coroutine.status(threadFound) ~= "suspended" then threadFound = nil end
	
	return task.spawn(threadFound or Thread, func, ...)
end

ThreadHandler.Cancel = function(thread : thread) : (boolean, R...)
	if thread == nil then return end
	
	return pcall(task.cancel, thread)
end

return ThreadHandler
