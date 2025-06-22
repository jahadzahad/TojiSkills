local storedThreads : {thread} = {}

local Threads = {} 

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

function Threads.Defer(func : () -> (), ...) : thread
	local threadFound : thread = table.remove(storedThreads)

	if threadFound and coroutine.status(threadFound) ~= "suspended" then threadFound = nil end

	return task.defer(threadFound or Thread, func, ...)
end

function Threads.Spawn(func : () -> (), ...) : thread
	local threadFound : thread = table.remove(storedThreads)

	if threadFound and coroutine.status(threadFound) ~= "suspended" then threadFound = nil end

	return task.spawn(threadFound or Thread, func, ...)
end

return Threads
