-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
-- <Summary> Representation of translation and rotation. 
--!strict

local random = Random.new()
local Displacement = {}
Displacement.__index = Displacement

export type Displacement = typeof(
	setmetatable({} :: { position: Vector3, eulerAngles: Vector3 }, Displacement)
)

-- Returns Unity's Random.insideUnitSphere.
local function getRandomInsideUnitSphere(): Vector3
	local unitVector = random:NextUnitVector()
	
	local radius = random:NextNumber() 
	return unitVector * radius
end

-- Creates a new displacement instance.
function Displacement.New(position: Vector3, eulerAngles: Vector3): Displacement
	local self = setmetatable({}, Displacement)
	
	self.position = position
	self.eulerAngles = eulerAngles or Vector3.zero
	
	return self
end

-- Creates a new displacement instance with Vector3.zero.
function Displacement.Zero(): Displacement
	return Displacement.New(Vector3.zero, Vector3.zero)
end

-- The following are metatable what nots that allow you to add, subtract, yada yada for displacement.

function Displacement.__add(a: Displacement, b: Displacement): Displacement
	return Displacement.New(a.position + b.position,
		b.eulerAngles + a.eulerAngles)
end

function Displacement.__sub(a: Displacement, b: Displacement)
	return Displacement.New(a.position - b.position,
		b.eulerAngles - a.eulerAngles
	)
end

function Displacement.__unm(disp: Displacement): Displacement
	return Displacement.New(-disp.position,
		-disp.eulerAngles
	)
end

function Displacement.__mul(a: Displacement | number, b: Displacement | number): Displacement
	local coords = (type(a) == "table" and a or b) :: Displacement
	local number = (type(a) == "number" and a or b) :: number
	
	return Displacement.New(coords.position * number,
		coords.eulerAngles * number
	)
end

function Displacement.__div(coords: Displacement, number: number): Displacement
	
	return Displacement.New(coords.position / number,
		coords.eulerAngles / number)
end

-- Multiplies two displacements together.
function Displacement.Scale(a: Displacement, b: Displacement): Displacement
	return Displacement.New(a.position * b.position,
		b.eulerAngles * a.eulerAngles
	)
end

-- Lerps a displacement.
function Displacement.Lerp(a: Displacement, b: Displacement, t: number): Displacement
	return Displacement.New(a.position:Lerp(b.position, t),
		a.eulerAngles:Lerp(b.eulerAngles, t)
	)
end

-- Scales a displacement's position and rotation.
function Displacement.ScaledBy(self: Displacement, posScale: number, rotScale: number): Displacement
	return Displacement.New(self.position * posScale, self.eulerAngles * rotScale)
end

-- Normalizes a displacement with rot/pos magnitudes of 1. (.Unit)
function Displacement.Normalized(self: Displacement): Displacement
	local posUnit = if self.position.Magnitude > 0 then self.position.Unit else Vector3.zero
	local rotUnit = if self.eulerAngles.Magnitude > 0 then self.eulerAngles.Unit else Vector3.zero
	
	return Displacement.New(posUnit, rotUnit)
end

-- Creates a new displacement with Unity's Random.insideUnitSphere.
function Displacement.InsideUnitSpheres()
	return Displacement.New(getRandomInsideUnitSphere(), getRandomInsideUnitSphere())
end

return Displacement
