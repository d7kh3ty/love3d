
require("data")

local clock = os.clock
function sleep(n)
	local t = clock()
	while clock() - t <= n / 1000 do end
end

local function obj(file)
	-- a table of vertices
	local faces = {}
	obj = io.open(file, "r")
	vertices 	= {}
	for line in obj:lines() do
		local temp = {}
		for str in string.gmatch(line, "([^".."%s".."]+)") do
			table.insert(temp, str)
		end

		if temp[1] == "v" then
			v = {}
			for i = 2,#temp do
				table.insert(v, tonumber(temp[i])*50)
			end
			table.insert(vertices, v)
		end
		if temp[1] == "f" then
			v = {}
			for i = 2,#temp do
				table.insert(v, tonumber(temp[i]))
			end
			table.insert(faces, v)
		end
	--print("t: ",#faces)
	-- 6320
	--print("v: ", #vertices)
	end
	return faces, vertices
end


function love.load()
	love.mouse.setPosition(love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5)
	faces, vertices = obj("teapot.obj")
end


local vector = Vector()
local matrix = Matrix()

function projection(t)
	p = {}
	for i = 1,#t do
		local cot = 1/math.tan(math.rad(camera.alpha)/2)
		table.insert(p, -(t[i][1]*cot)/t[i][3] + 400)
		table.insert(p, -(t[i][2]*cot)/t[i][3] + 300)
	end
	return p
end


function clipping(t)
	local n = vector.new_vector{0, 0, 1}			-- normal vector
	local P = vector.new_vector{0, 0, camera.n + camera.z}	-- point on near plane
	-- NEEDS IMPROVEMENT !!!

	-- if n * (Q - P) > 0, Q is in
	-- if n * (Q - P) < 0, Q is out
	-- if n * (Q - P) = 0, Q is on

	-- this function is a mess, im sorry
	table_out = {}
	table_in = {}
	for i = 1,#t do
		local Q = vector.new_vector(t[i])
		d = n * (Q - P)
		t[i][4] = d
		t[#t][4] = n * (vector.new_vector(t[#t]) - P)
		if i ~= 1 then
			ti = t[i-1][4] / (t[i-1][4] - t[i][4])
			Q1 = vector.new_vector(t[i-1])
			I = Q1 + ti%(Q - Q1)
		elseif i == 1 then
			ti = t[#t][4] / (t[#t][4] - t[i][4])
			Q1 = vector.new_vector(t[#t])
			I = Q1 + ti%(Q - Q1)
		end
		if d < 0 then           -- OUT
			table.insert(table_out, t[i])
			t[i][5] = false
			if i ~= 1 and t[i-1][5] == true then
				table.insert(table_in, I)
			elseif i == 1 and t[#t][5] == true then
				table.insert(table_in, I)
			end
		elseif d > 0 then       -- IN
			table.insert(table_in, t[i])
			t[i][5] = true
			if i ~= 1 and t[i-1][5] == false then
				table.insert(table_in, I)
			elseif i == 1 and t[#t][5] == false then
				table.insert(table_in, I)
			end
		end
	end
	return table_in
end


function rotation(t)
	Ry = matrix.new_matrix{ {math.cos(camera.ry),	0,	math.sin(camera.ry)},
	{0,				1,	0},
	{-math.sin(camera.ry),	0,	math.cos(camera.ry)}}

	Rx = matrix.new_matrix{ {1,		0,			0},
	{0, 	math.cos(camera.rx),	-math.sin(camera.rx)},
	{0,		math.sin(camera.rx),	math.cos(camera.rx)}}

	rotated = {}
	for i = 1,#t do
		p = {}
		p[1] = t[i][1] - camera.x
		p[2] = t[i][2] - camera.y
		p[3] = t[i][3] - camera.z
		table.insert(rotated, Rx*Ry%p)
	end
	return rotated
end


esc = false
function love.keypressed(key, scancode, isrepeat)
	if key == "escape" and esc == false then
		esc = true
	elseif key == "escape" and esc == true then
		esc = false
		love.mouse.setPosition(love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5)
	end
end


function love.update(dt)

	mouse_x = love.mouse.getX()
	mouse_y = love.mouse.getY()

	if esc == false and love.window.hasFocus() == true then
		love.mouse.setVisible(false)
		love.mouse.setPosition(love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5)
		camera.ry = camera.ry + (mouse_x - 400)/400
		camera.rx = camera.rx - (mouse_y - 300)/400
	else
		love.mouse.setVisible(true)
	end

	if love.keyboard.isDown("e") then
		camera.alpha = camera.alpha + 0.01
		print("α: ", camera.rz)
	elseif love.keyboard.isDown("q") then
		camera.alpha = camera.alpha - 0.01
		print("α: ", camera.rz)
	end

	if love.keyboard.isDown("left") then
		camera.x = camera.x + 4
		print("x: ", camera.x)
	elseif love.keyboard.isDown("right")  then
		camera.x = camera.x - 4
		print("x: ", camera.x)
	end
	if love.keyboard.isDown("up") then
		camera.y = camera.y + 1
		print("y: ", camera.y)
	elseif love.keyboard.isDown("down")  then
		camera.y = camera.y - 1
		print("y: ", camera.y)
	end

	local function move(theta)
		camera.z = camera.z + 10*math.cos(theta)
		camera.x = camera.x - 10*math.sin(theta)
	end
	if love.keyboard.isDown("w") then
		if love.keyboard.isDown("a") then
			move(camera.ry - math.pi/4)
		elseif love.keyboard.isDown("d") then
			move(camera.ry + math.pi/4)
		else
			move(camera.ry)
		end
	elseif love.keyboard.isDown("s") then
		if love.keyboard.isDown("a") then
			move(camera.ry - 3*math.pi/4)
		elseif love.keyboard.isDown("d") then
			move(camera.ry + 3*math.pi/4)
		else
			move(camera.ry + math.pi)
		end
	elseif love.keyboard.isDown("d")  then
		move(camera.ry + math.pi/2)
	elseif love.keyboard.isDown("a")  then
		move(camera.ry - math.pi/2)
	end

	polygons = {}
	for i = 1,#faces do
		local t = {}
		t[1] = vertices[faces[i][1]]
		t[2] = vertices[faces[i][2]]
		t[3] = vertices[faces[i][3]]
		--print(#vertices)
		--print(t[1], t[2], t[3])
		table.insert(polygons, projection(clipping(rotation(t))))
	end
end


function love.draw()
	love.graphics.setBackgroundColor(40/255, 40/255, 40/255)
	love.graphics.setColor(200/255, 200/255, 200/255)
	for i = 1,#polygons do
		print(i, " / 6320")
		if #polygons[i] >= 6 then
			love.graphics.polygon('line', polygons[i])
		end
	end
end

