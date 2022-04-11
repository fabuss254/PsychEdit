-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")
local Object = require("src/libs/Classic")

local ListLayout = require("src/classes/layout/ListLayout")

local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")

-- Class
local class = Object:extend("Tab")

function class:new(Props)
    Props = Props or {}

    local Menu = Frame()
    Menu.Size = UDim2(0, Props.Size and Props.Size.X or 300, 0, Props.Size and Props.Size.Y or 300)
    Menu.Position = UDim2(0, Props.Position and Props.Position.X or (ScreenSize.X/2 - Menu.Size.X.Offset/2), 0, Props.Position and Props.Position.Y or (ScreenSize.Y/2 - Menu.Size.Y.Offset/2))
    Menu.Color = Color.FromRGB(104, 123, 153)
    --Menu:Ratio(0.5)

    local Shadow = Frame()
    Shadow.ZIndex = -1
    Shadow.Size = UDim2(1, 0, 1, 0)
    Shadow.Position = UDim2(.5, 10, .5, 10)
    Shadow.Anchor = Vector2.one/2
    Shadow.Color = Color.Black
    Shadow.Opacity = .75
    Shadow:SetParent(Menu)

    local Content = Frame()
    Content.Position = UDim2(.5, 0, 1, -2)
    Content.Anchor = Vector2(.5, 1)
    Content.Color = Menu.Color:Lerp(Color.Black, 0.5)
    Content.Size = UDim2(1, -4, 1, -22)
    Content:SetParent(Menu)

    local Topbar = Frame()
    Topbar.Size = UDim2(1, 0, 0, 20)
    Topbar.Opacity = 1

    Topbar.META.IsDragged = false
    Topbar:Connect("MouseClick", function(bool)
        if not bool then return end

        Topbar.META.IsDragged = true
        Topbar.META.Offset = Menu.Position:ToVector2(ScreenSize) - GetMousePosition()
    end)

    Topbar:Connect("Update", function(dt)
        if not Topbar.META.IsDragged then return end
        if not love.mouse.isDown(1) then
            Topbar.META.IsDragged = false
            return
        end

        local newPos = GetMousePosition() + Topbar.META.Offset
        Menu.Position = UDim2(newPos.X/ScreenSize.X, 0, newPos.Y/ScreenSize.Y, 0)
    end)

    local Title = Text(Fonts.ConsolaSmall)
    Title.Anchor = Vector2.one/2
    Title.Position = UDim2(.5, 0, .6, 0)
    Title:SetText(Props.Title or "Menu missing property 'Props.Title'")
    Title:SetParent(Topbar)

    local Icons = {
        {"close", function() Menu.Visible = false end}
    }
    for i,v in pairs(Icons) do
        local ButtonFrame = Frame()
        ButtonFrame.Anchor = Vector2.x
        ButtonFrame.Size = UDim2(0, 20, 1, 0)
        ButtonFrame.Position = UDim2(1, 0, 0, 0)
        ButtonFrame.Opacity = 1
        ButtonFrame.ZIndex = 2
        ButtonFrame.Color = Menu.Color:Lerp(Color.Black, 0.5)
        
        ButtonFrame:Connect("Hover", function(bool)
            ButtonFrame.Opacity = bool and 0 or 1
        end)

        ButtonFrame:Connect("MouseClick", function(bool)
            if not bool then return end
            v[2]()
        end)

        local Icon = Image("assets/images/icons/" .. v[1] .. "_icon.png")
        Icon.Anchor = Vector2.one/2
        Icon.Size = UDim2(1, 0, .75, 0)
        Icon:Ratio(1)
        Icon.ZIndex = 4
        Icon.Position = UDim2(.5, 0, .5, 0)
        Icon:SetParent(ButtonFrame)
        
        ButtonFrame:SetParent(Topbar)
    end

    -- Bottom right corner extensive
    local ResizeFrame = Frame()
    ResizeFrame.Position = UDim2(1, -4, 1, -4)
    ResizeFrame.ZIndex = 10
    ResizeFrame.Size = UDim2(0, 6, 0, 6)
    ResizeFrame.Anchor = Vector2.one
    ResizeFrame.Color = Menu.Color
    ResizeFrame:SetParent(Content)

    ResizeFrame.META.Holding = false
    ResizeFrame:Connect("Hover", function(bool)
        ResizeFrame.Color = bool and Menu.Color:Lerp(Color.White, 0.5) or Menu.Color
    end)

    ResizeFrame:Connect("MouseClick", function(bool)
        if not bool then return end

        ResizeFrame.META.Holding = true
    end)

    ResizeFrame:Connect("Update", function(dt)
        if not ResizeFrame.META.Holding then return end
        if not love.mouse.isDown(1) then
            ResizeFrame.META.Holding = false
            return
        end

        local NewSize = GetMousePosition() - Menu.Position:ToVector2(ScreenSize) + Vector2(8, 8)
        Menu.Size = UDim2(0, math.max(NewSize.X, Props.MinSize and Props.MinSize.X or Title.Size.X.Offset + 50), 0, math.max(NewSize.Y, Props.MinSize and Props.MinSize.Y or 100))
    end)

    Topbar:SetParent(Menu)

    self.Menu = Menu
    self.Topbar = Topbar
    self.Content = Content
end

return class