#luaobject
###Description
A lua package for object-oriented programming, supports the following properties:<br>
1.Class includes  read-only elements and read-write elements,read-only elements can not be overridden(include sub class),read-write elements can be overridden(include sub class).<br>
2.Class supports multiple inheritance,A class can also inherit class1 and class2,access the parent class through the super[index],the read-write elements of parent class can be overridden from  sub class.<br>
3.Support inheritance chain(A inherit B,B inherit C,C inherit D,and so on).<br>
4.Support objects batch release,if object1,object2,object3 inherit Class1,release Class1,will release object1,object2,object3 automatic.<br>
5.Support single object element definition.<br>
6.Support bind event, event can be inherited.<br>
7.Support multicast event handler,handler can have a different number of parameters(the first parameter is always sender).<br>
8.Not support cross inheritance.<br>

###Example
####example 1
Define a Person class and create the object, print the variable id, and then release the object
#####methon 1
```lua
local Person=Class:create()    --declara class
Person.inherit={Object}     --inherit Object
Person.readonly={id=1,tostring=function(s) print(s) end}      read-only element,can not be override,can be inherited
Person.override={name="person",getvalue=function(v) return v end}   --can be override,can be inherited
person=Person:new()
print(person.id)
person:release()
```
#####methon2
```lua
local Person=Class:create({inherit={Object},readonly={id=1},override={name="person"}})
person=Person:new()
print(person.id)
person:release()
```
####example 2
Release all objects that be generated from Person
```lua
local Person=Class:create()
Person.inherit={Object}
Person.readonly={id=1,tostring=function(s) print(s) end}
Person.override={name="person",getvalue=function(v) return v end}
person1=Person:new()
person2=Person:new()
person3=Person:new()
Person:abandon()
```
####example 3
Access parent class elements
```lua
local Person=Class:create()
Person.inherit={Object}
Person.readonly={id=1,tostring=function(s) print(s) end}
Person.override={name="person",getvalue=function(v) return v end}
person=Person:new()
print(person.super.id) 
```
####example 4
Access to the parent element by index
```lua
local Person=Class:create()
Person.inherit={Object1,Object2}
Person.readonly={id=1,tostring=function(s) print(s) end}
Person.override={name="person",getvalue=function(v) return v end}
person=Person:new()
person.super[2].tostring()
```
####example 5
Define the event, binding event handler, and trigger events
```lua
local Person=Class:create()
local Event=require "event"
print_event=Event:new()
Person.event={print_event}
function p(sender,args) 
    print(args) 
end
person=Person:new()
person.event(print_event):bind(p)
person.event(print_event):fire(2)
```
####example 6
Define the object event, binding event handler, and trigger events
```lua
local Person=Class:create()
local Event=require "event"
print_event=Event:new()
function p(sender,args) --the first parameter is always sender
    print(args) 
end
person=Person:new()
person.event:register(print_event)
person.event(print_event):bind(p)
person.event(print_event):fire(2)
```
####example 7
multicast event handler
```lua
local Person=Class:create()
local Event=require "event"
print_event=Event:new()
function p1(sender,args1) 
    print(args2) 
end
function p2(sender,args1,args2) 
    print(args1,args2) 
end
person=Person:new()
person.event:register(print_event)
person.event(print_event):bind(p1)
person.event(print_event):bind(p2)
person.event(print_event):fire(2)
person.event(print_event):fire(1,2)
```
####example 8
event can be inherited
```lua
local Class=require "class"
local Event=require "event"
local Person=Class:create()
print_event=Event:new()
Person.event={print_event}
local Man=Class:create({inherit={Person}})	--man inherit Person,so inherit print_event
function p(sender,args) 
    print(sender,args) 
end
person=Person:new()
man=Man:new();
person.event(print_event):bind(p)
man.event(print_event):bind(p)
person.event(print_event):fire(1)
man.event(print_event):fire(2)
```
out:<br>
table: 0x4037a060	1	result of the person<br>
table: 0x4036cd40	2	result of the man<br>
You can see the two event sender points to a different event object.<br>

###Api
Class.inherit={parent class}<br>
Class.readonly={read-only elements}<br>
Class.override={read-write elements}<br>
Class.event={events} <br>
Class:create([inherit],[readonly],[override],[event])	create Class<br>
Class-->NewClass<br>
NewClass:new()	create object<br>
NewClass:abandon()	release all object<br>
Class-->object<br>
object:register(event)	register the object event<br>
object:remove(event)	remove the object event<br>
object:release()	release this object<br>
object:copy()	deep copy object<br>
object.event(event):bind(handler)	event bind handler<br>
object.event(event):unbind(handler)	event unbind handler<br>
object.event(event):fire(sender,args)	fire event<br>

