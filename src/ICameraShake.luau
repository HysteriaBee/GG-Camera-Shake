-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
-- <Summary> Contains methods for changing strength and direction of shakes depending on their position.
--!strict

local Displacement = require(script.Parent.Displacement)

export type ICameraShake = {
	-- Represents current position and rotation of the camera according to the shake.
	CurrentDisplacement: Displacement.Displacement,
	
	-- Shake system will dispose the shake on the first frame when this is true.
	IsFinished: boolean,
	
	-- CameraShaker calls this when the shake is added to the list of active shakes.
	Initialize: (self: any, cameraCFrame: CFrame) -> (),
	
	-- CameraShaker calls this every frame on active shakes.
	Update: (self: any, deltaTime: number, cameraCFrame: CFrame) -> (),
	
	-- Bypasses IsEnabled = false for the camera shaker.
	ForceEnabled: boolean?,
}

return nil
