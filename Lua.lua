-- =====================================================================
-- NORTEX HUB | PREMIUM V4 UI & FARM SCRIPT
-- =====================================================================

local Library = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Eski GUI Temizliği
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "PremiumHub_V4" then gui:Destroy() end
end

local HubVisible = true
local ToggleKey = Enum.KeyCode.RightControl
local UserIconID = "rbxassetid://16844605170"

-- Global Farm Değişkenleri
local tlFarmActive = false
local tlConn = nil
local autoRejoinEnabled = false
local antiAfkEnabled = true
local selectedPlayerName = ""

-- ==================== YARDIMCI FONKSIYONLAR ====================
local function FixAssetID(id)
    if type(id) == "number" or (type(id) == "string" and not id:find("rbxassetid://")) then
        return "rbxassetid://" .. tostring(id)
    end
    return id
end

local function GetExecutorName()
    local name = "Unknown"
    pcall(function() if identifyexecutor then name = identifyexecutor() end end)
    return name
end

local function getCurrentTLParts()
    local parts = {}
    local targetFolder = nil
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") and obj:FindFirstChild("ParkourMoney") then
            targetFolder = obj
            break
        end
    end
    if targetFolder then
        for _, obj in pairs(targetFolder:GetChildren()) do
            if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.CanCollide and obj.Name ~= "ParkourMoney" then
                if obj.Parent then table.insert(parts, obj) end
            end
        end
    end
    return parts
end

-- ==================== UI LIBRARY CORE ====================
function Library:CreateWindow(hubName, bgId)
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "PremiumHub_V4"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

    local BackgroundImage = Instance.new("ImageLabel", MainFrame)
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = FixAssetID(bgId)
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = 0
    Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 16)

    local Glass = Instance.new("Frame", MainFrame)
    Glass.Size = UDim2.new(1, 0, 1, 0)
    Glass.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Glass.BackgroundTransparency = 0.4
    Glass.ZIndex = 1
    Instance.new("UICorner", Glass).CornerRadius = UDim.new(0, 16)

    -- Yükleme Ekranı
    local LoadingFrame = Instance.new("Frame", ScreenGui)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LoadingFrame.Size = UDim2.new(0, 250, 0, 100)
    LoadingFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
    LoadingFrame.ClipsDescendants = true
    Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 16)

    local LoadBg = BackgroundImage:Clone() LoadBg.Parent = LoadingFrame
    local LoadGlass = Glass:Clone() LoadGlass.Parent = LoadingFrame

    local LoadTitle = Instance.new("TextLabel", LoadingFrame)
    LoadTitle.Size = UDim2.new(1, 0, 0, 30)
    LoadTitle.Position = UDim2.new(0, 0, 0, 5)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.Text = hubName
    LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadTitle.Font = Enum.Font.FredokaOne
    LoadTitle.TextSize = 20
    LoadTitle.ZIndex = 2

    local StatusText = Instance.new("TextLabel", LoadingFrame)
    StatusText.Size = UDim2.new(1, 0, 0, 20)
    StatusText.Position = UDim2.new(0, 0, 0, 45)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.Font = Enum.Font.FredokaOne
    StatusText.TextSize = 13
    StatusText.ZIndex = 2

    local BarBg = Instance.new("Frame", LoadingFrame)
    BarBg.Size = UDim2.new(0.8, 0, 0, 6)
    BarBg.Position = UDim2.new(0.1, 0, 0, 75)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBg.ZIndex = 2
    Instance.new("UICorner", BarBg)

    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BarFill.ZIndex = 3
    Instance.new("UICorner", BarFill)

    task.spawn(function()
        task.wait(0.5)
        StatusText.Text = "Detecting Executor..."
        TweenService:Create(BarFill, TweenInfo.new(1), {Size = UDim2.new(0.5, 0, 1, 0)}):Play()
        task.wait(1.2)
        StatusText.Text = GetExecutorName() .. " Executor"
        TweenService:Create(BarFill, TweenInfo.new(1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(1)
        
        -- Senin İstediğin Animasyon (Sadece içerik siliniyor)
        TweenService:Create(LoadTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(StatusText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(BarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)

        local morph = TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = MainFrame.Size, Position = MainFrame.Position})
        morph:Play()
        morph.Completed:Wait()
        MainFrame.Visible = true
        LoadingFrame:Destroy()
    end)

    -- TopBar
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 5

    local Title = Instance.new("TextLabel", TopBar)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = hubName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 6

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.FredokaOne
    CloseBtn.TextSize = 18
    CloseBtn.ZIndex = 6
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.Size = UDim2.new(0, 110, 1, -60)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ZIndex = 5
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", MainFrame)
    Container.Position = UDim2.new(0, 130, 0, 50)
    Container.Size = UDim2.new(1, -140, 1, -60)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 5

    -- Drag (Sürükleme)
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local WindowObj = {}

    function WindowObj:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.FredokaOne
        TabBtn.TextSize = 14
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        if #Sidebar:GetChildren() == 2 then 
            Page.Visible = true 
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundTransparency = 0.85
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150); b.BackgroundTransparency = 1 end end
            Page.Visible = true; TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); TabBtn.BackgroundTransparency = 0.85
        end)

        local Elements = {}

        local function CreateElementFrame(height)
            local F = Instance.new("Frame", Page)
            F.Size = UDim2.new(0.95, 0, 0, height)
            F.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            F.BackgroundTransparency = 0.7
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
            return F
        end

        function Elements:AddLabel(text)
            local LabFrame = CreateElementFrame(30)
            local LabText = Instance.new("TextLabel", LabFrame)
            LabText.Size = UDim2.new(1, -20, 1, 0)
            LabText.Position = UDim2.new(0, 10, 0, 0)
            LabText.BackgroundTransparency = 1
            LabText.Text = text
            LabText.Font = Enum.Font.FredokaOne
            LabText.TextColor3 = Color3.fromRGB(200, 200, 200)
            LabText.TextSize = 13
            LabText.TextXAlignment = Enum.TextXAlignment.Left
            local Funcs = {}
            function Funcs:SetText(val) LabText.Text = val end
            return Funcs
        end

        function Elements:AddButton(text, callback)
            local BtnFrame = CreateElementFrame(40)
            local Btn = Instance.new("TextButton", BtnFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.Font = Enum.Font.FredokaOne
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 14
            Btn.MouseButton1Click:Connect(callback)
        end

        function Elements:AddToggle(text, default, callback)
            local TglFrame = CreateElementFrame(40)
            local enabled = default
            local Lbl = Instance.new("TextLabel", TglFrame)
            Lbl.Size = UDim2.new(0.7, 0, 1, 0)
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Text = text; Lbl.Font = Enum.Font.FredokaOne; Lbl.TextColor3 = Color3.fromRGB(255, 255, 255); Lbl.TextSize = 14; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Left
            local Box = Instance.new("Frame", TglFrame)
            Box.Position = UDim2.new(1, -50, 0.5, -10); Box.Size = UDim2.new(0, 40, 0, 20); Box.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)
            local Circle = Instance.new("Frame", Box)
            Circle.Size = UDim2.new(0, 16, 0, 16); Circle.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8); Circle.BackgroundColor3 = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
            local Btn = Instance.new("TextButton", TglFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""
            Btn.MouseButton1Click:Connect(function()
                enabled = not enabled
                TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                callback(enabled)
            end)
        end

        function Elements:AddSlider(text, min, max, default, callback)
            local SldFrame = CreateElementFrame(55)
            local Tit = Instance.new("TextLabel", SldFrame)
            Tit.Size = UDim2.new(1, 0, 0, 20); Tit.Position = UDim2.new(0, 10, 0, 5); Tit.Text = text; Tit.Font = Enum.Font.FredokaOne; Tit.TextColor3 = Color3.fromRGB(255, 255, 255); Tit.TextSize = 13; Tit.BackgroundTransparency = 1; Tit.TextXAlignment = Enum.TextXAlignment.Left
            local Bar = Instance.new("Frame", SldFrame)
            Bar.Position = UDim2.new(0, 10, 0, 30); Bar.Size = UDim2.new(1, -20, 0, 15); Bar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Instance.new("UICorner", Bar)
            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Fill)
            local drag = false
            local function update(input)
                local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(p, 0, 1, 0)
                local val = math.floor(((max - min) * p) + min)
                callback(val)
            end
            Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
            UserInputService.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
        end

        function Elements:AddDropdown(text, callback)
            local DropFrame = CreateElementFrame(40)
            DropFrame.ClipsDescendants = true
            local Btn = Instance.new("TextButton", DropFrame)
            Btn.Size = UDim2.new(1, 0, 0, 40); Btn.BackgroundTransparency = 1; Btn.Text = text .. " ▼"; Btn.Font = Enum.Font.FredokaOne; Btn.TextColor3 = Color3.fromRGB(255, 255, 255); Btn.TextSize = 14
            local List = Instance.new("Frame", DropFrame)
            List.Position = UDim2.new(0, 0, 0, 40); List.Size = UDim2.new(1, 0, 1, -40); List.BackgroundTransparency = 1
            Instance.new("UIListLayout", List)
            local open = false
            Btn.MouseButton1Click:Connect(function()
                open = not open
                for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(Players:GetPlayers()) do
                    local pBtn = Instance.new("TextButton", List)
                    pBtn.Size = UDim2.new(1, 0, 0, 25); pBtn.BackgroundTransparency = 1; pBtn.Text = p.Name; pBtn.Font = Enum.Font.FredokaOne; pBtn.TextColor3 = Color3.fromRGB(200, 200, 200); pBtn.TextSize = 12
                    pBtn.MouseButton1Click:Connect(function() 
                        Btn.Text = p.Name .. " ▼"; callback(p.Name); open = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
                    end)
                end
                local target = open and (#Players:GetPlayers() * 25 + 45) or 40
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, target)}):Play()
            end)
        end

        return Elements
    end
    return WindowObj
end

-- ==================== MAIN EXECUTION ====================
local Window = Library:CreateWindow("Nortex Hub", 12586414777)

local HomeTab = Window:CreateTab("Home")
local FarmTab = Window:CreateTab("Farm")
local TeleTab = Window:CreateTab("Teleport")
local SettingsTab = Window:CreateTab("Ayarlar")

-- Home Tab
HomeTab:AddLabel("--- Sosyal Medya ---")
HomeTab:AddButton("Discord Linkini Kopyala", function() setclipboard("https://discord.gg/bS6uMXuT85") end)
HomeTab:AddLabel("--- Nortex Özellikleri ---")
HomeTab:AddLabel("• Anti-Kick TL Farm")
HomeTab:AddLabel("• Anti-AFK & Auto-Rejoin")

-- Farm Tab
FarmTab:AddToggle("TL Farm (Anti-Kick)", false, function(Value)
    tlFarmActive = Value
    if Value then
        tlConn = task.spawn(function()
            while tlFarmActive do
                local targets = getCurrentTLParts()
                if #targets > 0 then
                    local target = targets[math.random(1, #targets)]
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and target.Parent then
                        hrp.CFrame = target.CFrame + Vector3.new(0, 15, 0)
                        task.wait(0.1)
                        local t = TweenService:Create(hrp, TweenInfo.new(0.9), {CFrame = target.CFrame + Vector3.new(0, 2, 0)})
                        t:Play()
                        task.wait(1.2)
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if tlConn then task.cancel(tlConn); tlConn = nil end
    end
end)

local StatLabel = FarmTab:AddLabel("Toplanabilir TL: Hesaplanıyor...")
task.spawn(function()
    while true do
        StatLabel:SetText("Toplanabilir TL: " .. #getCurrentTLParts())
        task.wait(2)
    end
end)

-- Teleport Tab
TeleTab:AddButton("Spawn'a Git", function()
    pcall(function()
        local lobi = Workspace.Folder.MapMainFolder.Builds.lobi.Model.SpawnLocation
        LocalPlayer.Character.HumanoidRootPart.CFrame = lobi.CFrame + Vector3.new(0, 5, 0)
    end)
end)
TeleTab:AddDropdown("Oyuncu Seç", function(Name) selectedPlayerName = Name end)
TeleTab:AddButton("Oyuncuya Git", function()
    local target = Players:FindFirstChild(selectedPlayerName)
    if target and target.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

-- Settings Tab
SettingsTab:AddToggle("Anti AFK", true, function(v) antiAfkEnabled = v end)
SettingsTab:AddToggle("Auto Rejoin", false, function(v) autoRejoinEnabled = v end)
SettingsTab:AddSlider("Yürüme Hızı", 16, 250, 16, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

-- Background Loops
task.spawn(function()
    while task.wait(10) do
        if antiAfkEnabled then
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end
    end
end)

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if autoRejoinEnabled then
        task.wait(5)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
end)
