--[[
所有类的系统基类
]]--
local M={}
local G=_G
local errinfo="error:Permission denied!"
setfenv(1,M)
local function deepcopy(orig)   --对象的深度复制
    local orig_type = G.type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in G.next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        G.setmetatable(copy, deepcopy(G.getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function create(self)
    local Class={}
    --Class.inherit={}
    Class.readonly={
        copy=function(self)
            local ret=deepcopy(self)
            G.getmetatable(ret).__newindex=function(t,k,v) --不加这个元方法则无法给复制出来的对象新增元素
                G.rawset(t,k,v)
            end
            ret.___prototype=self
            return ret
        end
    }
    --Class.override= {}
    --Class.event={}
    --Class.objectpool={}
    Class.new=function(self)
        local o={super={},event={}}
        o.release=function(self)
            for i,v in G.ipairs(self.event) do
                G.table.remove(self.event,i)
            end
            for k,v in G.pairs(self) do
                self[k]=nil
            end
            self=nil
        end
        G.setmetatable(o,{
            __index=function(t,k)
                return self.readonly[k]
            end,
            __newindex=function(t,k,v)
                if self.readonly[k] then
                    G.error("error:can not set "..k..",it's object's!")
                end
            end
        })
        return o
    end
    G.setmetatable(Class,{__metatable=0,__newindex=function(t,k,v) G.error(errinfo) end})
    return Class
end
G.setmetatable(M,{__metatable=0,__newindex=function(t,k,v) G.error(errinfo) end})
return M
