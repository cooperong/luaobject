
local Class=require "class"
local M={}
local G=_G
local errinfo="error:Permission denied!"
setfenv(1,M)

local Event=Class:create({readonly={
    fire=function(self,...)
		local isNotFound=true	
        for i,v in G.ipairs(self.handler) do
            v(self,...)
			isNotFound=false
        end
		if isNotFound then	G.error("the event's callback is not exist") end
    end,
    bind=function(self,handler)
        for i,v in G.ipairs(self.handler) do
            if self.handler[i]==handler then return end
        end
        G.table.insert(self.handler,handler)
    end,
    unbind=function(self,handler)
        for i,v in G.ipairs(self.handler) do
            if self.handler[i]==handler then G.table.remove(self.handler,i) end
        end
    end
  }
})
function new(self)
    local e=Event:new() or {}
    e.handler={}
	e.___prototype={}	--当子类继承父类事件对象时,是采用深度对象复制的方式,复制后,子类的事件对象与父类的事件对象是两个内存独立的对象
	G.getmetatable(e).__newindex=function(t,k,v) G.error(errinfo) end
    return e;
end
G.setmetatable(M,{__metatable=0,__newindex=function(t,k,v) G.error(errinfo) end})
return M;
