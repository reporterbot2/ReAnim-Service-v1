-- Fixed ReAnimation GitHub Script with offsets

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

local limbNames = {"Left Arm","Right Arm","Left Leg","Right Leg"}
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

-- Setup limbs
for _, limbName in ipairs(limbNames) do
	local limb = character:FindFirstChild(limbName)
	if limb then
		-- Remove any remaining welds or attachments recursively
		for _, obj in ipairs(limb:GetDescendants()) do
			if obj:IsA("Weld") or obj:IsA("Attachment") or obj:IsA("Motor6D") then
				obj:Destroy()
			end
		end

		-- Create BodyVelocity
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bv.Velocity = Vector3.new(0,0,0)
		bv.Parent = limb

		-- Create BodyGyro
		local bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
		bg.P = 1e4
		bg.CFrame = limb.CFrame
		bg.Parent = limb

		-- Save controller + offset
		limbControllers[limbName] = {BV = bv, BG = bg, Offset = offsets[limbName]}
	end
end

-- Built-in updateLimb function
function updateLimb(limbName, rotationCFrame, position)
	local controller = limbControllers[limbName]
	if controller and controller.BV and controller.BG then
		-- Use saved offset if needed
		local offsetCFrame = controller.Offset or CFrame.new()
		-- Move limb toward target position
		controller.BV.Velocity = (position - controller.BV.Parent.Position) * 20
		-- Rotate limb
		controller.BG.CFrame = CFrame.new(position) * rotationCFrame
	end
end
