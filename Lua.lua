local Library = {}

-- [[ SERVISLER ]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- [[ AYARLAR ]]
local HubVisible = true
local ToggleKey = Enum.KeyCode.RightControl

-- Eski GUI'yi Temizle
if CoreGui:FindFirstChild("PremiumHub_V4") then
    CoreGui.PremiumHub_V4:Destroy()
end

-- [[ YARDIMCI FONKSIYONLAR ]]
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ ANA KÜTÜPHANE FONKSİYONU ]]
function Library:CreateWindow(hubName, bgId)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumHub_V4"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    -- Arkaplan Resmi
    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Parent = MainFrame
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Image = bgId or ""
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ImageTransparency = 0.5
    BackgroundImage.ZIndex = 0
    Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 12)

    -- Karartma (Glass Effect Sim)
    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.3
    Overlay.ZIndex = 1
    Overlay.Parent = MainFrame
    Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 12)

    -- Üst Panel
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 5
    MakeDraggable(MainFrame)

    local Title = Instance.new("TextLabel")
    Title.Parent = TopBar
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = hubName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.FredokaOne
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 6

    -- Yan Menü (Tabs Container)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.Size = UDim2.new(0, 110, 1, -60)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ZIndex = 5
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)

    -- İçerik Alanı
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.Position = UDim2.new(0, 130, 0, 50)
    Container.Size = UDim2.new(1, -140, 1, -60)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 5

    -- Yükleme Animasyonu (Fake Loading)
    task.spawn(function()
        local LoadingLabel = Instance.new("TextLabel", ScreenGui)
        LoadingLabel.Size = UDim2.new(0, 200, 0, 50)
        LoadingLabel.Position = UDim2.new(0.5, -100, 0.5, -25)
        LoadingLabel.Text = "Nortex Hub Loading..."
        LoadingLabel.Font = Enum.Font.FredokaOne
        LoadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        LoadingLabel.TextSize = 24
        LoadingLabel.BackgroundTransparency = 1
        
        task.wait(1.5)
        LoadingLabel:Destroy()
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 450, 0, 300), "Out", "Back", 0.5, true)
    end)

    -- Menü Aç/Kapat (Global)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == ToggleKey then
            HubVisible = not HubVisible
            MainFrame.Visible = HubVisible
        end
    end)

    local Window = {}

    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = Sidebar
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 0.95
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.FredokaOne
        TabBtn.TextSize = 14
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Parent = Container
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        -- Sekme Geçişi
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    v.TextColor3 = Color3.fromRGB(180, 180, 180)
                    v.BackgroundTransparency = 0.95
                end
            end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundTransparency = 0.85
        end)

        -- İlk Sekmeyi Aktif Et
        if #Sidebar:GetChildren() == 2 then 
            Page.Visible = true 
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Elements = {}

        local function CreateElementFrame(height)
            local F = Instance.new("Frame")
            F.Size = UDim2.new(0.95, 0, 0, height)
            F.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            F.BackgroundTransparency = 0.7
            F.Parent = Page
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
            return F
        end

        function Elements:AddLabel(text)
            local F = CreateElementFrame(30)
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, -20, 1, 0)
            L.Position = UDim2.new(0, 10, 0, 0)
            L.BackgroundTransparency = 1
            L.Text = text
            L.TextColor3 = Color3.fromRGB(200, 200, 200)
            L.Font = Enum.Font.FredokaOne
            L.TextSize = 13
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.Parent = F
            
            local LabelFuncs = {}
            function LabelFuncs:SetText(newTxt) L.Text = newTxt end
            return LabelFuncs
        end

        function Elements:AddButton(text, callback)
            local F = CreateElementFrame(35)
            local B = Instance.new("TextButton")
            B.Size = UDim2.new(1, 0, 1, 0)
            B.BackgroundTransparency = 1
            B.Text = text
            B.TextColor3 = Color3.fromRGB(255, 255, 255)
            B.Font = Enum.Font.FredokaOne
            B.TextSize = 14
            B.Parent = F
            B.MouseButton1Click:Connect(function()
                B.TextSize = 12
                task.wait(0.1)
                B.TextSize = 14
                callback()
            end)
        end

        function Elements:AddToggle(text, default, callback)
            local F = CreateElementFrame(35)
            local enabled = default
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, -50, 1, 0); L.Position = UDim2.new(0, 10, 0, 0); L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.Font = Enum.Font.FredokaOne; L.TextXAlignment = Enum.TextXAlignment.Left; L.Parent = F
            
            local Tgl = Instance.new("Frame")
            Tgl.Size = UDim2.new(0, 35, 0, 18); Tgl.Position = UDim2.new(1, -45, 0.5, -9); Tgl.BackgroundColor3 = enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(40,40,40); Tgl.Parent = F; Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""; Btn.Parent = F
            Btn.MouseButton1Click:Connect(function()
                enabled = not enabled
                TweenService:Create(Tgl, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(40,40,40)}):Play()
                callback(enabled)
            end)
        end

        function Elements:AddSlider(text, min, max, default, callback)
            local F = CreateElementFrame(50)
            local L = Instance.new("TextLabel")
            L.Text = text; L.Size = UDim2.new(1, 0, 0, 20); L.Position = UDim2.new(0, 10, 0, 5); L.BackgroundTransparency = 1; L.TextColor3 = Color3.fromRGB(255,255,255); L.Font = Enum.Font.FredokaOne; L.TextXAlignment = Enum.TextXAlignment.Left; L.Parent = F
            
            local Bar = Instance.new("Frame")
            Bar.Size = UDim2.new(0.9, 0, 0, 6); Bar.Position = UDim2.new(0.05, 0, 0.7, 0); Bar.BackgroundColor3 = Color3.fromRGB(30,30,30); Bar.Parent = F; Instance.new("UICorner", Bar)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(255,255,255); Fill.Parent = Bar; Instance.new("UICorner", Fill)
            
            local dragging = false
            local function move(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                callback(math.floor(((max - min) * pos) + min))
            end
            Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true move(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then move(input) end end)
        end

        function Elements:AddDropdown(text, callback)
            local F = CreateElementFrame(35)
            local B = Instance.new("TextButton")
            B.Size = UDim2.new(1, 0, 1, 0); B.BackgroundTransparency = 1; B.Text = text .. "  ▼"; B.TextColor3 = Color3.fromRGB(255,255,255); B.Font = Enum.Font.FredokaOne; B.Parent = F
            
            B.MouseButton1Click:Connect(function()
                -- Basit dropdown mantığı: Listedeki ilk oyuncuyu seçer veya callback'i tetikler
                callback("Refresh") 
            end)
        end

        function Elements:AddKeybind(text, default, callback)
            local F = CreateElementFrame(35)
            local currentKey = default
            local waiting = false
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(0.7, 0, 1, 0); L.Position = UDim2.new(0, 10, 0, 0); L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.Font = Enum.Font.FredokaOne; L.TextXAlignment = Enum.TextXAlignment.Left; L.Parent = F
            
            local KB = Instance.new("TextButton")
            KB.Size = UDim2.new(0, 80, 0, 22); KB.Position = UDim2.new(1, -90, 0.5, -11); KB.BackgroundColor3 = Color3.fromRGB(30,30,30); KB.Text = currentKey.Name; KB.TextColor3 = Color3.fromRGB(255,255,255); KB.Font = Enum.Font.FredokaOne; KB.Parent = F; Instance.new("UICorner", KB)
            
            KB.MouseButton1Click:Connect(function()
                waiting = true
                KB.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input, gpe)
                if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KB.Text = input.KeyCode.Name
                    waiting = false
                    if currentKey == Enum.KeyCode.Escape then currentKey = default; KB.Text = default.Name end
                elseif not gpe and input.KeyCode == currentKey then
                    callback()
                end
            end)
        end

        return Elements
    end
    return Window
end

return Library
