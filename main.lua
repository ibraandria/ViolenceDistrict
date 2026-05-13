--[[
    ╔══════════════════════════════════════════════════╗
    ║           VIOLENCE DISTRICT - FULL EDITION       ║
    ║         Optimized for EUGUNEWU Loader v3.0       ║
    ║         By Dr. Erik - Unrestricted Version       ║
    ╚══════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

print("🔪 [VIOLENCE DISTRICT] Initializing full chaos system...")

-- ==================== CONFIGURATION ====================
local CONFIG = {
    ZoneName = "ViolenceDistrict",
    ZoneRadius = 220,
    ViolenceChancePerTick = 21,
    MaxWantedLevel = 5,
    BloodDuration = 8,
    DamageOnRandomEvent = 35,
}

-- ==================== REMOTE EVENTS ====================
local function GetOrCreateRemote(name)
    local remote = ReplicatedStorage:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = ReplicatedStorage
    end
    return remote
end

local Remotes = {
    ViolenceTrigger = GetOrCreateRemote("ViolenceTrigger"),
    BloodEffect = GetOrCreateRemote("BloodEffect"),
    KillFeed = GetOrCreateRemote("KillFeed"),
    WantedUpdate = GetOrCreateRemote("WantedUpdate")
}

-- ==================== PLAYER DATA ====================
local PlayerData = {}

Players.PlayerAdded:Connect(function(plr)
    PlayerData[plr] = {
        Wanted = 0,
        KillStreak = 0,
        InZone = false,
        LastAttack = 0
    }
    
    plr.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            Remotes.KillFeed:FireAllClients("💀 " .. plr.Name .. " TELAH MATI DENGAN BRUTAL DI VIOLENCE DISTRICT!")
            
            -- Brutal Ragdoll + Gore
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(8000, 8000, 8000)
                    bv.Velocity = Vector3.new(math.random(-60,60), math.random(25,55), math.random(-60,60))
                    bv.Parent = part
                    Debris:AddItem(bv, 3)
                    
                    local bloodDecal = Instance.new("Decal")
                    bloodDecal.Texture = "rbxassetid://241650934"
                    bloodDecal.Face = Enum.NormalId.Top
                    bloodDecal.Parent = part
                    Debris:AddItem(bloodDecal, 15)
                end
            end
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    PlayerData[plr] = nil
end)

-- ==================== DISTRICT ZONE ====================
local DistrictFolder = Workspace:FindFirstChild(CONFIG.ZoneName)
local CenterPart = DistrictFolder and DistrictFolder:FindFirstChild("Center") or nil

if not CenterPart then
    warn("[Violence District] Center part tidak ditemukan! Buat Part bernama 'Center' di folder ViolenceDistrict")
end

local function IsInZone(plr)
    if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and CenterPart) then
        return false
    end
    return (plr.Character.HumanoidRootPart.Position - CenterPart.Position).Magnitude <= CONFIG.ZoneRadius
end

-- ==================== BRUTAL VIOLENCE EVENT ====================
local function TriggerBrutalViolence(attacker)
    local targets = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= attacker and PlayerData[plr].InZone and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            table.insert(targets, plr)
        end
    end
    
    if #targets == 0 then return end
    
    local victim = targets[math.random(#targets)]
    local vHum = victim.Character.Humanoid
    
    vHum:TakeDamage(CONFIG.DamageOnRandomEvent)
    
    -- Blood Spray Effect
    Remotes.BloodEffect:FireAllClients("Spray", victim.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
    
    -- Stats Update
    local data = PlayerData[attacker]
    data.Wanted = math.min(data.Wanted + 1, CONFIG.MaxWantedLevel)
    data.KillStreak += 1
    
    Remotes.WantedUpdate:FireAllClients(attacker.Name, data.Wanted, data.KillStreak)
    Remotes.KillFeed:FireAllClients("🔪 " .. attacker.Name .. " MENYERANG " .. victim.Name .. " DENGAN BRUTAL!")
end

-- ==================== MAIN HEARTBEAT LOOP ====================
RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        local data = PlayerData[plr]
        if not data then continue end
        
        local inZoneNow = IsInZone(plr)
        
        if inZoneNow and not data.InZone then
            data.InZone = true
            Remotes.ViolenceTrigger:FireClient(plr, "EnterZone", true)
        elseif not inZoneNow and data.InZone then
            data.InZone = false
            Remotes.ViolenceTrigger:FireClient(plr, "EnterZone", false)
        end
        
        -- Random Violence Trigger
        if data.InZone and math.random(1, 100) <= CONFIG.ViolenceChancePerTick then
            TriggerBrutalViolence(plr)
        end
    end
end)

-- ==================== CLIENT SIDE - GORE & UI ====================
if RunService:IsClient() then
    local BloodRemote = Remotes.BloodEffect
    local KillFeedRemote = Remotes.KillFeed
    local ViolenceRemote = Remotes.ViolenceTrigger
    
    BloodRemote.OnClientEvent:Connect(function(action, position)
        if typeof(position) ~= "Vector3" then return end
        
        local attachment = Instance.new("Attachment")
        attachment.WorldPosition = position
        attachment.Parent = Workspace.Terrain
        
        local particle = Instance.new("ParticleEmitter")
        particle.Texture = "rbxassetid://241650934"
        particle.Color = ColorSequence.new(Color3.fromRGB(75, 0, 0))
        particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.8), NumberSequenceKeypoint.new(1, 0.3)})
        particle.Lifetime = NumberRange.new(3, 7)
        particle.Rate = action == "Spray" and 250 or 140
        particle.Speed = NumberRange.new(15, 40)
        particle.SpreadAngle = Vector2.new(50, 50)
        particle.Transparency = NumberSequence.new(0.2, 1)
        particle.Parent = attachment
        
        Debris:AddItem(attachment, CONFIG.BloodDuration)
    end)
    
    KillFeedRemote.OnClientEvent:Connect(function(message)
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = message,
            Color = Color3.fromRGB(200, 10, 10),
            Font = Enum.Font.GothamBold,
            TextSize = 18
        })
    end)
    
    ViolenceRemote.OnClientEvent:Connect(function(action, value)
        if action == "EnterZone" then
            if value then
                print("🩸 ANDA TELAH MEMASUKI VIOLENCE DISTRICT - KERUSUHAN DIMULAI!")
            else
                print("🏃 Anda telah keluar dari Violence District.")
            end
        end
    end)
end

print("✅ VIOLENCE DISTRICT FULL SYSTEM LOADED SUCCESSFULLY")
print("Repo: ibraandria/ViolenceDistrict - Ready for chaos")
print("Gunakan dengan risiko sendiri. Full gore enabled.")

-- Extra Print untuk Loader
task.wait(1)
print("🔴 Violence District siap dieksekusi melalui EUGUNEWU Loader")
