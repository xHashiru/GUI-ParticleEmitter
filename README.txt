# GUI-ParticleEmitter
Particle Emitter for GUI objects

Put the UI_EmitterModule inside of ReplicatedStorage and the ParticleManager in StarterPlayer and you are ready to go.


Documentation:

local EmitterModule = require(game.ReplicatedStorage.UI_EmitterModule)


Functions:
EmitterModule:AddEmitter(ParticleEmitter, Scale)

EmitterModule:RemoveEmitter(ParticleEmitter)


Scale can be any value but is set to 1 by default. It scales size, speed and acceleration.
