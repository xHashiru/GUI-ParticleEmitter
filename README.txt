# GUI-ParticleEmitter
Particle Emitter for GUI objects

Put the UI_EmitterModule inside of ReplicatedStorage and the ParticleManager in StarterPlayer and you are ready to go.


Documentation:

local EmitterModule = require(game.ReplicatedStorage.UI_EmitterModule)


Functions:
EmitterModule:AddEmitter(ParticleEmitter, Scale)

EmitterModule:RemoveEmitter(ParticleEmitter)


Info:
Scale can be any value but is set to 1 by default. It scales size, speed and acceleration.

ParticleEmitter must be in the GUI object that emitts the effect.


Emitters can be disabled and it will behave as expected
LightInfluence and Emission dont do anything

SpreadAngle uses -SpreadAngle.X to +SpreadAngle.Y randomly
EmissionDirection works in top, right, bottom and left direction.
Acceleration only uses X and Y
ZIndex also works, be sure to use it.

Drag might not behave 100% like an original ParticleEmitter, so be sure to tinker with the Drag-Slider if you use it.
