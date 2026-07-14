-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
-- <Summary> Contains methods for changing strength and direction of shakes depending on their position.
--!strict

local Power = require(script.Parent.Power)
local Displacement = require(script.Parent.Displacement)

type Displacement = Displacement.Displacement

local Attenuator = {}

export type StrengthAttenuationParams = {
	clippingDistance: number, -- Radius in which shake doesn't lose strength.
	falloffScale: number, -- Defines how fast strength falls with distance.
	falloffDegree: number, -- Power of the falloff function.
	axesMultiplier: Vector3, -- Contribution of each axis to distance. E. g. (1, 1, 0) for a 2D game in XY plane.
}

-- Returns default parameters.
function Attenuator.GetDefaultParams(): StrengthAttenuationParams
	return {
		clippingDistance = 10,
		falloffScale = 50,
		falloffDegree = 2,
		axesMultiplier = Vector3.one,
	}
end

-- Returns multiplier for the strength of a shake, based on source and camera positions.
function Attenuator.Strength(pars: StrengthAttenuationParams, sourcePosition: Vector3, cameraPosition: Vector3): number
	local vec = cameraPosition - sourcePosition
	local distance = (pars.axesMultiplier * vec).Magnitude
	local strength = math.clamp(1 - (distance - pars.clippingDistance) / pars.falloffScale, 0, 1)
	
	return Power.Evaluate(strength, pars.falloffDegree)
end

-- Returns displacement, opposite to the direction to the source in camera's local space.
function Attenuator.Direction(sourcePosition: Vector3, cameraCFrame: CFrame): Displacement
	local cameraPosition = cameraCFrame.Position
	
	local direction = Displacement.Zero()
	local worldDir = (cameraPosition - sourcePosition).Unit
	local localDir = cameraCFrame:VectorToObjectSpace(worldDir)

	direction.position = localDir
	direction.eulerAngles = Vector3.new(localDir.Z, localDir.X, -localDir.X)
	
	return direction
end

return Attenuator
