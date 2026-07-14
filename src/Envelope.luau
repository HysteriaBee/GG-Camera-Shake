-- GGShaker by GasGiant
-- Luau Port by @niceshark11 (HysteriaBee)
-- <Summary> Controls strength of the shake over time.
--!strict

local Power = require(script.Parent.Power)

local Envelope = {}
Envelope.__index = Envelope

export type EnvelopeParams = {
	attack: number, -- How fast the amplitude increases.
	sustain: number, -- How long in seconds the amplitude holds maximum value.
	decay: number, -- How fast the amplitude decreases.
	degree: number, -- Power in which the amplitude is raised to get intensity.
}

export type EnvelopeControlMode = "Auto" | "Manual" -- Pass auto for a single shake, or manual for controlling strength manually.
export type EnvelopeState = "Sustain" | "Increase" | "Decrease"

export type Envelope = {
	pars: EnvelopeParams,
	controlMode: EnvelopeControlMode,
	amplitude: number,
	targetAmplitude: number,
	sustainEndTime: number,
	finishWhenAmplitudeZero: boolean,
	finishImmediately: boolean,
	state: EnvelopeState,
	Intensity: number,
} & typeof(Envelope)

-- Returns default parameters.
function Envelope.GetDefaultParams(): EnvelopeParams
	return {
		attack = 10,
		sustain = 0,
		decay = 1,
		degree = 3,
	}
end

-- Creates a new envelope instance.
function Envelope.New(pars: EnvelopeParams, initialTargetAmplitude: number, controlMode: EnvelopeControlMode): Envelope
	local self = setmetatable({}, Envelope) :: Envelope

	self.pars = pars
	self.controlMode = controlMode
	self.amplitude = 0
	self.targetAmplitude = 0
	self.sustainEndTime = 0
	self.Intensity = 0
	self.finishWhenAmplitudeZero = false
	self.finishImmediately = false
	self.state = "Sustain"

	self:_SetTarget(initialTargetAmplitude)

	return self
end

-- Set the target amplitude for an envelope.
function Envelope._SetTarget(self: Envelope, value: number)
	self.targetAmplitude = math.clamp(value, 0, 1)
	self.state = if self.targetAmplitude > self.amplitude then "Increase" else "Decrease"
end

-- Update an envelope.
function Envelope.Update(self: Envelope, deltaTime: number)
	if self:IsFinished() then
		return
	end

	local pars = self.pars
	local amplitude = self.amplitude
	local targetAmplitude = self.targetAmplitude

	if self.state == "Increase" then
		if pars.attack > 0 then
			amplitude += deltaTime * pars.attack
		end

		if amplitude > targetAmplitude or pars.attack <= 0 then
			amplitude = targetAmplitude
			self.state = "Sustain"

			if self.controlMode == "Auto" then
				self.sustainEndTime = os.clock() + pars.sustain :: number
			end
		end
	else
		if self.state == "Decrease" then
			if pars.decay > 0 then
				amplitude -= deltaTime * pars.decay
			end

			if amplitude < targetAmplitude or pars.decay <= 0 then
				amplitude = targetAmplitude
				self.state = "Sustain"
			end
		else
			if self.controlMode == "Auto" and os.clock() > self.sustainEndTime then
				self:_SetTarget(0)
			end
		end
	end

	self.amplitude = math.clamp(amplitude, 0, 1)
	self.Intensity = Power.Evaluate(self.amplitude, pars.degree)
end

-- Check if an envelope is finished.
function Envelope.IsFinished(self: Envelope): boolean

	if self.finishImmediately then 
		return true 
	end

	return (self.finishWhenAmplitudeZero or self.controlMode == "Auto")
		and self.amplitude <= 0 
		and self.targetAmplitude <= 0
end

-- Set an envelope to finish.
function Envelope.Finish(self: Envelope)
	self.finishWhenAmplitudeZero = true
	self:_SetTarget(0)
end

-- Set an envelope to finish immediately.
function Envelope.FinishImmediately(self: Envelope)
	self.finishImmediately = true
end

--Set the target amplitude for an envelope.
function Envelope.SetTargetAmplitude(self: Envelope, value: number)
	if self.controlMode == "Manual" and not self.finishWhenAmplitudeZero then
		self:_SetTarget(value)
	end
end

return Envelope
