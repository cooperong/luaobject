local Object=require "object"
local M={}
local G=_G
local errinfo="error:Permission denied!"
setfenv(1,M)

function create(self,c)
    local Class=c or {}    
    Class.inherit=Class.inherit or {}   --父类表
    G.table.insert(Class.inherit,1,Object:create())    --自动插入Object类,Object类是所有类的系统基类
    Class.readonly=Class.readonly or {} --只读元素表
    Class.override=Class.override or {} --可读写元素表
    Class.event=Class.event or {}   --事件表
    Class.objectpool={} --对象池,存放所有生成的对象,主要用户后期资源释放
    Class.new=Class.new or function(self)
            local o={super={},event={
                register=function(self,event)   --注册事件
                    for i,v in G.ipairs(self) do
                        if self[i]==event then return end
                    end
                    G.table.insert(self,event)
                end,
                remove=function(self,event) --移除事件
                    for i,v in G.ipairs(self) do
                        if self[i]==event then G.table.remove(self,i) end
                    end
                end
            }}  
            self.objectpool[#self.objectpool+1]=o
            if self.inherit then    --继承父类事件
                for i,v in G.ipairs(self.inherit) do
                    --o.super[i]=v:new()
                    G.rawset(o.super,i,v:new())
                    if v.event then
                        for _i,_v in G.ipairs(v.event) do
                            o.event[_i]=o.event[_i] or _v:copy()
                        end
                    end
                end
            end
            for k,v in G.pairs(self.override) do  --继承父类可读写元素
                G.rawset(o,k,v)
            end
            for i,v in G.ipairs(self.event) do    --把类事件复制为对象事件
                o.event[i]=o.event[i] or v
            end
            o.release=function(self)    --对象释放
                for i,v in G.ipairs(self.super) do
                    self.super[i]:release()
                end
                for i,v in G.ipairs(self.event) do
                    G.table.remove(self.event,i)
                end
                for k,v in G.pairs(self) do
                    self[k]=nil
                end
                for i,v in G.ipairs(Class.objectpool) do
                    if self==v then G.table.remove(Class.objectpool,i) end
                end
                self=nil
            end           
            G.setmetatable(o,{
                __index=function(t,k)
                    local ret=self.readonly[k];
                    if not ret then
                        for i,v in G.ipairs(o.super) do
                            if o.super[i][k] then ret=o.super[i][k] break end
                        end
                    end
                    return ret
                end,
                __newindex=function(t,k,v)
                    if self.readonly[k] then
                        G.error("error:can not set "..k..",it's readonly!")
                    elseif #o.super>0 then
                        for i,e in G.ipairs(o.super) do
                            if o.super[i][k] then 
                                o.super[i][k]=v 
                                break 
                            elseif #o.super==i then
                                G.rawset(o,k,v)
                            end
                        end
                    else
                        G.rawset(o,k,v)
                    end
                end
            })

            G.setmetatable(o.super,{    --禁止对o.super直接写入  
                __newindex=function(t,k,v) 
                        G.error(errinfo) 
                end
            })
            G.setmetatable(o.event,{ --判断是执行类事件预定义函数还是返回自定义事件对象
                __call=function(f,...)
                    if G.type(f)=="function" then --执行类事件预定义函数,比如person.event:register(button_event)
                        return f(...)
                    else    --返回自定义事件对象,比如person.event(print_event):bind(p),其中person.event(print_event)部分返回的是自定义事件对象,bind是这个事件对象的预定义函数
                        for i,v in G.ipairs(f) do 
                            if f[i]==... or f[i].___prototype==... then return f[i] end --子类的事件对象是由父类事件对象复制来的,是独立的对象,不是引用关系,因此在识别事件对象时使用___prototype方法来返回被复制的源事件对象
                        end
                        G.error("the event is not exist")
                    end
                end,
                __newindex=function(t,k,v) 
                        G.error(errinfo) 
                end
            })           
            return o
    end
    Class.abandon=function(self)
        for i,v in G.ipairs(self.objectpool) do
            self.objectpool[i]:release()
        end
        for k,v in G.pairs(self.readonly) do
            self.readonly[k]=nil
        end
        for k,v in G.pairs(self.override) do
            self.override[k]=nil
        end
        for i,v in G.ipairs(self.event) do
            G.table.remove(self.event,i)
        end
        for k,v in G.pairs(self) do
            self[k]=nil
        end
        self=nil
    end
    G.setmetatable(Class,{__metatable=0,__newindex=function(t,k,v) G.error(errinfo) end})
    return Class
end
G.setmetatable(M,{__metatable=0,__newindex=function(t,k,v) G.error(errinfo) end})
return M
