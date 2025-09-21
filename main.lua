-- Single LocalScript (can be loaded via loadstring)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

local limbNames = {"Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local torso = character:WaitForChild("Torso")
local offsets = {}
local limbControllers = {}

-- Save offsets and remove Motor6Ds
for _, obj in ipairs(torso:GetChildren()) do
	if obj:IsA("Motor6D") and obj.Part1 and table.find(limbNames, obj.Part1.Name) then
		offsets[obj.Part1.Name] = torso.CFrame:toObjectSpace(obj.Part1.CFrame)
		obj:Destroy()
	end
end

-- Setup each limb with BodyGyro and BodyVelocity
local function setupLimb(limb)
	if not limb then return end
	for _, obj in ipairs(limb:GetChildren()) do
		if obj:IsA("Weld") or obj:IsA("Attachment") or obj:IsA("Motor6D") then
			obj:Destroy()
		end
	end

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.new(0,0,0)
	bv.Parent = limb

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.P = 1e4
	bg.CFrame = limb.CFrame
	bg.Parent = limb

	limbControllers[limb.Name] = {BV = bv, BG = bg, Offset = offsets[limb.Name]}

	RunService.RenderStepped:Connect(function()
		local offset = offsets[limb.Name]
		if torso and offset and limb.Parent then
			local targetCFrame = torso.CFrame * offset
			bv.Velocity = (targetCFrame.Position - limb.Position) * 20 + (character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Velocity or Vector3.new())
			bg.CFrame = targetCFrame
		end
	end)
end

-- Setup all limbs
for _, limbName in ipairs(limbNames) do
	local limb = character:FindFirstChild(limbName)
	if limb then
		setupLimb(limb)
	end
end

-- Built-in updateLimb function (can be called anywhere in this script)
local function updateLimb(limbName, rotationCFrame, position)
	local controller = limbControllers[limbName]
	if controller and controller.BG and controller.BV then
		controller.BG.CFrame = CFrame.new(position) * rotationCFrame
		controller.BV.Velocity = Vector3.new(0,0,0)
	end
end

-- Example usage inside the same script:
-- rotate Left Arm 90 degrees on Y and move it 2 studs in front of torso
-- updateLimb("Left Arm", CFrame.Angles(0, math.rad(90), 0), torso.Position + torso.CFrame.LookVector * 2)
