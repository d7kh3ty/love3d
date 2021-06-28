camera = {
    x = 10,
    y = 0,
    z = -1000,

    rx = 0,
    ry = 0,
    rz = 0,

    n = 50,
    f = 500,

    alpha = 0.1,
}

local x = 0
local y = 0
local z = 0

data ={
{
    {x-100,      y-100,   z+100},
    {x+100,      y-100,   z+100},
    {x+100,      y+100,   z+100},
    {x-100,      y+100,   z+100},
},
{
    {x-100,      y-100,   z-100},
    {x+100,      y-100,   z-100},
    {x+100,      y+100,   z-100},
    {x-100,      y+100,   z-100},
},
{
    {x+100,      y-100,   z+100},
    {x+100,      y+100,   z+100},
    {x+100,      y+100,   z-100},
    {x+100,      y-100,   z-100},
},
{
    {x-200,      y-100,   z+100},
    {x-200,      y+100,   z+100},
    {x-200,      y+100,   z-100},
    {x-200,      y-100,   z-100},
},
{
    {x-200,      y-100,   z+100},
    {x+200,      y-100,   z+100},
    {x+200,      y+100,   z+100},
    {x-200,      y+100,   z+100},
},
{
    {x-200,      y-100,   z-100},
    {x+200,      y-100,   z-100},
    {x+200,      y+100,   z-100},
    {x-200,      y+100,   z-100},
},
{
    {x+200,      y-100,   z+100},
    {x+200,      y+100,   z+100},
    {x+200,      y+100,   z-100},
    {x+200,      y-100,   z-100},
},
{
    {x-200,      y-100,   z+100},
    {x-200,      y+100,   z+100},
    {x-200,      y+100,   z-100},
    {x-200,      y-100,   z-100},
},
}

function Vector()
    local mt = {}
    local function add(a, b)
        local v = new_vector{}
        for l in pairs(a) do v[l] = a[l] + b[l] end
        return v
    end
    local function sub(a, b)
        local v = new_vector{}
        for l in pairs(a) do v[l] = a[l] - b[l] end
        return v
    end
    local function dot(a, b)
        local s = 0
        for l in pairs(a) do s = s + a[l] * b[l] end
        return s
    end
    local function scalar(a, b)
        local v = new_vector{}
        for l in pairs(b) do v[l] = b[l] * a end
        return v
    end
    mt.__mul = dot
    mt.__sub = sub
    mt.__add = add
    mt.__mod = scalar
    function new_vector(t)
        local v = {}
        setmetatable(v, mt)
        for l = 1,3 do v[l] = t[l] end
        return v
    end
    return {new_vector = new_vector}
end

function printmatrix(p)
    for i = 1,#p do
        io.write("|")
        for j = 1,#p[i] do
            if j ~= #p[i] then
                io.write(p[j][i], ",")
            else
                io.write(p[j][i])
            end
        end
        io.write("|\n")
    end
    io.write("-------\n")
end

function Matrix()
    local mt = {}
    local function mul(a, b)
        local m = new_matrix{}
        for l = 1,#a do
            m[l] = {}
            for n = 1,#b do
                x = 0
                for i = 1,#a do
                    x = x + a[i][n] * b[l][i]
                end
                m[l][n] = x
            end
        end
        return m
    end
    local function vec(a,b)
	local m = new_matrix{}
	for l = 1,#a do
	    x = 0
	    for n = 1,#a[l] do
		x = x + b[n] * a[n][l]
	    end
	    m[l] = x
	end
	return m
    end
    mt.__mul = mul
    mt.__mod = vec
    function new_matrix(t)
        local m = {}
        setmetatable(m, mt)
        for l = 1,#t do
            m[l] = {}
            for n = 1,#t[l] do
                m[l][n] = t[n][l]
            end
        end
        --printmatrix(m)
        return m
    end
    return {new_matrix = new_matrix}
end

