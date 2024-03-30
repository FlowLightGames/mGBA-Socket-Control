lastkeys = nil
server = nil
ST_sockets = {}
nextID = 1

framecount=0
frame_input_interval=3
key_mask = {}

function ST_stop(id)
	local sock = ST_sockets[id]
	ST_sockets[id] = nil
	sock:close()
end

function ST_format(id, msg, isError)
	local prefix = "Socket " .. id
	if isError then
		prefix = prefix .. " Error: "
	else
		prefix = prefix .. " Received: "
	end

	return prefix .. msg
end

function ST_format_num(id, msg, isError)
	local prefix = ""
	if isError then
		prefix = prefix .. "-1"
	else
		prefix = prefix .. msg
	end
	
	return prefix
end

function ST_error(id, err)
	console:error(ST_format(id, err, true))
	ST_stop(id)
end

function ST_received(id)
	local sock = ST_sockets[id]
	if not sock then return end
	while true do
		local p, err = sock:receive(1024)
		if p then
			console:log(ST_format(id, p:match("^(.-)%s*$")))
			-- local num_s=""
			-- for i,byte in ipairs(p) do
			-- 	num_s=num_s..string.char(byte)
			-- end
			num=tonumber(p)
			if num>=0 then
				table.insert(key_mask,num)
			end
		else
			if err ~= socket.ERRORS.AGAIN then
				console:error(ST_format(id, err, true))
				ST_stop(id)
			end
			return
		end
	end
end

function ST_press_mask()
	if framecount>=frame_input_interval then
		framecount=0
		emu:clearKeys(0xFF)
	end
	for index,value in ipairs(key_mask)do
		emu:addKey(value)
	end
	key_mask={}

	framecount = framecount + 1
end

function ST_accept()
	local sock, err = server:accept()
	if err then
		console:error(ST_format("Accept", err, true))
		return
	end
	local id = nextID
	nextID = id + 1
	ST_sockets[id] = sock
	sock:add("received", function() ST_received(id) end)
	sock:add("error", function() ST_error(id) end)
	console:log(ST_format(id, "Connected"))
end

-- callbacks:add("keysRead", ST_scankeys)
callbacks:add("frame", ST_press_mask)

local port = 8888
server = nil
while not server do
	server, err = socket.bind("127.0.0.1", port)
	if err then
		if err == socket.ERRORS.ADDRESS_IN_USE then
			port = port + 1
		else
			console:error(ST_format("Bind", err, true))
			break
		end
	else
		local ok
		ok, err = server:listen()
		if err then
			server:close()
			console:error(ST_format("Listen", err, true))
		else
			console:log("Socket Server Test: Listening on port " .. port)
			server:add("received", ST_accept)
		end
	end
end