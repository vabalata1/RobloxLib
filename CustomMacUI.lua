local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function createSignal()
    local bindable = Instance.new("BindableEvent")
    local signal = {}
    function signal:Connect(fn) return bindable.Event:Connect(fn) end
    function signal:Fire(...) bindable:Fire(...) end
    function signal:Destroy() bindable:Destroy() end
    return signal
end

local function tween(object, time, props, style, dir)
    return TweenService:Create(object, TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function pickParentGui()
    if RunService:IsStudio() then
        local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        return pg or Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        local CoreGui = game:GetService("CoreGui")
        return CoreGui
    end
end

local DefaultTheme = {
    Background = Color3.fromRGB(22, 22, 24),
    Elevated = Color3.fromRGB(30, 30, 32),
    Stroke = Color3.fromRGB(58, 58, 62),
    Accent = Color3.fromRGB(10, 132, 255),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(170, 170, 178),
    Green = Color3.fromRGB(48, 209, 88),
    Red = Color3.fromRGB(255, 69, 58),
    Yellow = Color3.fromRGB(255, 214, 10),
    TrafficRed = Color3.fromRGB(255, 95, 86),
    TrafficYellow = Color3.fromRGB(255, 189, 46),
    TrafficGreen = Color3.fromRGB(39, 201, 63),
}

local function applyCorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = instance
end

local function addStroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = instance
    return s
end

local function addPadding(container, px)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    p.PaddingLeft = UDim.new(0, px)
    p.PaddingRight = UDim.new(0, px)
    p.Parent = container
end

local function addShadow(parent)
    parent.ClipsDescendants = false
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "WindowShadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857472" -- soft drop shadow
    shadow.ImageTransparency = 0.25
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    shadow.ZIndex = 0
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.fromOffset(-20, -20)
    shadow.Parent = parent
    return shadow
end

local function newText(parent, text, size, color, bold)
    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Text = text
    t.Font = Enum.Font.Gotham
    t.TextSize = size
    t.TextColor3 = color
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = parent
    return t
end

local function newButtonText(parent, text, size, color)
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = size
    b.TextColor3 = color
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.Parent = parent
    return b
end

local Library = {}
Library.__index = Library

function Library:CreateWindow(title, options)
    local theme = table.clone and table.clone(DefaultTheme) or {
        Background = DefaultTheme.Background,
        Elevated = DefaultTheme.Elevated,
        Stroke = DefaultTheme.Stroke,
        Accent = DefaultTheme.Accent,
        Text = DefaultTheme.Text,
        SubText = DefaultTheme.SubText,
        Green = DefaultTheme.Green,
        Red = DefaultTheme.Red,
        Yellow = DefaultTheme.Yellow,
        TrafficRed = DefaultTheme.TrafficRed,
        TrafficYellow = DefaultTheme.TrafficYellow,
        TrafficGreen = DefaultTheme.TrafficGreen,
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomMacUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = pickParentGui()

    local root = Instance.new("Frame")
    root.Name = "Window"
    root.Size = UDim2.fromOffset((options and options.Size and options.Size.X) or 600, (options and options.Size and options.Size.Y) or 440)
    root.Position = UDim2.fromScale(0.3, 0.25)
    root.BackgroundColor3 = theme.Background
    root.BorderSizePixel = 0
    root.ZIndex = 1
    root.Parent = gui
    applyCorner(root, 12)
    addStroke(root, theme.Stroke, 1)
    addShadow(root)

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = theme.Elevated
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.Parent = root
    applyCorner(titleBar, 12)
    addStroke(titleBar, theme.Stroke, 1)
    addPadding(titleBar, 8)

    -- Traffic lights container (left)
    local traffic = Instance.new("Frame")
    traffic.Name = "TrafficLights"
    traffic.BackgroundTransparency = 1
    traffic.Size = UDim2.fromOffset(72, 20)
    traffic.Position = UDim2.fromOffset(10, 8)
    traffic.Parent = titleBar

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = traffic

    local function makeLight(color)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = color
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Size = UDim2.fromOffset(14, 14)
        btn.BackgroundTransparency = 0
        btn.Parent = traffic
        applyCorner(btn, 7)
        addStroke(btn, Color3.fromRGB(0,0,0), 0.5).Transparency = 0.7
        btn.MouseEnter:Connect(function()
            tween(btn, 0.12, {BackgroundTransparency = 0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, 0.12, {BackgroundTransparency = 0}):Play()
        end)
        return btn
    end

    local closeBtn = makeLight(theme.TrafficRed)
    local minBtn = makeLight(theme.TrafficYellow)
    local zoomBtn = makeLight(theme.TrafficGreen)

    -- Centered title
    local titleText = newText(titleBar, title or "Window", 15, theme.Text, true)
    titleText.Size = UDim2.new(1, -180, 1, 0)
    titleText.Position = UDim2.fromOffset(90, 0)
    titleText.TextXAlignment = Enum.TextXAlignment.Center

    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.BackgroundColor3 = theme.Background
    tabBar.BorderSizePixel = 0
    tabBar.Size = UDim2.new(1, 0, 0, 36)
    tabBar.Position = UDim2.fromOffset(0, 36)
    tabBar.Parent = root
    addStroke(tabBar, theme.Stroke, 1)

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabList.Padding = UDim.new(0, 8)
    tabList.Parent = tabBar

    local pages = Instance.new("Frame")
    pages.Name = "Pages"
    pages.BackgroundColor3 = theme.Background
    pages.BorderSizePixel = 0
    pages.Position = UDim2.fromOffset(0, 72)
    pages.Size = UDim2.new(1, 0, 1, -72)
    pages.Parent = root

    local pageContainerLayout = Instance.new("UIPageLayout")
    pageContainerLayout.FillDirection = Enum.FillDirection.Horizontal
    pageContainerLayout.EasingDirection = Enum.EasingDirection.Out
    pageContainerLayout.EasingStyle = Enum.EasingStyle.Quad
    pageContainerLayout.Padding = UDim.new(0, 0)
    pageContainerLayout.TweenTime = 0.15
    pageContainerLayout.Parent = pages

    makeDraggable(root, titleBar)

    local minimized = false
    local zoomed = false
    local originalSize = root.Size

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(pages, 0.15, {Size = minimized and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 1, -72)}):Play()
        tween(root, 0.15, {Size = minimized and UDim2.fromOffset(root.AbsoluteSize.X, 72) or originalSize}):Play()
    end)

    zoomBtn.MouseButton1Click:Connect(function()
        zoomed = not zoomed
        if zoomed then
            originalSize = root.Size
            tween(root, 0.18, {Size = UDim2.fromOffset(math.max(720, root.AbsoluteSize.X + 120), math.max(520, root.AbsoluteSize.Y + 80))}):Play()
        else
            tween(root, 0.18, {Size = originalSize}):Play()
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local window = {}
    window.__index = window

    function window:SetTheme(newTheme)
        for k, v in pairs(newTheme) do
            theme[k] = v
        end
        root.BackgroundColor3 = theme.Background
        titleBar.BackgroundColor3 = theme.Elevated
        tabBar.BackgroundColor3 = theme.Background
    end

    local currentTabButton = nil
    local function styleTabButton(btn, selected)
        if selected then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = theme.Elevated:Lerp(theme.Accent, 0.2)
            btn.TextColor3 = theme.Text
        else
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = theme.Elevated
            btn.TextColor3 = theme.SubText
        end
    end

    function window:AddTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "_TabButton"
        tabButton.BackgroundColor3 = theme.Elevated
        tabButton.Text = name
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14
        tabButton.TextColor3 = theme.SubText
        tabButton.AutoButtonColor = false
        tabButton.Size = UDim2.fromOffset(120, 28)
        tabButton.Parent = tabBar
        applyCorner(tabButton, 8)
        addStroke(tabButton, theme.Stroke, 1)

        local page = Instance.new("Frame")
        page.Name = name .. "_Page"
        page.BackgroundTransparency = 1
        page.Size = UDim2.fromScale(1, 1)
        page.Parent = pages

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.BackgroundTransparency = 1
        content.Position = UDim2.fromOffset(10, 10)
        content.Size = UDim2.new(1, -20, 1, -20)
        content.Parent = page

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 8)
        list.Parent = content

        if #pages:GetChildren() == 1 then
            pageContainerLayout:JumpTo(page)
            styleTabButton(tabButton, true)
            currentTabButton = tabButton
        end

        tabButton.MouseButton1Click:Connect(function()
            pageContainerLayout:JumpTo(page)
            if currentTabButton and currentTabButton ~= tabButton then
                styleTabButton(currentTabButton, false)
            end
            styleTabButton(tabButton, true)
            currentTabButton = tabButton
        end)

        tabButton.MouseEnter:Connect(function()
            if currentTabButton ~= tabButton then
                tween(tabButton, 0.1, {BackgroundColor3 = theme.Elevated:Lerp(theme.Accent, 0.05)}):Play()
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if currentTabButton ~= tabButton then
                tween(tabButton, 0.12, {BackgroundColor3 = theme.Elevated}):Play()
            end
        end)

        local tab = {}
        tab.__index = tab

        function tab:AddSection(sectionName)
            local section = Instance.new("Frame")
            section.Name = sectionName .. "_Section"
            section.BackgroundColor3 = theme.Elevated
            section.BorderSizePixel = 0
            section.Size = UDim2.new(1, 0, 0, 56)
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.Parent = content
            applyCorner(section, 10)
            addStroke(section, theme.Stroke, 1)
            addPadding(section, 12)

            local vlist = Instance.new("UIListLayout")
            vlist.FillDirection = Enum.FillDirection.Vertical
            vlist.SortOrder = Enum.SortOrder.LayoutOrder
            vlist.Padding = UDim.new(0, 8)
            vlist.Parent = section

            local header = newText(section, sectionName, 14, theme.SubText, true)
            header.Size = UDim2.new(1, 0, 0, 18)

            local sectionApi = {}

            function sectionApi:AddButton(text, callback)
                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 32)
                row.Parent = section

                local button = Instance.new("TextButton")
                button.Text = text
                button.Font = Enum.Font.Gotham
                button.TextSize = 14
                button.TextColor3 = theme.Text
                button.AutoButtonColor = false
                button.Size = UDim2.new(0, 180, 1, 0)
                button.BackgroundColor3 = theme.Elevated
                button.Parent = row
                applyCorner(button, 8)
                addStroke(button, theme.Stroke, 1)

                button.MouseEnter:Connect(function()
                    tween(button, 0.12, {BackgroundColor3 = theme.Elevated:Lerp(theme.Accent, 0.08)}):Play()
                end)
                button.MouseLeave:Connect(function()
                    tween(button, 0.12, {BackgroundColor3 = theme.Elevated}):Play()
                end)
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end

            function sectionApi:AddToggle(label, defaultOn)
                local changed = createSignal()
                local state = defaultOn == true

                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 32)
                row.Parent = section

                local text = newText(row, label, 14, theme.Text, false)
                text.Size = UDim2.new(1, -60, 1, 0)

                local knob = Instance.new("Frame")
                knob.AnchorPoint = Vector2.new(1, 0.5)
                knob.Position = UDim2.new(1, -4, 0.5, 0)
                knob.Size = UDim2.fromOffset(46, 24)
                knob.BackgroundColor3 = state and theme.Accent or theme.Stroke
                knob.Parent = row
                applyCorner(knob, 24)

                local circle = Instance.new("Frame")
                circle.Size = UDim2.fromOffset(20, 20)
                circle.Position = state and UDim2.fromOffset(46 - 24, 2) or UDim2.fromOffset(2, 2)
                circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
                circle.Parent = knob
                applyCorner(circle, 20)

                local function setOn(on)
                    state = on
                    tween(knob, 0.12, {BackgroundColor3 = on and theme.Accent or theme.Stroke}):Play()
                    tween(circle, 0.12, {Position = on and UDim2.fromOffset(46 - 24, 2) or UDim2.fromOffset(2, 2)}):Play()
                    changed:Fire(state)
                end

                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        setOn(not state)
                    end
                end)

                local api = {}
                function api:Get() return state end
                function api:Set(on) setOn(on) end
                api.Changed = changed
                function api:Destroy()
                    changed:Destroy()
                    row:Destroy()
                end
                return api
            end

            function sectionApi:AddSlider(label, defaultValue, minValue, maxValue, step)
                local changed = createSignal()
                local value = math.clamp(defaultValue or minValue, minValue, maxValue)
                local stepValue = step or 1

                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 48)
                row.Parent = section

                local top = Instance.new("Frame")
                top.BackgroundTransparency = 1
                top.Size = UDim2.new(1, 0, 0, 20)
                top.Parent = row

                local text = newText(top, label, 14, theme.Text, false)
                text.Size = UDim2.new(1, -60, 1, 0)

                local valueText = newText(top, tostring(value), 14, theme.SubText, false)
                valueText.Size = UDim2.new(0, 60, 1, 0)
                valueText.Position = UDim2.new(1, -60, 0, 0)
                valueText.TextXAlignment = Enum.TextXAlignment.Right

                local bar = Instance.new("Frame")
                bar.BackgroundColor3 = theme.Stroke
                bar.BorderSizePixel = 0
                bar.Size = UDim2.new(1, 0, 0, 8)
                bar.Position = UDim2.fromOffset(0, 24)
                bar.Parent = row
                applyCorner(bar, 4)

                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = theme.Accent
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new((value - minValue)/(maxValue - minValue), 0, 1, 0)
                fill.Parent = bar
                applyCorner(fill, 4)

                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(12, 12)
                knob.AnchorPoint = Vector2.new(0.5, 0.5)
                knob.Position = UDim2.new((value - minValue)/(maxValue - minValue), 0, 0.5, 0)
                knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                knob.Parent = bar
                applyCorner(knob, 6)
                addStroke(knob, theme.Stroke, 1)

                local dragging = false
                local function setFromX(px)
                    local rel = math.clamp(px / bar.AbsoluteSize.X, 0, 1)
                    local raw = minValue + rel * (maxValue - minValue)
                    local snapped = math.floor((raw + stepValue/2)/stepValue) * stepValue
                    snapped = math.clamp(snapped, minValue, maxValue)
                    value = snapped
                    valueText.Text = tostring(value)
                    fill.Size = UDim2.new((value - minValue)/(maxValue - minValue), 0, 1, 0)
                    knob.Position = UDim2.new((value - minValue)/(maxValue - minValue), 0, 0.5, 0)
                    changed:Fire(value)
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        setFromX((input.Position.X - bar.AbsolutePosition.X))
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        setFromX(input.Position.X - bar.AbsolutePosition.X)
                    end
                end)

                local api = {}
                function api:Get() return value end
                function api:Set(v)
                    v = math.clamp(v, minValue, maxValue)
                    local rel = (v - minValue)/(maxValue - minValue)
                    value = v
                    valueText.Text = tostring(value)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, 0, 0.5, 0)
                    changed:Fire(value)
                end
                api.Changed = changed
                function api:Destroy()
                    changed:Destroy()
                    row:Destroy()
                end
                return api
            end

            return sectionApi
        end

        return tab
    end

    function window:Destroy()
        gui:Destroy()
    end

    function window:SetTitle(newTitle)
        titleText.Text = newTitle
    end

    return setmetatable({
        SetTheme = function(_, t) window.SetTheme(window, t) end,
        AddTab = function(_, n) return window.AddTab(window, n) end,
        Destroy = function(_) window.Destroy(window) end,
        SetTitle = function(_, t) window.SetTitle(window, t) end,
    }, window)
end

local exported = setmetatable({}, Library)
return exported