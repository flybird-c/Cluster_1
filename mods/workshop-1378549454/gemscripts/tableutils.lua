--[[
Copyright (C) 2018-2020 Zarklord

This file is part of Gem Core.

The source code of this program is shared under the RECEX
SHARED SOURCE LICENSE (version 1.0).
The source code is shared for referrence and academic purposes
with the hope that people can read and learn from it. This is not
Free and Open Source software, and code is not redistributable
without permission of the author. Read the RECEX SHARED
SOURCE LICENSE for details
The source codes does not come with any warranty including
the implied warranty of merchandise.
You should have received a copy of the RECEX SHARED SOURCE
LICENSE in the form of a LICENSE file in the root of the source
directory. If not, please refer to
<https://raw.githubusercontent.com/Recex/Licenses/master/SharedSourceLicense/LICENSE.txt>
]]

function table.makeuniquei(t)
    local ut = {}
    local exists = {}
    for i, v in ipairs(t) do
        if not exists[v] then
            table.insert(ut, v)
            exists[v] = true
        end
    end
    return ut
end

function table.makeunique(t)
    local ut = {}
    local exists = {}
    for k, v in pairs(t) do
        if not exists[v] then
            ut[k] = v
            exists[v] = true
        end
    end
    return ut
end


local function default_sortfn(a, b) return a < b end
function stable_sort(t, sortfn)
    local n = #t
    local step = 1
    sortfn = sortfn or default_sortfn
    local t1, t2 = t, {}
    --t1 is sorted in buckets of size=step
    --t2 will be sorted in buckets of size=step*2
    while step < n do
        for i = 1, n, step*2 do
            --for each bucket of size=step, merge the results
            local pos, a, b = i, i, i + step
            local e1, e2 = b - 1, b + step - 1
            --e1 = end of first bucket, e2= end of second bucket
            if e1 >= n then
                --end of our array, just copy the sorted remainder
                while a <= e1 do
                    t2[a], a = t1[a], a + 1
                end
                break
            elseif
                e2 > n then e2 = n
            end
            --check if sorted already
            if sortfn(t1[e1], t1[b]) then
                --sorted, so let's just concat
                while a <= e2 do
                    t2[a], a = t1[a], a + 1
                end
            else
                --merge the buckets
                while true do
                    local va, vb = t1[a], t1[b]
                    if sortfn(vb, va) then
                        t2[pos] = vb
                        b = b + 1
                        if b > e2 then
                            --second bucket is done, append the remainder
                            pos = pos + 1
                            while a <= e1 do
                                t2[pos], a, pos = t1[a], a + 1, pos + 1
                            end
                            break
                        end
                    else
                        t2[pos] = va
                        a = a + 1
                        if a > e1 then
                            --first bucket is done, append the remainder
                            pos = pos + 1
                            while b <= e2 do
                                t2[pos], b, pos = t1[b], b + 1, pos + 1
                            end
                            break
                        end
                    end
                    pos = pos + 1
                end
            end
        end
        step = step * 2
        t1, t2 = t2, t1
    end
    --copy sorted result from temporary table to input table if needed
    if t1 ~= t then
        for i = 1, n do t[i] = t1[i] end
    end
    return t
end

rawnext = next
rawpairs = pairs
rawipairs = ipairs

function next(t, k, ...)
    local m = debug.getmetatable(t)
    local n = m and m.__next or rawnext
    return n(t, k, ...)
end

function pairs(t, ...)
    local m = debug.getmetatable(t)
    local p = m and m.__pairs or rawpairs
    return p(t, ...)
end

function ipairs(t, ...)
    local m = debug.getmetatable(t)
    local i = m and m.__ipairs or rawipairs
    return i(t, ...)
end

metanext = next
metapairs = pairs
metaipairs = ipairs

gemrun("hidefn", next, rawnext)
gemrun("hidefn", pairs, rawpairs)
gemrun("hidefn", ipairs, rawipairs)

require("metaclass")

local metafunctions = UpvalueHacker.GetUpvalue(MetaClass, "metafunctions")
metafunctions.__iterator = function(t, ...)
    return metarawget(t, "__iterator")(t, ...)
end

function iterator(t, ...)
    local m = debug.getmetatable(t)
    local i = m and m.__iterator
    if not i then
        print("table t: "..t.." didn't have an __iterator metamethod!")
        print(debugstack())
        i = function() return nil end
    end
    return i(t, ...)
end

function upvaluenext(t, index)
    index = index + 1
    local n, v = debug.getupvalue(t, index)
    if n then
        return index, n, v
    end
end

function upvaluepairs(t)
    return upvaluenext, t, 0
end

function multipairs(...)
    local t_list = {...}
    return coroutine.wrap(function()
        for _, t in rawpairs(t_list) do
            for k, v in pairs(t) do
                coroutine.yield(k, v)
            end
        end
    end)
end

function multiipairs(...)
    local t_list = {...}
    return coroutine.wrap(function()
        for _, t in rawipairs(t_list) do
            for i, v in ipairs(t) do
                coroutine.yield(i, v)
            end
        end
    end)
end

function ipairs_circular(t, count)
    return function(t, index)
        index = index + 1
        if index > count then return end
        return index, circular_index(t, index)
    end, t, 0
end

function table.findarrayindex(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

local LUA_REGISTRY = debug.getregistry()
function UpdateRegistry(old_value, new_value)
    for key, value in pairs(LUA_REGISTRY) do
        if value == old_value then
            LUA_REGISTRY[key] = new_value
        end
    end
end

Queue = Class(function(self, entries)
    local _head = -1
    local _tail = 0
    local _queue = {}

    local function Reset(self)
        _head = -1
        _tail = 0
    end

    function self:Size()
        return math.abs((_head + 1) - _tail)
    end

    function self:Push(v)
        _head = _head + 1
        _queue[_head] = v
    end

    self.Push_Front = self.Push

    function self:Push_Back(v)
        _tail = _tail - 1
        _queue[_tail] = v
    end

    function self:Pop()
        if self:IsEmpty() then return nil end
        local r = _queue[_tail]
        _queue[_tail] = nil
        _tail = _tail + 1
        if self:IsEmpty() then Reset(self) end
        return r
    end

    self.Pop_Back = self.Pop

    function self:Pop_Front()
        if self:IsEmpty() then return nil end
        local r = _queue[_head]
        _queue[_head] = nil
        _head = _head - 1
        if self:IsEmpty() then Reset(self) end
        return r
    end

    function self:Peek()
        return _queue[_tail]
    end

    self.Peek_Back = self.Peek

    function self:Peek_Front()
        return _queue[_head]
    end

    function self:Contents()
        return function()
            --the first value determines whether or not to stop the for loop, since nil is a valid value to return for self:Pop_Back() we do a IsEmpty check
            return not self:IsEmpty() and true or nil, self:Pop_Back()
        end, self, nil
    end

    function self:RContents()
        return function()
            --the first value determines whether or not to stop the for loop, since nil is a valid value to return for self:Pop_Front() we do a IsEmpty check
            return not self:IsEmpty() and true or nil, self:Pop_Front()
        end, self, nil
    end

    function self:IsEmpty()
        return self:Size() == 0
    end

    function self:Clear()
        _queue = {}
        Reset(self)
    end

    for i, v in ipairs(type(entries) == "table" and entries or {}) do
        self:Push_Back(v)
    end
end)

function Queue:__iterator(reverse)
    if reverse then
        return self:Contents()
    else
        return self:RContents()
    end
end

NodeLink = Class(function(self, data)
    self.data = {}
    self.prev = nil
    self.next = nil
end)

function NodeLink:Data()
    return self.data
end

function NodeLink:Destroy()
    self.prev = nil
    self.next = nil
end

function NodeLink:__index(k)
    return self.data[k]
end

function NodeLink:__newindex(k, v)
    self.data[k] = v
end

DoubleLinkedList = MetaClass(function(self, start_data, node_type, no_memory_management)
    local node_class = node_type or NodeLink
    local first = nil
    local last = nil
    local length = 0

    function self:InsertNode(node_to_insert, insert_before, ...)
        insert_before = node_to_insert ~= nil and insert_before or nil
        node_to_insert = node_to_insert or last
        local node = node_class(...)
        if node_to_insert then
            if insert_before then
                node.next = node_to_insert
                node.prev = node_to_insert.prev
                node_to_insert.prev.next = node
                node_to_insert.prev = node

                if node_to_insert == first then
                    first = node
                end
            else
                node.next = node_to_insert.next
                node.prev = node_to_insert
                node_to_insert.next.prev = node
                node_to_insert.next = node
                if node_to_insert == last then
                    last = node
                end
            end
        else
            first = node
            last = node

            node.prev = node
            node.next = node
        end
        length = length + 1
    end

    function self:RemoveNode(node)
        node = node or last
        if not node then return end
        if last == first then
            --this was the only node
            first = nil
            last = nil
        else
            if node == last then
                last = node.prev
            elseif node == first then
                first = node.next
            end
            node.next.prev = node.prev
            node.prev.next = node.next
        end
        node:Destroy()

        length = length - 1
        return node
    end

    function self:First()
        return first
    end

    function self:Last()
        return last
    end

    function self:__len()
        return length
    end

    function self:ForwardIterator(current)
        if current and current.next == first then return end
        current = current and current.next or first
        return current
    end

    function self:BackwardIterator(current)
        if current and current.prev == last then return end
        current = current and current.prev or last
        return current
    end

    if not no_memory_management then
        function self:__gc()
            local n = first
            if n then
                repeat
                    local _n = n.next
                    n:Destroy()
                    if not _n then
                        break
                    end
                    n = _n
                until n == first
            end
            first = nil
            last = nil
        end
    end

    if start_data then
        for _, v in ipairs(start_data) do
            self:InsertNode(v)
        end
    end
end)

function DoubleLinkedList:__iterator(reverse)
    if not reverse then
        return self:ForwardIterator()
    else
        return self:BackwardIterator()
    end
end