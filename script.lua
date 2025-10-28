-- FeHub Script

--[[
    FeHub - All-in-one Roblox script
    Features:
    - Orion-based UI
    - Player commands: bring, jail, unjail, punch
    - Chat-based commands with a customizable prefix
    - Remote event spy
]]

-- Services
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local Player
local LocalPlayer = Players.LocalPlayer

print("FeHub: Script started.")

-- Load Orion Library
local OrionLib
local success, err = pcall(function()
    OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/OrionLibrary/Orion/main/source.lua')))()
end)

if not success then
    print("FeHub Error: Failed to load Orion Library. Error: " .. tostring(err))
    return -- Stop script execution if Orion fails to load
end

if not OrionLib then
    print("FeHub Error: OrionLib is nil after loading. Orion library might not be available or returned an empty value.")
    return -- Stop script execution
end

print("FeHub: Orion Library loaded successfully.")

-- Configuration
local config = {
    prefix = ";",
    targetPlayerName = "",
    remoteSpyEnabled = false,
    jailPart = nil
}

-- Create the Window
local Window = OrionLib:MakeWindow({
    Name = "FeHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FeHubConfig",
    IntroEnabled = true,
    IntroText = "Welcome to FeHub!",
    Icon = "rbxassetid://4483345998"
})

print("FeHub: UI Window created.")

-- =============================================
-- CORE FUNCTIONS
-- =============================================

-- Function to find a player
local function getPlayer(name)
    if not name or name == "" then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if string.sub(string.lower(player.Name), 1, #name) == string.lower(name) then
            return player
        end
    end
    return nil
end

-- Bring command logic
local function bringPlayer(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        OrionLib:MakeNotification({ Name = "Brought", Content = "Brought " .. target.Name .. " to you.", Time = 3 })
    else
        OrionLib:MakeNotification({ Name = "Error", Content = "Could not bring player.", Time = 3 })
    end
end

-- Jail command logic
local function jailPlayer(target)
    if config.jailPart then config.jailPart:Destroy() end
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local jail = Instance.new("Part")
        jail.Parent = workspace
        jail.Size = Vector3.new(10, 12, 10)
        jail.Position = target.Character.HumanoidRootPart.Position
        jail.Anchored = true
        jail.CanCollide = true
        jail.Transparency = 0.6
        jail.BrickColor = BrickColor.new("Institutional white")
        
        local weld = Instance.new("WeldConstraint")
        weld.Parent = jail
        weld.Part0 = jail
        weld.Part1 = target.Character.HumanoidRootPart
        
        config.jailPart = jail
        Debris:AddItem(config.jailPart, 60) -- Jail lasts for 60 seconds or until unjailed

        OrionLib:MakeNotification({ Name = "Jailed", Content = target.Name .. " has been jailed.", Time = 3 })
    else
        OrionLib:MakeNotification({ Name = "Error", Content = "Could not jail player.", Time = 3 })
    end
end

-- Unjail command logic
local function unjailPlayer()
    if config.jailPart then
        config.jailPart:Destroy()
        config.jailPart = nil
        OrionLib:MakeNotification({ Name = "Unjailed", Content = "Player has been unjailed.", Time = 3 })
    end
end

-- Punch command logic
local function punchPlayer(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local lv = LocalPlayer.Character.HumanoidRootPart.CFrame.lookVector
        local bp = Instance.new("BodyPosition")
        bp.Parent = target.Character.HumanoidRootPart
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 50000
        bp.D = 1000
        bp.Position = target.Character.HumanoidRootPart.Position + (lv * 100)
        
        Debris:AddItem(bp, 0.5)
        OrionLib:MakeNotification({ Name = "Punched", Content = "Punched " .. target.Name .. ".", Time = 3 })
    else
        OrionLib:MakeNotification({ Name = "Error", Content = "Could not punch player.", Time = 3 })
    end
end


print("FeHub: Core functions defined.")

-- =============================================
-- UI CREATION
-- =============================================

-- Main Tab
local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })

MainTab:AddSection({ Name = "Player Commands" })

MainTab:AddTextbox({
    Name = "Target Player",
    Default = "Username",
    TextDisappear = true,
    Callback = function(value)
        config.targetPlayerName = value
    end
})

MainTab:AddButton({
    Name = "Bring",
    Callback = function()
        bringPlayer(getPlayer(config.targetPlayerName))
    end
})

MainTab:AddButton({
    Name = "Jail",
    Callback = function()
        jailPlayer(getPlayer(config.targetPlayerName))
    end
})

MainTab:AddButton({
    Name = "Unjail",
    Callback = function()
        unjailPlayer()
    end
})

MainTab:AddButton({
    Name = "Punch (Fling)",
    Callback = function()
        punchPlayer(getPlayer(config.targetPlayerName))
    end
})

-- Remote Spy Tab
local RemoteSpyTab = Window:MakeTab({ Name = "Remote Spy", Icon = "rbxassetid://4483345998" })
RemoteSpyTab:AddSection({ Name = "Remote Spy" })

RemoteSpyTab:AddToggle({
    Name = "Enable Remote Spy",
    Default = false,
    Callback = function(value)
        config.remoteSpyEnabled = value
        local status = value and "Enabled" or "Disabled"
        OrionLib:MakeNotification({ Name = "Remote Spy", Content = status .. ". Check console (F9) for logs.", Time = 4 })
    end
})

RemoteSpyTab:AddParagraph("Info", "When enabled, this will print all fired RemoteEvents and their arguments to the developer console.")


-- Settings Tab
local SettingsTab = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://4483345998" })
SettingsTab:AddSection({ Name = "General Settings" })

SettingsTab:AddTextbox({
    Name = "Command Prefix",
    Default = config.prefix,
    TextDisappear = false,
    Callback = function(value)
        config.prefix = value
        OrionLib:MakeNotification({ Name = "Prefix Updated", Content = "New prefix is: " .. value, Time = 3 })
    end
})

print("FeHub: UI Tabs and elements created.")

-- =============================================
-- BACKGROUND PROCESSES
-- =============================================

-- Chat command handler
LocalPlayer.Chatted:Connect(function(msg)
    local lowerMsg = msg:lower()
    if not lowerMsg:find(config.prefix, 1, true) then return end

    local args = lowerMsg:split(" ")
    local cmd = args[1]:sub(#config.prefix + 1)
    local targetName = args[2]

    if cmd == "bring" then
        bringPlayer(getPlayer(targetName))
    elseif cmd == "jail" then
        jailPlayer(getPlayer(targetName))
    elseif cmd == "unjail" then
        unjailPlayer()
    elseif cmd == "punch" then
        punchPlayer(getPlayer(targetName))
    elseif cmd == "prefix" and targetName then
        config.prefix = targetName
        OrionLib:MakeNotification({ Name = "Prefix Updated", Content = "New prefix is: " .. targetName, Time = 3 })
    end
end)

-- Remote event spy logic
local function spyOnRemote(remote)
    remote.OnClientEvent:Connect(function(...)
        if config.remoteSpyEnabled then
            local args = {...}
            local argString = table.concat(args, ", ")
            print("FeHub Remote Spy | Fired: " .. remote:GetFullName() .. " | Args: " .. argString)
        end
    end)
end

-- Find all remotes
for _, service in ipairs({ReplicatedStorage, workspace}) do
    for _, descendant in ipairs(service:GetDescendants()) do
        if descendant:IsA("RemoteEvent") then
            spyOnRemote(descendant)
        end
    end
end

-- Also listen for new remotes being added
ReplicatedStorage.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("RemoteEvent") then
        spyOnRemote(descendant)
    end
end)
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("RemoteEvent") then
        spyOnRemote(descendant)
    end
end)

print("FeHub: Background processes (chat handler, remote spy) initialized.")

-- =============================================
-- INITIALIZATION
-- =============================================

local initSuccess, initErr = pcall(function()
    OrionLib:Init()
end)

if not initSuccess then
    print("FeHub Error: Failed to initialize Orion Library. Error: " .. tostring(initErr))
    return
end

print("FeHub: Orion Library initialized successfully.")

OrionLib:MakeNotification({
    Name = "FeHub Loaded",
    Content = "Successfully loaded FeHub. Enjoy!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

print("FeHub: Script finished execution.")
