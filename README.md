# CustomMacUI

Librairie UI minimaliste pour Roblox inspirée de macOS. Inclut fenêtre, onglets, sections, boutons, toggles et sliders.

## Installation
- Placez `CustomMacUI.lua` dans `ReplicatedStorage` (ou un autre conteneur).
- `require` le module depuis un LocalScript.

## Exemple
```lua
local CustomMacUI = require(ReplicatedStorage:WaitForChild("CustomMacUI"))

local win = CustomMacUI:CreateWindow("Mon Outil", { Size = Vector2.new(600, 420) })

local main = win:AddTab("Main")
local section = main:AddSection("Contrôles")

section:AddButton("Ping", function()
    print("Ping!")
end)

local autoFarm = section:AddToggle("Auto Farm", false)
autoFarm.Changed:Connect(function(on)
    print("AutoFarm:", on)
end)

local speed = section:AddSlider("Speed", 16, 0, 100, 1)
speed.Changed:Connect(function(v)
    print("Speed:", v)
end)
```

## Fonctions
- CreateWindow(title, options)
- AddTab(name)
- AddSection(name)
- Section:AddButton(text, callback)
- Section:AddToggle(label, defaultOn) -> api { Get, Set, Changed }
- Section:AddSlider(label, default, min, max, step) -> api { Get, Set, Changed }

## À venir
- Dropdown, keybind, textbox, colorpicker, thèmes clairs/sombres, sauvegarde des valeurs.