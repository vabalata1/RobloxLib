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
    Background = Color3.fromRGB(30, 30, 32),
    Elevated = Color3.fromRGB(38, 38, 42),
    Stroke = Color3.fromRGB(60, 60, 66),
    Accent = Color3.fromRGB(0, 122, 255),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(180, 180, 190),
    Green = Color3.fromRGB(52, 199, 89),
    Red = Color3.fromRGB(255, 69, 58),
}

local function applyCorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
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
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomMacUI"
    gui.ResetOnSpawn = false
    gui.Parent = pickParentGui()

    local root = Instance.new("Frame")
    root.Name = "Window"
    root.Size = UDim2.fromOffset((options and options.Size and options.Size.X) or 560, (options and options.Size and options.Size.Y) or 420)
    root.Position = UDim2.fromScale(0.3, 0.3)
    root.BackgroundColor3 = theme.Background
    root.BorderSizePixel = 0
    root.Parent = gui
    applyCorner(root, 10)
    addStroke(root, theme.Stroke, 1)

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = theme.Elevated
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.Parent = root
    applyCorner(titleBar, 10)
    addStroke(titleBar, theme.Stroke, 1)
    addPadding(titleBar, 8)

    local titleText = newText(titleBar, title or "Window", 16, theme.Text, true)
    titleText.Size = UDim2.new(1, -120, 1, 0)
    titleText.Position = UDim2.fromOffset(12, 0)
    titleText.TextXAlignment = Enum.TextXAlignment.Left

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.AnchorPoint = Vector2.new(1, 0.5)
    controls.Position = UDim2.new(1, -8, 0.5, 0)
    controls.BackgroundTransparency = 1
    controls.Size = UDim2.fromOffset(96, 24)
    controls.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(24, 24)
    closeBtn.Position = UDim2.fromOffset(72, 0)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.BackgroundColor3 = theme.Red
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.AutoButtonColor = false
    applyCorner(closeBtn, 6)
    closeBtn.Parent = controls

    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.fromOffset(24, 24)
    miniBtn.Position = UDim2.fromOffset(40, 0)
    miniBtn.Text = "–"
    miniBtn.Font = Enum.Font.Gotham
    miniBtn.TextSize = 18
    miniBtn.BackgroundColor3 = theme.Green
    miniBtn.TextColor3 = Color3.new(1,1,1)
    miniBtn.AutoButtonColor = false
    applyCorner(miniBtn, 6)
    miniBtn.Parent = controls

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
    miniBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(pages, 0.15, {Size = minimized and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 1, -72)}):Play()
        tween(root, 0.15, {Size = minimized and UDim2.fromOffset(root.AbsoluteSize.X, 72) or UDim2.fromOffset(root.AbsoluteSize.X, (options and options.Size and options.Size.Y or 420))}):Play()
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

    function window:AddTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "_TabButton"
        tabButton.BackgroundColor3 = theme.Elevated
        tabButton.Text = name
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 14
        tabButton.TextColor3 = theme.Text
        tabButton.AutoButtonColor = false
        tabButton.Size = UDim2.fromOffset(110, 28)
        tabButton.Parent = tabBar
        applyCorner(tabButton, 6)
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

        if not page:IsDescendantOf(pages) then
            page.Parent = pages
        end

        if #pages:GetChildren() == 1 then
            pageContainerLayout:JumpTo(page)
        end

        tabButton.MouseButton1Click:Connect(function()
            pageContainerLayout:JumpTo(page)
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
            applyCorner(section, 8)
            addStroke(section, theme.Stroke, 1)
            addPadding(section, 10)

            local vlist = Instance.new("UIListLayout")
            vlist.FillDirection = Enum.FillDirection.Vertical
            vlist.SortOrder = Enum.SortOrder.LayoutOrder
            vlist.Padding = UDim.new(0, 6)
            vlist.Parent = section

            local header = newText(section, sectionName, 14, theme.SubText, true)
            header.Size = UDim2.new(1, 0, 0, 18)

            local sectionApi = {}

            function sectionApi:AddButton(text, callback)
                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 28)
                row.Parent = section

                local button = newButtonText(row, text, 14, theme.Text)
                button.Size = UDim2.new(1, 0, 1, 0)
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)

                local underline = Instance.new("Frame")
                underline.BackgroundColor3 = theme.Accent
                underline.BorderSizePixel = 0
                underline.AnchorPoint = Vector2.new(0,1)
                underline.Position = UDim2.new(0, 0, 1, 0)
                underline.Size = UDim2.new(0, 0, 0, 2)
                underline.Parent = row

                button.MouseEnter:Connect(function()
                    tween(underline, 0.12, {Size = UDim2.new(1, 0, 0, 2)}):Play()
                end)
                button.MouseLeave:Connect(function()
                    tween(underline, 0.12, {Size = UDim2.new(0, 0, 0, 2)}):Play()
                end)
            end

            function sectionApi:AddToggle(label, defaultOn)
                local changed = createSignal()
                local state = defaultOn == true

                local row = Instance.new("Frame")
                row.BackgroundTransparency = 1
                row.Size = UDim2.new(1, 0, 0, 28)
                row.Parent = section

                local text = newText(row, label, 14, theme.Text, false)
                text.Size = UDim2.new(1, -56, 1, 0)

                local knob = Instance.new("Frame")
                knob.AnchorPoint = Vector2.new(1, 0.5)
                knob.Position = UDim2.new(1, -4, 0.5, 0)
                knob.Size = UDim2.fromOffset(44, 22)
                knob.BackgroundColor3 = state and theme.Accent or theme.Stroke
                knob.Parent = row
                applyCorner(knob, 22)

                local circle = Instance.new("Frame")
                circle.Size = UDim2.fromOffset(18, 18)
                circle.Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
                circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
                circle.Parent = knob
                applyCorner(circle, 18)

                local function setOn(on)
                    state = on
                    tween(knob, 0.12, {BackgroundColor3 = on and theme.Accent or theme.Stroke}):Play()
                    tween(circle, 0.12, {Position = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)}):Play()
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
                row.Size = UDim2.new(1, 0, 0, 40)
                row.Parent = section

                local top = Instance.new("Frame")
                top.BackgroundTransparency = 1
                top.Size = UDim2.new(1, 0, 0, 18)
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
                bar.Size = UDim2.new(1, 0, 0, 6)
                bar.Position = UDim2.fromOffset(0, 22)
                bar.Parent = row
                applyCorner(bar, 3)

                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = theme.Accent
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new((value - minValue)/(maxValue - minValue), 0, 1, 0)
                fill.Parent = bar
                applyCorner(fill, 3)

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