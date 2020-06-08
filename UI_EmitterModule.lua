local module= {}

local ra = Random.new()

local Emitters = {}

local ParticleQueue = {}

local Garbage = {}

local t0 = tick()
local RunTime

game:GetService("RunService"):BindToRenderStep("UI_ParticleModule", Enum.RenderPriority.First.Value+1, function(deltaTime)
	RunTime = tick()-t0
	
	--print(#ParticleQueue, #Emitters, #Garbage) Debug, works nicely
	
	for _, Data in pairs(Emitters) do
		if Data.Emitter.Enabled and tick()-Data.lastEmission >= Data.Emitter.Rate^(-1) then
			Data.lastEmission = tick()
			
			addParticle(Data.Emitter, Data.Emitter.Parent, Data.Scale)
		end
	end
	
	local toRemove = {}
	
	for _,Particle in pairs(ParticleQueue) do
		local ParticleRunTime = tick()-Particle.Start
		local ParticleRunTimeRatio = ParticleRunTime/Particle.Lifetime
		
		if ParticleRunTime >= Particle.Lifetime then
			table.insert(toRemove, Particle)
		else
			do
				local first, second, ratio = getKeypointsFromTime(Particle.Transparency, ParticleRunTimeRatio)
				Particle.UI.ImageTransparency = lerpValue(first.Value, second.Value, ratio)
			end
			
			do
				local first, second, ratio = getKeypointsFromTime(Particle.Size, ParticleRunTimeRatio)
				local Size = lerpValue(first.Value, second.Value, ratio)*100*Particle.Scale
				Particle.UI.Size = UDim2.new(0,Size,0,Size)
			end
			
			do
				local first, second, ratio = getKeypointsFromTime(Particle.Emitter.Color, ParticleRunTimeRatio)
				local newColor = first.Value:Lerp(second.Value, ratio)
				Particle.UI.ImageColor3 = newColor
			end
			
			Particle.UI.Rotation = Particle.UI.Rotation + Particle.RotSpeed*deltaTime
			
			local cPos = Particle.UI.Position
			
			local SpeedUDim
			local Speed = Particle.Speed
			
			local Damping = 1-math.min(1, ParticleRunTime^4*(Particle.Emitter.Drag/10))
			
			local Angle = Particle.SpreadAngle
			Particle.SpeedDisplacement = Particle.SpeedDisplacement + Speed*deltaTime*Damping
			
			if Particle.Emitter.EmissionDirection == Enum.NormalId.Bottom then
				Angle = Angle + 180
			elseif Particle.Emitter.EmissionDirection == Enum.NormalId.Right then
				Angle = Angle + 90
			elseif Particle.Emitter.EmissionDirection == Enum.NormalId.Left then
				Angle = Angle + 270
			end
			
			local SpeedUDim = UDim2.new(0,math.sin(math.rad(Angle))*Particle.SpeedDisplacement,0,-math.cos(math.rad(Angle))*Particle.SpeedDisplacement)
			
			Particle.Accel = Particle.Accel + Particle.Emitter.Acceleration*100*Particle.Scale*(ParticleRunTime^2)*deltaTime*Damping
			
			Particle.UI.Position = Particle.StartPos + SpeedUDim + UDim2.new(0,Particle.Accel.X,0,-Particle.Accel.Y)
			
		end
	end
	
	
	for _,Particle in pairs(toRemove) do
		Particle.UI.ImageTransparency = 1
		table.insert(Garbage, {UI = Particle.UI, RemoveAt = tick()+3*(Particle.Emitter.Rate^(-1))})
		
		table.remove(ParticleQueue, table.find(ParticleQueue, Particle))
	end
	
	toRemove = {}
	
	for _,UI in pairs(Garbage) do
		if tick() >= UI.RemoveAt then
			UI.UI:Destroy()
			
			table.insert(toRemove, UI)
		end
	end
	
	for _,UI in pairs(toRemove) do
		table.remove(Garbage, table.find(Garbage, UI))
	end
end)

function lerpValue(num, lerpTo, ratio)
	return (num+(lerpTo-num)*ratio)
end

function r_num(min, max)
	return ra:NextNumber(max and min or 0, max or min)
end

function r_int(min, max)
	return ra:NextInteger(max and min or 0, max or min)
end

function addParticle(ParticleEmitter, UI_Parent, Scale)
	local new
	
	for _,oldUI in pairs(Garbage) do
		if oldUI.UI then
			new = oldUI.UI
			new.Parent = UI_Parent
			
			table.remove(Garbage, table.find(Garbage, oldUI))
			
			break
		end
	end
	
	if not new then
		new = Instance.new("ImageLabel", UI_Parent)
		new.BackgroundTransparency = 1
		new.AnchorPoint = Vector2.new(0.5,0.5)
	end
	
	new.Image = ParticleEmitter.Texture
	new.ZIndex = ParticleEmitter.ZOffset
	
	local StartPos = UDim2.new(r_num(0,1),0,r_num(0,1),0)
	new.Position = StartPos
	
	local Color = ParticleEmitter.Color.Keypoints[1]
	local StartColor = Color.Value
	new.ImageColor3 = StartColor
	
	local Size = ParticleEmitter.Size.Keypoints[1]
	local StartSize = r_num(Size.Value-Size.Envelope, Size.Value+Size.Envelope)*100*Scale
	new.Size = UDim2.new(0,StartSize,0,StartSize)
	
	local Trans = ParticleEmitter.Transparency.Keypoints[1]
	local StartTrans = r_num(Trans.Value-Trans.Envelope, Trans.Value+Trans.Envelope)
	new.ImageTransparency = StartTrans
	
	new.Rotation = r_num(ParticleEmitter.Rotation.Min, ParticleEmitter.Rotation.Max)
	
	local ParticleSpeed = r_num(ParticleEmitter.Speed.Min, ParticleEmitter.Speed.Max)*100*Scale
	local ParticleRotSpeed = r_num(ParticleEmitter.RotSpeed.Min, ParticleEmitter.RotSpeed.Max)
	
	local SpreadAngle = r_num(-ParticleEmitter.SpreadAngle.X, ParticleEmitter.SpreadAngle.Y)
	
	local RandomizedTransparency = getRandomNumberSequence(ParticleEmitter.Transparency)
	local RandomizedSize = getRandomNumberSequence(ParticleEmitter.Size)
	
	table.insert(ParticleQueue, {Emitter=ParticleEmitter, UI = new, Start = tick(),
	Lifetime = r_num(ParticleEmitter.Lifetime.Min, ParticleEmitter.Lifetime.Max),
	Transparency = RandomizedTransparency, Size = RandomizedSize,
	Speed = ParticleSpeed, RotSpeed = ParticleRotSpeed, SpreadAngle = SpreadAngle,
	StartPos = StartPos, SpeedDisplacement = 0, Accel = Vector3.new(0,0,0), Scale = Scale})
end

function getRandomNumberSequence(NumberSeq)
	local newSeq = {Keypoints = {}}
	
	for _,kp in pairs(NumberSeq.Keypoints) do
		table.insert(newSeq.Keypoints, {Time = kp.Time, Value = r_num(kp.Value-kp.Envelope, kp.Value+kp.Envelope)})
	end
	
	return newSeq	--returns "CustomNumberSequence"
end

function getKeypointsFromTime(CustomNumberSeq, t)
	for i, kp in pairs(CustomNumberSeq.Keypoints) do
		if kp.Time > t then
			local kp1 = CustomNumberSeq.Keypoints[i-1]
			local kp2 = CustomNumberSeq.Keypoints[i]
			local ratio = (t-kp1.Time)/(kp2.Time-kp1.Time)
			return kp1, kp2, ratio
		end
	end
end





function module:AddEmitter(ParticleEmitter, Scale)
	print("Adding Particle:", ParticleEmitter)
	
	table.insert(Emitters, {Emitter=ParticleEmitter, lastEmission = tick(), Scale=Scale or 1})
end

function module:RemoveEmitter(ParticleEmitter)
	print("Removing Particle:", ParticleEmitter)
	
	local toRemove = {}
	
	for _, Data in pairs(Emitters) do
		if Data.Emitter == ParticleEmitter then
			table.insert(toRemove, Data)
			break
		end
	end
	
	for _,Particle in pairs(toRemove) do
		table.remove(Emitters, table.find(Emitters, Particle))
	end
end

return module
