local tblx = {}

---@param obj1 any
---@param obj2 any
---@return boolean
local function isEqual(obj1, obj2)
    return obj1 == obj2
end

---@param t table
function tblx.clear(t)
    for k in pairs(t) do t[k] = nil end
end

---@param t table
---@return boolean
function tblx.any(t)
    return next(t) ~= nil
end

---@param t table
---@return integer
function tblx.count(t)
    local i, k = 0, next(t)
    while k do
        i = i + 1
        k = next(t, k)
    end
    return i
end

---@param t table
---@param value any
---@return boolean
function tblx.include(t, value)
    local pred = (type(value) == 'function') and value or isEqual
    for _, v in pairs(t) do
        if pred(v, value) then return true end
    end
    return false
end

return tblx
