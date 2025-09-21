-- Fixed ReAnimation LocalScript (no demo)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")

local limbNames = {"Left Arm","Right Arm","Left Leg","Right Leg"}
local torso = character:WaitForChild("Torso")
local limbControllers = {}

-- Setup limbs with BodyGyro & BodyVelocity
for _, limbName in ipairs(limbNames) do
	local limb = character:FindFirstChild(limbName)
	if limb then
		-- remove Motor6Ds, Welds, Attachments
		for _, obj in ipairs(limb:GetChildren()) do
			if obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("Attachment") then
				obj:Destroy()
			end
		end

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bv.Velocity = Vector3.new(0,0,0)
		bv.Parent = limb

		local bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
		bg.P = 1e4
		bg.CFrame = limb.CFrame
		bg.Parent = limb

		limbControllers[limbName] = {BV = bv, BG = bg}
	end
end

-- Built-in updateLimb function that directly moves/rotates limb
function updateLimb(limbName, rotationCFrame, position)
	local controller = limbControllers[limbName]
	if controller and controller.BV and controller.BG then
		-- Set velocity to reach the target position
		controller.BV.Velocity = (position - controller.BV.Parent.Position) * 20
		-- Set the BodyGyro to desired rotation
		controller.BG.CFrame = CFrame.new(position) * rotationCFrame
	end
end
