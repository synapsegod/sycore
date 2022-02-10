# sycore

To get started simply load sycore globals to your current stack

```lua
local sycore = loadfile("sycore\\Core.lua)()
```

To load a .lua file simply use the global Import function. 
Every file will only be loaded into sycore once, similar to require, unless the .lua file has no return value.

The global Package variable is the directory path for sycore ("sycore\\")

```lua
local Object = Import(Package.."OOP\\Object.lua")
```

## OOP
sycore has built in Object-Orientated support for scripting with classes.

The base Class for all Objects is the Object class. In the following example I will demonstrate how to create your own class.
For the following examples we will assume you have a variable Object referring to the Object class.

```lua
local MyClass = Object:Extend("MyClassName")

function MyClass:new(TestValue)
    local object = self._SUPER.new(self) --Object.new(self) works too
    object.TestValue = TestValue
    return object
end

local myObject = MyClass:new("Hello world")
print(myObject.TestValue) --Hello world
```

## Fields
By default all values inside a class/object are free to edit with no restrictions. When creating a new class you have the option to pass a table with  fields where the key corresponds to the key of the object.

### Read-only

A fields **read-only** property will be ignored when the value is nil. Inheriting classes/ objects are able to override the value if the field is not **final**.

### Final


If a field is **final** then all descending classes / objects will **not** be able to set a value with the field name.

```lua
local MyClass = Object:Extend("MyClassName", {
    TestValue = Object:NewField(true, true) --readonly, final
})

function MyClass:new(TestValue)
    local object = Object.new(self)
    object.TestValue = TestValue
    return object
end

local myObject = MyClass:new("Hello world")
myObject.TestValue = "Test" --throws assertion error
```

## Extending a class

Lets say you wanted to make a Vehicle class followed by a Car and Motorcycle class. Sycores OOP lets you do this without any tedious scripting.

To check if a class extends another class somehow, use :IsA(classname)

```lua
local Vehicle = Object:Extend("Vehicle", nil, true, false)

local Car = Vehicle:Extend("Car", {
    Wheels = Object:NewField(true, true)
}, false, false)
function Car:new(speed)
    local object = self._SUPER.new(self)
    object.Wheels = 4
    object.Speed = speed or 100

    return object
end

local Porsche = Car:Extend("Porsche")
function Porsche:new()
    return self._SUPER.new(300)
end
local myPorsche = Porsche:new()
```

### Abstract and Final

Classes can be set to **abstract** or **final** meaning you may not use :new() on a class or extend the class, respectively.

```lua
local Vehicle = Object:Extend("Vehicle", nil, false, false) --not abstract, not final
local Car = Vehicle:Extend("Vehicle") --assertion error
```
## Interfaces / Multi-inheritance
A class is able to inherit multiple classes at once, although technically this is not inheriting, it is more like copying a the values into the class/object.

To check if a class is implementing another class use :Inherits(classname).

**Multi-inheritance is not used often and can be avoided by creating another value  inside the class/object referring to another class.**

**The first implementation will be the dominant inheritance, only values not yet present/inherited in the class/object will be copied!**

**Methods such as Destroy might have to be rewritten for all Implementations for the new class**

**The implementing class will not inherit from implementations, instead it will inherit from the class it was extended from**

```lua
local Human = Object:Extend("Human", nil, true)

local Mom = Human:Extend("Mom")
function Mom:new() return Human.new(self) end

local Dad = Human:Extend("Dad")
function Dad:new() return Human.new(self) end

local Child = Human:Extend("Child"):Implements(Mom, Dad)
function Child:new()
    local child = Human.new(self)
    Mom.new(child)
    Dad.new(child)
    return child
end
```

## Events
Each class/object value can be hooked up to an event which fires whenever the value changes.

The value must be present when the event is hooked to it.

```lua
local object = Object:new()
object.Value = "Hello"

local event = object:GetPropertyChangedEvent("Value")
local connection = event:Connect(function()
    print("Value changed", object.Value)
end)

object.Value = "Goodbye"
```

## Object cleanup

The :Destroy() function disconnects all hooked events and removes internal references to the object.

```lua
local Car = Object:Extend()
function Car:new() return Object.new(self) end
function Car:Destroy()
    if self.Destroyed then return end
    Object.Destroy(self)
    --if the car has any custom clean ups they go here
end
local car = Car:new()
car:Destroy()
```

## Coding annotation/hints
Sycore has a built in documentation using EmmyAnnotation.
[EmmyLua](https://emmylua.github.io/)

This is the Visual Studio Code extension I use.
[Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
