
-- thank to https://github.com/bhristt/Spring-Module

local spring = {}
spring.__index = spring

local exp = math.exp
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local clock = os.clock

function spring.New(Mass,Damping,Constant,InitialOffset,InitialVelocity,ExternalForce)
	local this = {
		Mass = Mass;
		Damping = Damping;
		Constant = Constant;
		InitialOffset = InitialOffset - ExternalForce/Constant;
		InitialVelocity = InitialVelocity;
		ExternalForce = ExternalForce;
	}
	setmetatable(this,spring)
	return this
end

-- init resolver
local d = -1 / 2
function spring:InitResolverOld()
	local InitialOffset, InitialVelocity, ExternalForce = self.InitialOffset, self.InitialVelocity, self.ExternalForce
	local Mass, Damping, Constant = self.Mass, self.Damping, self.Constant
	local delta = ((Damping * Damping) / (Mass * Mass)) - (4 * Constant / Mass)
	local StartTick = clock()
	self.StartTick = StartTick

	if delta > 0 then
		local w1 = Damping/Mass + sqrt(delta)
		local w2 = Damping/Mass - sqrt(delta)
		local r1, r2 = d * w1, d * w2
		local c1, c2 = ((r2 * InitialOffset) - InitialVelocity) / (r2 - r1), ((r1 * InitialOffset) - InitialVelocity) / (r1 - r2)
		local yp = ExternalForce / Constant

		self.GetOffset = function()
			local dt = clock() - StartTick
			return c1 * exp(r1 * dt) + c2 * exp(r2 * dt) + yp
		end
		self.GetVelocity = function()
			local dt = clock() - StartTick
			return c1 * r1 * exp(r1 * dt) + c2 * r2 * exp(r2 * dt)
		end
		self.GetAcceleration = function()
			local dt = clock() - StartTick
			return c1 * r1 * r1 * exp(r1 * dt) + c2 * r2 * r2 * exp(r2 * dt)
		end
	elseif delta == 0 then
		local r = -Damping / (2 * Mass)
		local c1, c2 = InitialOffset, InitialVelocity - r * InitialOffset
		local yp = ExternalForce / Constant

		self.GetOffset = function()
			local dt = clock() - StartTick
			return exp(r * dt) * (c1 + c2 * dt) + yp
		end
		self.GetVelocity = function()
			local dt = clock() - StartTick
			return exp(r * dt) * (c2 * r * dt + c1 * r + c2)
		end
		self.GetAcceleration = function()
			local dt = clock() - StartTick
			return r * exp(r * dt) * (c2 * r * dt + c1 * r + 2 * c2)
		end
	else
		local r = -Damping / (2 * Mass)
		local s = sqrt(-delta)
		local c1, c2 = InitialOffset, (InitialVelocity - (r * InitialOffset)) / s
		local yp = ExternalForce / Constant

		self.GetOffset = function()
			local dt = clock() - StartTick
			return exp(r * dt) * (c1 * cos(s * dt) + c2 * sin(s * dt)) + yp
		end
		self.GetVelocity = function()
			local dt = clock() - StartTick
			return -exp(r * dt) * ((c1 * s - c2 * r) * sin(s * dt) + (-c2 * s - c1 * r) * cos(s * dt))
		end
		self.GetAcceleration = function()
			local dt = clock() - StartTick
			return -exp(r * dt) * ((c2 * s * s + 2 * c1 * r * s - c2 * r * r) * sin(s * dt) + (c1 * s * s - 2 * c2 * r * s - c1 * r * r) * cos(s * dt))
		end
	end

	return self
end

function spring:InitResolver()
	local InitialOffset, InitialVelocity, ExternalForce = self.InitialOffset, self.InitialVelocity, self.ExternalForce
	local Mass, Damping, Constant = self.Mass, self.Damping, self.Constant
	local delta = ((Damping * Damping) / (Mass * Mass)) - (4 * Constant / Mass)
	local StartTick = clock()
	self.StartTick = StartTick
	self.Delta = delta
	self.yp = ExternalForce / Constant
	if delta > 0 then
		local w1 = Damping/Mass + sqrt(delta)
		local w2 = Damping/Mass - sqrt(delta)
		local r1, r2 = d * w1, d * w2
		self.c1,self.c2 = ((r2 * InitialOffset) - InitialVelocity) / (r2 - r1), ((r1 * InitialOffset) - InitialVelocity) / (r1 - r2)
		self.r1,self.r2 = r1,r2
	elseif delta == 0 then
		local r = -Damping / (2 * Mass)
		self.c1,self.c2 = InitialOffset, InitialVelocity - r * InitialOffset
		self.r = r
	else
		local r = -Damping / (2 * Mass)
		local s = sqrt(-delta)
		self.c1,self.c2 = InitialOffset, (InitialVelocity - (r * InitialOffset)) / s
		self.r,self.s = r,s
	end
	return self
end

function spring:GetOffset(dt)
	dt = dt or (clock() - self.StartTick)
	local delta = self.Delta

	if delta > 0 then
		return self.c1 * exp(self.r1 * dt) + self.c2 * exp(self.r2 * dt) + self.yp
	elseif delta == 0 then
		return exp(self.r * dt) * (self.c1 + self.c2 * dt) + self.yp
	else
		return exp(self.r * dt) * (self.c1 * cos(self.s * dt) + self.c2 * sin(self.s * dt)) + self.yp
	end
end

function spring:GetVelocity(dt)
	dt = dt or (clock() - self.StartTick)
	local delta = self.Delta

	if delta > 0 then
		local r1,r2 = self.r1,self.r2
		return self.c1 * r1 * exp(r1 * dt) + self.c2 * r2 * exp(r2 * dt)
	elseif delta == 0 then
		local r,c2 = self.r,self.c2
		return exp(r * dt) * (c2 * r * dt + self.c1 * r + c2)
	else
		local r,s,c1,c2 = self.r,self.s,self.c1,self.c2
		return -exp(r * dt) * ((c1 * s - c2 * r) * sin(s * dt) + (-c2 * s - c1 * r) * cos(s * dt))
	end
end

function spring:GetAcceleration(dt)
	dt = dt or (clock() - self.StartTick)
	local delta = self.Delta

	if delta > 0 then
		local r1,r2 = self.r1,self.r2
		return self.c1 * r1 * r1 * exp(r1 * dt) + self.c2 * r2 * r2 * exp(r2 * dt)
	elseif delta == 0 then
		local r,c2 = self.r,self.c2
		return r * exp(r * dt) * (c2 * r * dt + self.c1 * r + 2 * c2)
	else
		local r,s,c1,c2 = self.r,self.s,self.c1,self.c2
		return -exp(r * dt) * ((c2 * s * s + 2 * c1 * r * s - c2 * r * r) * sin(s * dt) + (c1 * s * s - 2 * c2 * r * s - c1 * r * r) * cos(s * dt))
	end
end

-- sets the external force of the spring object to the given force
function spring:SetExternalForce(force)
	-- set properties
	self.ExternalForce = force
	self.InitialOffset =  self:GetOffset() - force / self.Constant
	self.InitialVelocity =  self:GetVelocity()

	-- reset spring
	self:InitResolver()
end

-- sets the external force of the spring object such that
-- the spring object eventually reaches this number
function spring:SetGoal(goal)
	-- set properties
	self.ExternalForce = goal * self.Constant
	self.InitialOffset = self:GetOffset() - goal
	self.InitialVelocity = self:GetVelocity()

	-- reset spring
	self:InitResolver()
end

-- set offset instant and reset force
function spring:SetOffset(offset)

	-- set properties and restart spring
	self.InitialOffset = offset
	self.InitialVelocity = 0
	self.ExternalForce = 0
	self:InitResolver()

	self:SetGoal(self:GetOffset())
end

-- get goal from external force and constant
function spring:GetGoal()
	return self.ExternalForce/self.Constant
end

-- adds the given offset to the spring object
function spring:AddOffset(offset)
	-- set properties and restart spring
	self.InitialOffset = self:GetOffset() + offset
	self.InitialVelocity = self:GetVelocity()
	self:InitResolver()
end

-- adds the given velocity to the spring object
function spring:AddVelocity(velocity)
	-- set properties and restart spring
	self.InitialOffset = self:GetOffset()
	self.InitialVelocity = self:GetVelocity() + velocity
	self:InitResolver()
end

return spring
