local Library = {}

-- Servisler
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Eski GUI temizliği
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "PremiumHub_V4" then gui:Destroy() end
end

local HubVisible = true
local ToggleKey = Enum.KeyCode.RightControl
local UserIconID = "rbxassetid://16844605170"

-- Executor ismini bulma fonksiyonu
local function GetExecutorName()
    local name = "Unknown"
    pcall(function()
        if identifyexecutor then
            name = identifyexecutor()
        end
    end)
    return name
end

function Library:CreateWindow(hubName, bgId)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumHub_V4"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ANA ÇERÇEVE
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

    -- Arkaplan Resmi ve Cam Efekti
    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Parent = MainFrame
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Image = bgId
    BackgroundImage.ScaleType = Enum.ScaleType.Crop
    BackgroundImage.ZIndex = 0
    Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 16)

    local Glass = Instance.new("Frame")
    Glass.Parent = MainFrame
    Glass.Size = UDim2.new(1, 0, 1, 0)
    Glass.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Glass.BackgroundTransparency = 0.4
    Glass.ZIndex = 1
    Instance.new("UICorner", Glass).CornerRadius = UDim.new(0, 16)

    -- YÜKLEME EKRANI (Animasyon)
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingFrame"
    LoadingFrame.Parent = ScreenGui
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LoadingFrame.Size = UDim2.new(0, 250, 0, 100)
    LoadingFrame.Position = UDim2.new(0.5, -125, 0.5, -50)
    LoadingFrame.ClipsDescendants = true
    Instance.new("UICorner", LoadingFrame).CornerRadius = UDim.new(0, 16)

    local LoadBg = BackgroundImage:Clone()
    LoadBg.Parent = LoadingFrame
    local LoadGlass = Glass:Clone()
    LoadGlass.Parent = LoadingFrame

    local LoadTitle = Instance.new("TextLabel")
    LoadTitle.Parent = LoadingFrame
    LoadTitle.Size = UDim2.new(1, 0, 0, 30)
    LoadTitle.Position = UDim2.new(0, 0, 0, 5)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.Text = hubName
    LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadTitle.Font = Enum.Font.FredokaOne
    LoadTitle.TextSize = 20
    LoadTitle.ZIndex = 2

    local StatusText = Instance.new("TextLabel")
    StatusText.Parent = LoadingFrame
    StatusText.Size = UDim2.new(1, 0, 0, 20)
    StatusText.Position = UDim2.new(0, 0, 0, 45)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.Font = Enum.Font.FredokaOne
    StatusText.TextSize = 13
    StatusText.ZIndex = 2

    local BarBackground = Instance.new("Frame")
    BarBackground.Parent = LoadingFrame
    BarBackground.Size = UDim2.new(0.8, 0, 0, 6)
    BarBackground.Position = UDim2.new(0.1, 0, 0, 75)
    BarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBackground.ZIndex = 2
    Instance.new("UICorner", BarBackground).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame")
    BarFill.Parent = BarBackground
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BarFill.ZIndex = 3
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        task.wait(0.5)
        StatusText.Text = "Detecting Executor..."
        TweenService:Create(BarFill, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
        task.wait(1.2)
        
        local execName = GetExecutorName()
        StatusText.Text = execName .. " Executor"
        TweenService:Create(BarFill, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
        task.wait(1.2)
        
        StatusText.Text = "Welcome..."
        TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(1)

        TweenService:Create(LoadTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(StatusText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(BarBackground, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)

        local morphTween = TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = MainFrame.Size,
            Position = MainFrame.Position
        })
        morphTween:Play()
        morphTween.Completed:Wait()

        MainFrame.Visible = true
        LoadingFrame:Destroy()
    end)

    -- TopBar & Butonlar
    local TopBar = Instance.new("Frame")
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 5

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

    local ButtonsBox = Instance.new("Frame")
    ButtonsBox.Parent = TopBar
    ButtonsBox.Position = UDim2.new(1, -70, 0, 0)
    ButtonsBox.Size = UDim2.new(0, 60, 1, 0)
    ButtonsBox.BackgroundTransparency = 1
    ButtonsBox.ZIndex = 6
    
    local UIListLayout = Instance.new("UIListLayout", ButtonsBox)
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout.Padding = UDim.new(0, 5)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = ButtonsBox
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.FredokaOne
    MinBtn.TextSize = 22

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = ButtonsBox
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.FredokaOne
    CloseBtn.TextSize = 18

    -- Sidebar & Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.Size = UDim2.new(0, 110, 1, -60)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ZIndex = 5
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.Position = UDim2.new(0, 130, 0, 50)
    Container.Size = UDim2.new(1, -140, 1, -60)
    Container.BackgroundTransparency = 1
    Container.ZIndex = 5

    -- Sürükleme (Drag) İşlemleri
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

    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = isMinimized and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 300)}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function() HubVisible = false; MainFrame.Visible = false end)
    UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.KeyCode == ToggleKey then HubVisible = not HubVisible; MainFrame.Visible = HubVisible end end)

    local Window = {}
    
    function Window:CreateTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = Sidebar
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = tabName
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.FredokaOne
        TabBtn.TextSize = 14
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Parent = Container
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        -- Otomatik olarak ilk sekmeyi seçme mantığı
        if #Sidebar:GetChildren() == 2 then -- İlk buton eklendiğinde (UIListLayout 1. çocuktur)
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
            local F = Instance.new("Frame")
            F.Size = UDim2.new(0.95, 0, 0, height)
            F.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            F.BackgroundTransparency = 0.7
            F.Parent = Page
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
            return F
        end

        -- NEW: AddLabel Function
        function Elements:AddLabel(text)
            local LabFrame = CreateElementFrame(30)
            local LabText = Instance.new("TextLabel")
            LabText.Size = UDim2.new(1, -20, 1, 0)
            LabText.Position = UDim2.new(0, 10, 0, 0)
            LabText.BackgroundTransparency = 1
            LabText.Text = text
            LabText.Font = Enum.Font.FredokaOne
            LabText.TextColor3 = Color3.fromRGB(200, 200, 200)
            LabText.TextSize = 13
            LabText.TextXAlignment = Enum.TextXAlignment.Left
            LabText.Parent = LabFrame

            local LabelFunc = {}
            function LabelFunc:SetText(newText)
                LabText.Text = newText
            end
            return LabelFunc
        end

        function Elements:AddDropdown(text, callback)
            local DropFrame = CreateElementFrame(40)
            DropFrame.ClipsDescendants = true
            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 40)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = text .. "  ▼"
            DropBtn.Font = Enum.Font.FredokaOne
            DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropBtn.TextSize = 14
            DropBtn.Parent = DropFrame
            local ItemList = Instance.new("Frame")
            ItemList.Position = UDim2.new(0, 0, 0, 40)
            ItemList.Size = UDim2.new(1, 0, 1, -40)
            ItemList.BackgroundTransparency = 1
            ItemList.Parent = DropFrame
            Instance.new("UIListLayout", ItemList)

            local open = false
            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                for _, v in pairs(ItemList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, player in pairs(Players:GetPlayers()) do
                    local pBtn = Instance.new("TextButton")
                    pBtn.Size = UDim2.new(1, 0, 0, 25)
                    pBtn.BackgroundTransparency = 1
                    pBtn.Text = player.Name
                    pBtn.Font = Enum.Font.FredokaOne
                    pBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    pBtn.TextSize = 13
                    pBtn.Parent = ItemList
                    pBtn.MouseButton1Click:Connect(function()
                        DropBtn.Text = player.Name .. "  ▼"
                        callback(player.Name)
                        open = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 40)}):Play()
                    end)
                end
                local targetHeight = open and (#Players:GetPlayers() * 25 + 45) or 40
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
            end)
        end

        function Elements:AddButton(text, callback)
            local BtnFrame = CreateElementFrame(40)
            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Size = UDim2.new(0.7, 0, 1, 0)
            BtnLabel.Position = UDim2.new(0, 10, 0, 0)
            BtnLabel.Text = text
            BtnLabel.Font = Enum.Font.FredokaOne
            BtnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            BtnLabel.TextSize = 15
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Parent = BtnFrame
            
            local ClickIcon = Instance.new("ImageButton")
            ClickIcon.Position = UDim2.new(1, -35, 0.5, -12.5)
            ClickIcon.Size = UDim2.new(0, 25, 0, 25)
            ClickIcon.BackgroundTransparency = 1
            ClickIcon.Image = UserIconID
            ClickIcon.Parent = BtnFrame
            
            ClickIcon.MouseButton1Click:Connect(function()
                 TweenService:Create(ClickIcon, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(150,150,150)}):Play()
                 task.wait(0.1)
                 TweenService:Create(ClickIcon, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
                 callback()
            end)
        end

        function Elements:AddSlider(text, min, max, default, callback)
            local SldFrame = CreateElementFrame(55)
            local SldTitle = Instance.new("TextLabel")
            SldTitle.Size = UDim2.new(1, 0, 0, 20)
            SldTitle.Position = UDim2.new(0, 10, 0, 5)
            SldTitle.Text = text
            SldTitle.Font = Enum.Font.FredokaOne
            SldTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SldTitle.TextSize = 14
            SldTitle.TextXAlignment = Enum.TextXAlignment.Left
            SldTitle.BackgroundTransparency = 1
            SldTitle.Parent = SldFrame

            local BarBg = Instance.new("Frame")
            BarBg.Position = UDim2.new(0, 10, 0, 30)
            BarBg.Size = UDim2.new(1, -20, 0, 15)
            BarBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            BarBg.ClipsDescendants = true
            BarBg.Parent = SldFrame
            Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.Parent = BarBg
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            local ValLbl = Instance.new("TextLabel")
            ValLbl.Size = UDim2.new(1, 0, 1, 0)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text = tostring(default)
            ValLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
            ValLbl.Font = Enum.Font.FredokaOne
            ValLbl.TextSize = 12
            ValLbl.Parent = BarBg

            local draggingSld = false
            local function move(input)
                local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(((max - min) * pos) + min)
                ValLbl.Text = tostring(val)
                callback(val)
            end
            BarBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSld = true move(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSld = false end end)
            UserInputService.InputChanged:Connect(function(input) if draggingSld and input.UserInputType == Enum.UserInputType.MouseMovement then move(input) end end)
        end

        function Elements:AddToggle(text, default, callback)
            local TglFrame = CreateElementFrame(40)
            local enabled = default

            local TglLabel = Instance.new("TextLabel")
            TglLabel.Size = UDim2.new(0.7, 0, 1, 0)
            TglLabel.Position = UDim2.new(0, 10, 0, 0)
            TglLabel.Text = text
            TglLabel.Font = Enum.Font.FredokaOne
            TglLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TglLabel.TextSize = 15
            TglLabel.TextXAlignment = Enum.TextXAlignment.Left
            TglLabel.BackgroundTransparency = 1
            TglLabel.Parent = TglFrame

            local TglBox = Instance.new("Frame")
            TglBox.Position = UDim2.new(1, -50, 0.5, -10)
            TglBox.Size = UDim2.new(0, 40, 0, 20)
            TglBox.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
            TglBox.Parent = TglFrame
            Instance.new("UICorner", TglBox).CornerRadius = UDim.new(1, 0)

            local InnerCircle = Instance.new("Frame")
            InnerCircle.Size = UDim2.new(0, 16, 0, 16)
            InnerCircle.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            InnerCircle.BackgroundColor3 = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            InnerCircle.Parent = TglBox
            Instance.new("UICorner", InnerCircle).CornerRadius = UDim.new(1, 0)

            local TglBtn = Instance.new("TextButton")
            TglBtn.Size = UDim2.new(1, 0, 1, 0)
            TglBtn.BackgroundTransparency = 1
            TglBtn.Text = ""
            TglBtn.Parent = TglFrame

            TglBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                TweenService:Create(TglBox, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(InnerCircle, TweenInfo.new(0.2), {
                    Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
                }):Play()
                callback(enabled)
            end)
        end

        return Elements
    end
    
    return Window
end

return Library
