-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
--<Summary> Here are some presets for you to get started with!
-- As a rule of thumb for shakes: Don't overdo it, and have minimal to no positional shake for 3D. Please refer to GG's video on creating good shakes for your experience.
--!strict

local KickShake = require(script.Parent.KickShake)
local BounceShake = require(script.Parent.BounceShake)
local PerlinShake = require(script.Parent.PerlinShake)
local Envelope = require(script.Parent.Envelope)
local Displacement = require(script.Parent.Displacement)

type KickShake = KickShake.KickShake
type PerlinShake = PerlinShake.PerlinShake
type BounceShake = BounceShake.BounceShake

local CameraShakePresets = {}

-- Suitable for short and snappy shakes in 2D. Moves camera in X and Y axes and rotates it in Z axis.
function CameraShakePresets.ShortShake2D(positionStrength: number?, rotationStrength: number?, freq: number?, numBounces: number?): BounceShake
	local pars = BounceShake.GetDefaultParams()
	pars.positionStrength = positionStrength or 0.08
	pars.rotationStrength = rotationStrength or 0.1
	pars.freq = freq or 25
	pars.numBounces = numBounces or 5

	return BounceShake.New(pars)
end

-- Suitable for longer and stronger shakes in 3D. Rotates camera in all three axes.
function CameraShakePresets.ShortShake3D(strength: number?, freq: number?, numBounces: number?): BounceShake
	local pars = BounceShake.GetDefaultParams()
	pars.axesMultiplier = Displacement.New(Vector3.zero, Vector3.new(1, 1, 0.4))
	pars.rotationStrength = strength or 0.3
	pars.freq = freq or 25
	pars.numBounces = numBounces or 5

	return BounceShake.New(pars)
end

-- Suitable for longer and stronger shakes in 2D. Moves camera in X and Y axes and rotates it in Z axis.
function CameraShakePresets.Explosion2D(positionStrength: number?, rotationStrength: number?, duration: number?): PerlinShake
	positionStrength = positionStrength or 1
	rotationStrength = rotationStrength or 3
	duration = duration or 0.5

	local modes = {
		{freq = 8, amplitude = 1},
		{freq = 20, amplitude = 0.3},
	}

	local envelopePars = Envelope.GetDefaultParams()
	envelopePars.decay = if duration <= 0 then 1 else 1 / duration

	local pars = PerlinShake.GetDefaultParams()
	pars.strength = Displacement.New(
		Vector3.new(1, 1, 0) * (positionStrength :: number),
		Vector3.new(0, 0, 1) * (rotationStrength :: number)
	)
	pars.noiseModes = modes
	pars.envelope = envelopePars

	return PerlinShake.New(pars)
end

-- Suitable for longer and stronger shakes in 3D. Rotates camera in all three axes.
function CameraShakePresets.Explosion3D(strength: number?, duration: number?, sourcePosition: Vector3?): PerlinShake
	duration = duration or 0.7

	local modes = {
		{freq = 6, amplitude = 1},
		{freq = 20, amplitude = 0.2},
	}

	local envelopePars = Envelope.GetDefaultParams()
	envelopePars.decay = if duration <= 0 then 1 else 1 / duration

	local pars = PerlinShake.GetDefaultParams()
	pars.strength = Displacement.New(
		Vector3.zero,
		Vector3.new(1, 1, 0.5) * (strength :: number)
	)
	pars.noiseModes = modes
	pars.envelope = envelopePars

	return PerlinShake.New(pars, nil, sourcePosition)
end

-- Suitable for gun recoil. Rotates camera in two axes: vertical, and horizontal.
function CameraShakePresets.GunFire3D(strength: {verticalStrength: number, horizontalStrength: number}?, duration: {attack: number, recover: number}?, forceEnabled: boolean?): KickShake
	local pars = KickShake.GetDefaultParams()
	
	local vertStrength = strength and strength.verticalStrength or 1
	local horStrength = strength and strength.horizontalStrength or 1

	local randomHorizontal = math.random(-100, 100) / 100 
	local randomVertical = math.random(70, 120) / 100

	local rotationalStrength = Vector3.new(
		vertStrength * randomVertical,       -- upwards
		horStrength * randomHorizontal,     -- left/right kick
		0
	)
	
	pars.strength = Displacement.New(Vector3.zero, rotationalStrength)
	pars.attackTime = duration and duration.attack or 0.1
	pars.releaseTime = duration and duration.recover or 0.6
	forceEnabled = forceEnabled or true
	
	return KickShake.New(pars, Displacement.New(Vector3.zero, Vector3.new(1,1,0)), forceEnabled) -- The displacement created here simply allows specific axes. Setting to 0 disables that axes entirely.
end

return CameraShakePresets
