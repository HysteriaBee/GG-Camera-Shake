-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
--!strict

local ICameraShake = require(script.Parent.ICameraShake)
local Envelope = require(script.Parent.Envelope)
local Attenuator = require(script.Parent.Attenuator)
local Displacement = require(script.Parent.Displacement)

type StrengthAttenuationParams = Attenuator.StrengthAttenuationParams
type Displacement = Displacement.Displacement
type ICameraShake = ICameraShake.ICameraShake
type Envelope = Envelope.Envelope

local random = Random.new()

export type NoiseMode = {
	freq: number,
	amplitude: number,
}

export type Params = {
	strength: Displacement, -- Strength of the shake for each axis.
	noiseModes: {NoiseMode}, -- Layers of perlin noise with different frequencies.
	envelope: Envelope.EnvelopeParams, -- Strength over time.
	attenuation: StrengthAttenuationParams, -- How strength falls with distance from the shake source.
}

local PerlinShake = {}
PerlinShake.__index = PerlinShake

export type PerlinShake = {
	CurrentDisplacement: Displacement,
	AmplitudeController: Envelope,
	ForceEnabled: boolean?,
	IsFinished: boolean,
	pars: Params,
	envelope: Envelope,
	seeds: {Vector2},
	sourcePosition: Vector3?,
	time: number,
	norm: number,
} & typeof(PerlinShake) & ICameraShake

-- Returns Unity's Random.insideUnitCircle.
local function getRandomInsideUnitCircle(): Vector2
	local angle = random:NextNumber() * 2 * math.pi
	local radius = math.sqrt(random:NextNumber())

	return Vector2.new(math.cos(angle) * radius, math.sin(angle) * radius)
end

-- Returns 2 dimensional perlin using Luau's math.noise with z set to 0.
local function perlin01(x: number, y: number): number
	return (math.noise(x, y) + 1) / 2
end

-- Returns default parameters.
function PerlinShake.GetDefaultParams(): Params
	return {
		strength = Displacement.New(Vector3.zero, Vector3.new(2, 2, 0.8)),
		noiseModes = {
			{freq = 12, amplitude = 1}
		},
		envelope = Envelope.GetDefaultParams(),
		attenuation = Attenuator.GetDefaultParams(),
	}
end

-- Creates a new PerlinShake instance.
function PerlinShake.New(parameters: Params?, maxAmplitude: number?, sourcePosition: Vector3?, manualStrengthControl: boolean?, forceEnabled: boolean?): PerlinShake
	local self = setmetatable({}, PerlinShake) :: PerlinShake
	
	local controlMode = (manualStrengthControl and "Manual" or "Auto")
	self.pars = parameters or PerlinShake.GetDefaultParams()
	self.envelope = Envelope.New(self.pars.envelope, maxAmplitude or 1, controlMode :: Envelope.EnvelopeControlMode)
	self.CurrentDisplacement = Displacement.Zero()
	self.AmplitudeController = self.envelope
	self.sourcePosition = sourcePosition
	self.ForceEnabled = forceEnabled
	self.time = 0
	
	return self
end

-- Initializes a PerlinShake instance.
function PerlinShake.Initialize(self: PerlinShake, cameraPosition: Vector3)
	self.seeds = {}
	self.norm = 0

	for i = 1, #self.pars.noiseModes do
		self.seeds[i] = getRandomInsideUnitCircle() * 20
		self.norm += self.pars.noiseModes[i].amplitude
	end
end

-- Updates a PerlinShake instance.
function PerlinShake.Update(self: PerlinShake, deltaTime: number, cameraCFrame: CFrame)
	if self.envelope:IsFinished() then
		self.IsFinished = true
		return
	end
	
	self.time += deltaTime
	self.envelope:Update(deltaTime)
	
	local disp = Displacement.Zero()
	
	for i = 1, #self.pars.noiseModes do
		disp += self.pars.noiseModes[i].amplitude / self.norm * self:SampleNoise(self.seeds[i], self.pars.noiseModes[i].freq)
	end
	
	self.CurrentDisplacement = self.envelope.Intensity * Displacement.Scale(disp, self.pars.strength)
	local sourcePosition = self.sourcePosition
	
	if sourcePosition then
		self.CurrentDisplacement *= Attenuator.Strength(self.pars.attenuation, sourcePosition, cameraCFrame.Position)
	end
end

-- Returns a displacement created via perlin noise.
function PerlinShake.SampleNoise(self: PerlinShake,seed: Vector2, freq: number): Displacement
	local selfTime = self.time
	
	local position = Vector3.new(
		perlin01(seed.X + selfTime * freq, seed.Y),
		perlin01(seed.X, seed.Y + selfTime * freq),
		perlin01(seed.X + selfTime * freq, seed.Y + selfTime * freq)
	)
	position -= Vector3.one * 0.5

	local rotation = Vector3.new(
		perlin01(-seed.X - selfTime * freq, -seed.Y),
		perlin01(-seed.X, -seed.Y - selfTime * freq),
		perlin01(-seed.X - selfTime * freq, -seed.Y - selfTime * freq)
	)
	rotation -= Vector3.one * 0.5
	
	return Displacement.New(position, rotation)
end



return PerlinShake
