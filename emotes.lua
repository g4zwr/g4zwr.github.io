local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

local function scl(ax, v)
    local t = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local rW, rH = 1920, 1080
    local m = t and 2 or 1.5
    local vs = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    if ax == "X" then return v * (vs.X / rW) * m
    elseif ax == "Y" then return v * (vs.Y / rH) * m end
end

local function gSv(n)
    local gs = type(cloneref) == "function" and cloneref or function(...) return ... end
    return gs(game:GetService(n))
end

local srv = setmetatable({}, {__index = function(_, n) return gSv(n) end})
local rIdC = {}

local function gRId(inp)
    local function rSg(id)
        local nI = tonumber(id)
        if not nI then return nil end
        if rIdC[nI] then return rIdC[nI] end
        local rI = nil
        pcall(function()
            local d = Instance.new("HumanoidDescription")
            d.WalkAnimation = nI; d.RunAnimation = nI; d.JumpAnimation = nI
            d.FallAnimation = nI; d.ClimbAnimation = nI; d.SwimAnimation = nI
            local dm = srv.Players:CreateHumanoidModelFromDescription(d, Enum.HumanoidRigType.R15)
            local an = dm:FindFirstChild("Animate")
            if an then
                for _, f in ipairs(an:GetChildren()) do
                    if f:IsA("Folder") and string.lower(f.Name) ~= "idle" then
                        for _, c in ipairs(f:GetChildren()) do
                            if c:IsA("Animation") and c.AnimationId ~= "" then
                                rI = tonumber(c.AnimationId:match("%d+"))
                                if rI then break end
                            end
                        end
                    end
                    if rI then break end
                end
            end
            dm:Destroy()
        end)
        if rI then rIdC[nI] = rI return rI end
        pcall(function()
            local ob = game:GetObjects("rbxassetid://" .. tostring(nI))
            if ob and #ob > 0 then
                local function sc(cn)
                    if cn:IsA("Animation") and cn.AnimationId ~= "" then
                        rI = tonumber(cn.AnimationId:match("%d+"))
                        if rI then return end
                    end
                    for _, c in ipairs(cn:GetChildren()) do
                        if rI then return end
                        sc(c)
                    end
                end
                sc(ob[1])
            end
        end)
        if rI then rIdC[nI] = rI end
        return rI
    end
    if type(inp) == "table" then
        local t = {}
        for k, v in pairs(inp) do t[k] = rSg(v) end
        return t
    end
    return rSg(inp)
end

local Plrs = srv.Players
local RS = srv.RunService
local TS = srv.TweenService
local AES = srv.AvatarEditorService
local HS = srv.HttpService

local ldG = Instance.new("ScreenGui")
ldG.Name = "GazeLoadingGUI"
ldG.DisplayOrder = 1000
ldG.ResetOnSpawn = false
ldG.IgnoreGuiInset = true
ldG.ScreenInsets = Enum.ScreenInsets.None
ldG.Parent = srv.CoreGui

local ldF = Instance.new("Frame")
ldF.Size = UDim2.new(0, scl("X", 300), 0, scl("Y", 110))
ldF.AnchorPoint = Vector2.new(0.5, 0.5)
ldF.Position = UDim2.new(0.5, 0, 0.5, 0)
ldF.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ldF.BackgroundTransparency = 0.1
ldF.Parent = ldG
do
    local c = Instance.new("UICorner", ldF); c.CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", ldF); st.Color = Color3.fromRGB(90, 90, 90); st.Thickness = 1.5
end

local ldT = Instance.new("TextLabel")
ldT.Size = UDim2.new(1, 0, 0, scl("Y", 30))
ldT.Position = UDim2.new(0, 0, 0, scl("Y", 8))
ldT.BackgroundTransparency = 1
ldT.Text = "Gaze Emotes"
ldT.TextColor3 = Color3.new(1, 1, 1)
ldT.Font = Enum.Font.GothamBold
ldT.TextScaled = true
ldT.Parent = ldF

local ldS = Instance.new("TextLabel")
ldS.Size = UDim2.new(1, -scl("X", 20), 0, scl("Y", 20))
ldS.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 42))
ldS.BackgroundTransparency = 1
ldS.Text = "Starting..."
ldS.TextColor3 = Color3.fromRGB(200, 200, 200)
ldS.Font = Enum.Font.Gotham
ldS.TextScaled = true
ldS.Parent = ldF

local ldB = Instance.new("Frame")
ldB.Size = UDim2.new(1, -scl("X", 40), 0, scl("Y", 14))
ldB.Position = UDim2.new(0, scl("X", 20), 0, scl("Y", 70))
ldB.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ldB.Parent = ldF
do
    local c = Instance.new("UICorner", ldB); c.CornerRadius = UDim.new(0, 7)
end

local ldFill = Instance.new("Frame")
ldFill.Size = UDim2.new(0, 0, 1, 0)
ldFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
ldFill.Parent = ldB
do
    local c = Instance.new("UICorner", ldFill); c.CornerRadius = UDim.new(0, 7)
end

local ldPct = Instance.new("TextLabel")
ldPct.Size = UDim2.new(1, 0, 0, scl("Y", 16))
ldPct.Position = UDim2.new(0, 0, 0, scl("Y", 88))
ldPct.BackgroundTransparency = 1
ldPct.Text = "0%"
ldPct.TextColor3 = Color3.new(1, 1, 1)
ldPct.Font = Enum.Font.GothamBold
ldPct.TextScaled = true
ldPct.Parent = ldF

local LOAD_TOTAL = 12
local ldN = 0
local function loadStep(txt)
    ldN = math.min(ldN + 1, LOAD_TOTAL)
    ldFill.Size = UDim2.new(ldN / LOAD_TOTAL, 0, 1, 0)
    ldPct.Text = math.floor(ldN / LOAD_TOTAL * 100) .. "%"
    ldS.Text = txt
    RS.RenderStepped:Wait()
end

local lP = Plrs.LocalPlayer
local chr = lP.Character or lP.CharacterAdded:Wait()
local hum = chr:WaitForChild("Humanoid")
local r6 = hum.RigType == Enum.HumanoidRigType.R6
local lPs = chr.PrimaryPart and chr.PrimaryPart.Position or Vector3.new()

local tRef, cTRef, sTRef, cFRef, sFRef

lP.CharacterAdded:Connect(function(nc)
    chr = nc
    hum = nc:WaitForChild("Humanoid")
    r6 = hum.RigType == Enum.HumanoidRigType.R6
    if tRef then tRef.Text = r6 and "GAZE SMOTES" or "Gaze Emotes" end
    if cTRef then cTRef.Text = r6 and "Anim" or "Catalog" end
    if sTRef then sTRef.Visible = not r6 end
    if r6 and cFRef and sFRef then
        cFRef.Visible = true; sFRef.Visible = false
        cTRef.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        sTRef.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end
    lPs = chr.PrimaryPart and chr.PrimaryPart.Position or Vector3.new()
end)

local cfg = {
    ["Stop Emote When Moving"] = true, ["Fade In"] = 0.1, ["Fade Out"] = 0.1,
    ["Weight"] = 1, ["Speed"] = 1, ["Time Position"] = 0, ["Freeze On Finish"] = false,
    ["Looped"] = true, ["Stop Other Animations On Play"] = true, ["High Priority"] = true,
    _s = {}, _t = {}
}

local sEmt = {}
local sFn = "GazeEmotes_NewNEWN3WSaved.json"

local function svEmt()
    pcall(function() if writefile then writefile(sFn, HS:JSONEncode(sEmt)) end end)
end

local function lEmt()
    local s, r = pcall(function()
        if readfile and isfile and isfile(sFn) then return HS:JSONDecode(readfile(sFn)) end
        return {}
    end)
    sEmt = (s and type(r) == "table") and r or {}
    local u = false
    for i, e in ipairs(sEmt) do
        if not e.AnimationId then e.AnimationId = "rbxassetid://" .. tostring(e.AssetId or e.Id); u = true end
        if e.Favorite == nil then e.Favorite = false; u = true end
        if not e.Price then e.Price = 0; u = true end
        if not e.Idx then e.Idx = i; u = true end
        if e.Creator == nil then e.Creator = ""; u = true end
    end
    if u then svEmt() end
end

lEmt()
loadStep("Loading saved emotes")

local cTr = nil

local function plEmt(aId)
    if cTr then cTr:Stop(cfg["Fade Out"]) end
    local rid = gRId(aId) or aId
    local an = Instance.new("Animation")
    an.AnimationId = "rbxassetid://" .. tostring(rid)
    local animator = hum:FindFirstChildOfClass("Animator") or hum
    local tr = animator:LoadAnimation(an)
    local pr = cfg["High Priority"] and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action
    tr.Priority = pr
    local wt = cfg["Weight"] == 0 and 0.001 or cfg["Weight"]
    if cfg["Stop Other Animations On Play"] then
        for _, pT in pairs(hum.Animator:GetPlayingAnimationTracks()) do
            if pT.Priority ~= pr then pT:Stop() end
        end
    end
    tr:Play(cfg["Fade In"], wt, cfg["Speed"])
    cTr = tr
    cTr.TimePosition = math.clamp(cfg["Time Position"], 0, 1) * (cTr.Length or 1)
    cTr.Priority = pr
    cTr.Looped = cfg["Looped"]
    return tr
end

RS.RenderStepped:Connect(function()
    if cfg["Looped"] and cTr and cTr.IsPlaying then cTr.Looped = cfg["Looped"] end
    if chr:FindFirstChild("HumanoidRootPart") then
        local hrp = chr.HumanoidRootPart
        if cfg["Stop Emote When Moving"] and cTr and cTr.IsPlaying then
            local mv = (hrp.Position - lPs).Magnitude > 0.1
            local jp = hum and hum:GetState() == Enum.HumanoidStateType.Jumping
            if mv or jp then cTr:Stop(cfg["Fade Out"]); cTr = nil end
        end
        lPs = hrp.Position
    end
end)

local cG = srv.CoreGui
local mG = Instance.new("ScreenGui")
mG.Name = "GazeEmoteGUI"
mG.Parent = cG
mG.Enabled = false
mG.DisplayOrder = 999

local function mkCr(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function mkSt(p, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c or Color3.fromRGB(150, 150, 150)
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function mkPr(cd, pr)
    local pL = Instance.new("TextLabel", cd)
    pL.Size = UDim2.new(0, scl("X", 45), 0, scl("Y", 20))
    pL.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 10))
    pL.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    pL.BackgroundTransparency = 0.4
    pL.TextColor3 = Color3.fromRGB(255, 255, 255)
    pL.Font = Enum.Font.GothamBold
    pL.TextScaled = true
    pL.ZIndex = 2
    pL.Text = (pr and tonumber(pr) and tonumber(pr) > 0) and (utf8.char(0xE002) .. tostring(pr)) or "Free"
    mkCr(pL, 6)
end

local mF = Instance.new("Frame")
mF.Size = UDim2.new(0, scl("X", 452), 0, scl("Y", 350))
mF.Position = UDim2.new(0.7, -scl("X", 325), 0.5, -scl("Y", 225))
mF.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mF.BackgroundTransparency = 0.15
mF.Active = true
mF.Draggable = true
mF.Parent = mG
mkCr(mF, 8)
mkSt(mF, Color3.fromRGB(90, 90, 90), 1.5)

local rB = Instance.new("TextButton")
rB.Size = UDim2.new(0, 24, 0, 24)
rB.Position = UDim2.new(1, -24, 1, -24)
rB.BackgroundTransparency = 1
rB.Text = "◢"
rB.TextColor3 = Color3.fromRGB(160, 160, 160)
rB.TextSize = 18
rB.ZIndex = 10
rB.Parent = mF

local iRz = false
local dSP, sFS

rB.InputBegan:Connect(function(ip)
    if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
        iRz = true; dSP = ip.Position; sFS = mF.AbsoluteSize
    end
end)

UIS.InputChanged:Connect(function(ip)
    if iRz and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then
        local dt = ip.Position - dSP
        mF.Size = UDim2.new(0, math.max(150, sFS.X + dt.X), 0, math.max(100, sFS.Y + dt.Y))
    end
end)

UIS.InputEnded:Connect(function(ip)
    if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
        iRz = false
    end
end)

local tL = Instance.new("TextLabel")
tRef = tL
tL.Size = UDim2.new(1, 0, 0, scl("Y", 36))
tL.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tL.BackgroundTransparency = 0.5
tL.Text = r6 and "Gaze Emotes (R6)" or "Gaze Emotes"
tL.TextColor3 = Color3.new(1, 1, 1)
tL.Font = Enum.Font.GothamBold
tL.TextScaled = true
tL.Parent = mF
mkCr(tL, 8)

local cTb = Instance.new("TextButton")
cTRef = cTb
cTb.Size = UDim2.new(0.3, 0, 0, scl("Y", 24))
cTb.Position = UDim2.new(0.05, 0, 0, scl("Y", 40))
cTb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
cTb.BackgroundTransparency = 0.2
cTb.Text = r6 and "Anim" or "Catalog"
cTb.TextColor3 = Color3.new(1, 1, 1)
cTb.Font = Enum.Font.GothamBold
cTb.TextScaled = true
cTb.Parent = mF
mkCr(cTb, 4)
mkSt(cTb, Color3.fromRGB(120, 120, 120), 1)

local sTb = Instance.new("TextButton")
sTRef = sTb
sTb.Size = UDim2.new(0.3, 0, 0, scl("Y", 24))
sTb.Position = UDim2.new(0.35, 0, 0, scl("Y", 40))
sTb.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sTb.BackgroundTransparency = 0.2
sTb.Text = "Saved"
sTb.TextColor3 = Color3.new(1, 1, 1)
sTb.Font = Enum.Font.GothamBold
sTb.TextScaled = true
sTb.Visible = not r6
sTb.Parent = mF
mkCr(sTb, 4)
mkSt(sTb, Color3.fromRGB(80, 80, 80), 1)

local dv = Instance.new("Frame")
dv.Size = UDim2.new(0, scl("X", 2), 1, -scl("Y", 70))
dv.Position = UDim2.new(0.6, -scl("X", 1), 0, scl("Y", 70))
dv.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dv.BackgroundTransparency = 0.5
dv.Parent = mF
loadStep("Building main window")

local rSvd, pSr

local sT = {
    {Enum.CatalogSortType.Relevance, "Relevance"},
    {Enum.CatalogSortType.PriceHighToLow, "Price H→L"},
    {Enum.CatalogSortType.PriceLowToHigh, "Price L→H"},
    {Enum.CatalogSortType.MostFavorited, "Most Fav"},
    {Enum.CatalogSortType.RecentlyCreated, "Recent"},
    {Enum.CatalogSortType.Bestselling, "Bestsell"}
}
local cSI = 1
local cSQ = ""
local cPC = nil
local cPN = 1
local cTId = 1

local salesList = Enum.SalesTypeFilter:GetEnumItems()
local catList = Enum.CatalogCategoryFilter:GetEnumItems()
local function idxOf(list, item)
    for i, v in ipairs(list) do if v == item then return i end end
    return 1
end
local c_Sales = idxOf(salesList, Enum.SalesTypeFilter.All)
local c_Cat = idxOf(catList, Enum.CatalogCategoryFilter.None)
local c_Off = true
local c_Creator = ""
local c_MaxPrice = -1
local c_MinPrice = -1

local sSrtI = 1
local sSrtA = {"Newest", "Oldest", "A-Z", "Z-A", "Price H-L", "Price L-H"}
local sPN = 1
local sRId = 0
local sMxP = 1
local f_FavOnly = false
local f_MaxPrice = -1
local f_MinPrice = -1
local f_Creator = ""

local cFm = Instance.new("Frame")
cFRef = cFm
cFm.Size = UDim2.new(0.6, -scl("X", 10), 1, -scl("Y", 70))
cFm.Position = UDim2.new(0, scl("X", 5), 0, scl("Y", 70))
cFm.BackgroundTransparency = 1
cFm.Visible = true
cFm.Parent = mF

local sBx = Instance.new("TextBox")
sBx.Size = UDim2.new(0.5, -scl("X", 8), 0, scl("Y", 28))
sBx.Position = UDim2.new(0, scl("X", 8), 0, 0)
sBx.PlaceholderText = "Search..."
sBx.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sBx.BackgroundTransparency = 0.3
sBx.TextColor3 = Color3.new(1, 1, 1)
sBx.Font = Enum.Font.Gotham
sBx.TextScaled = true
sBx.ClearTextOnFocus = false
sBx.Text = ""
sBx.Parent = cFm
mkCr(sBx, 4)
mkSt(sBx, Color3.fromRGB(80, 80, 80), 1)

local cFltB = Instance.new("TextButton")
cFltB.Size = UDim2.new(0.38, -scl("X", 8), 0, scl("Y", 28))
cFltB.Position = UDim2.new(0.5, scl("X", 4), 0, 0)
cFltB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
cFltB.BackgroundTransparency = 0.2
cFltB.Text = "Filter"
cFltB.Font = Enum.Font.GothamBold
cFltB.TextScaled = true
cFltB.TextColor3 = Color3.new(1, 1, 1)
cFltB.Parent = cFm
mkCr(cFltB, 4)
mkSt(cFltB, Color3.fromRGB(90, 90, 90), 1)

local rfB = Instance.new("TextButton")
rfB.Size = UDim2.new(0.1, -scl("X", 4), 0, scl("Y", 28))
rfB.Position = UDim2.new(0.9, scl("X", 4), 0, 0)
rfB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
rfB.BackgroundTransparency = 0.2
rfB.Text = "↻"
rfB.Font = Enum.Font.GothamBold
rfB.TextScaled = true
rfB.TextColor3 = Color3.new(1, 1, 1)
rfB.Parent = cFm
mkCr(rfB, 4)
mkSt(rfB, Color3.fromRGB(90, 90, 90), 1)
loadStep("Building catalog tab")

local sFm = Instance.new("Frame")
sFRef = sFm
sFm.Size = UDim2.new(0.6, -scl("X", 10), 1, -scl("Y", 70))
sFm.Position = UDim2.new(0, scl("X", 5), 0, scl("Y", 70))
sFm.BackgroundTransparency = 1
sFm.Visible = false
sFm.Parent = mF

local sSBx = Instance.new("TextBox")
sSBx.Size = UDim2.new(0.5, -scl("X", 8), 0, scl("Y", 28))
sSBx.Position = UDim2.new(0, scl("X", 8), 0, 0)
sSBx.PlaceholderText = "Search Saved..."
sSBx.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sSBx.BackgroundTransparency = 0.3
sSBx.TextColor3 = Color3.new(1, 1, 1)
sSBx.Font = Enum.Font.Gotham
sSBx.TextScaled = true
sSBx.ClearTextOnFocus = false
sSBx.Text = ""
sSBx.Parent = sFm
mkCr(sSBx, 4)
mkSt(sSBx, Color3.fromRGB(80, 80, 80), 1)

local fltB = Instance.new("TextButton", sFm)
fltB.Size = UDim2.new(0.38, -scl("X", 8), 0, scl("Y", 28))
fltB.Position = UDim2.new(0.5, scl("X", 4), 0, 0)
fltB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
fltB.BackgroundTransparency = 0.2
fltB.Text = "Filter"
fltB.Font = Enum.Font.GothamBold
fltB.TextScaled = true
fltB.TextColor3 = Color3.new(1, 1, 1)
mkCr(fltB, 4)
mkSt(fltB, Color3.fromRGB(90, 90, 90), 1)

local aEB = Instance.new("TextButton", sFm)
aEB.Size = UDim2.new(0.1, -scl("X", 4), 0, scl("Y", 28))
aEB.Position = UDim2.new(0.9, scl("X", 4), 0, 0)
aEB.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
aEB.BackgroundTransparency = 0.2
aEB.Text = "+"
aEB.Font = Enum.Font.GothamBold
aEB.TextScaled = true
aEB.TextColor3 = Color3.new(1, 1, 1)
mkCr(aEB, 4)
mkSt(aEB, Color3.fromRGB(30, 90, 150), 1)

local sSFm = Instance.new("ScrollingFrame")
sSFm.Size = UDim2.new(1, -scl("X", 16), 1, -scl("Y", 100))
sSFm.Position = UDim2.new(0, scl("X", 8), 0, scl("Y", 36))
sSFm.CanvasSize = UDim2.new(0, 0, 0, 0)
sSFm.ScrollBarThickness = 0
sSFm.BackgroundTransparency = 1
sSFm.Parent = sFm

local eSL = Instance.new("TextLabel")
eSL.Size = UDim2.new(1, 0, 0, scl("Y", 36))
eSL.Position = UDim2.new(0, 0, 0.5, -scl("Y", 18))
eSL.BackgroundTransparency = 1
eSL.Text = "Sorry I Was Changing Save Files Again 😅"
eSL.TextColor3 = Color3.new(1, 1, 1)
eSL.Font = Enum.Font.GothamBold
eSL.TextScaled = true
eSL.Visible = false
eSL.Parent = sSFm

local sGL = Instance.new("UIGridLayout")
sGL.CellSize = UDim2.new(0, scl("X", 120), 0, scl("Y", 200))
sGL.CellPadding = UDim2.new(0, scl("X", 8), 0, scl("Y", 8))
sGL.HorizontalAlignment = Enum.HorizontalAlignment.Center
sGL.Parent = sSFm

local sPrvB = Instance.new("TextButton", sFm)
sPrvB.Size = UDim2.new(0.4, -scl("X", 6), 0, scl("Y", 32))
sPrvB.Position = UDim2.new(0, scl("X", 4), 1, -scl("Y", 36))
sPrvB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sPrvB.BackgroundTransparency = 0.2
sPrvB.Text = "< Prev"
sPrvB.Font = Enum.Font.GothamBold
sPrvB.TextScaled = true
sPrvB.TextColor3 = Color3.new(1, 1, 1)
mkCr(sPrvB, 6)
mkSt(sPrvB, Color3.fromRGB(80, 80, 80), 1)

local sNxtB = Instance.new("TextButton", sFm)
sNxtB.Size = UDim2.new(0.4, -scl("X", 6), 0, scl("Y", 32))
sNxtB.Position = UDim2.new(0.6, scl("X", 2), 1, -scl("Y", 36))
sNxtB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
sNxtB.BackgroundTransparency = 0.2
sNxtB.Text = "Next >"
sNxtB.Font = Enum.Font.GothamBold
sNxtB.TextScaled = true
sNxtB.TextColor3 = Color3.new(1, 1, 1)
mkCr(sNxtB, 6)
mkSt(sNxtB, Color3.fromRGB(80, 80, 80), 1)

local sPgB = Instance.new("TextBox", sFm)
sPgB.Size = UDim2.new(0.2, 0, 0, scl("Y", 32))
sPgB.Position = UDim2.new(0.4, scl("X", 2), 1, -scl("Y", 36))
sPgB.BackgroundTransparency = 1
sPgB.Font = Enum.Font.Gotham
sPgB.TextScaled = true
sPgB.TextColor3 = Color3.new(1, 1, 1)
sPgB.Text = "1 / 1"
loadStep("Building saved tab")

local stFm = Instance.new("Frame")
stFm.Size = UDim2.new(0.4, -scl("X", 10), 1, -scl("Y", 70))
stFm.Position = UDim2.new(0.6, scl("X", 5), 0, scl("Y", 70))
stFm.BackgroundTransparency = 1
stFm.Parent = mF

local stT = Instance.new("TextLabel")
stT.Size = UDim2.new(1, 0, 0, scl("Y", 28))
stT.BackgroundTransparency = 1
stT.Text = "Settings"
stT.TextColor3 = Color3.new(1, 1, 1)
stT.Font = Enum.Font.GothamBold
stT.TextScaled = true
stT.Parent = stFm

local stSF = Instance.new("ScrollingFrame")
stSF.Size = UDim2.new(1, -scl("X", 20), 1, -scl("Y", 40))
stSF.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 30))
stSF.BackgroundTransparency = 1
stSF.CanvasSize = UDim2.new(0, 0, 0, 0)
stSF.ScrollBarThickness = 4
stSF.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
stSF.Parent = stFm

stSF:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    stSF.CanvasPosition = Vector2.new(0, stSF.CanvasPosition.Y)
end)

local stLL = Instance.new("UIListLayout", stSF)
stLL.Padding = UDim.new(0, 8)
stLL.FillDirection = Enum.FillDirection.Vertical
stLL.SortOrder = Enum.SortOrder.LayoutOrder

stLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    stSF.CanvasSize = UDim2.new(0, 0, 0, stLL.AbsoluteContentSize.Y + 10)
end)

loadStep("Building settings panel")
local pOvl = Instance.new("Frame", mF)
pOvl.Size = UDim2.new(1, 0, 1, 0)
pOvl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pOvl.BackgroundTransparency = 0.6
pOvl.Active = true
pOvl.Visible = false
pOvl.ZIndex = 50
mkCr(pOvl, 8)

local function mkPopFm(h)
    local fm = Instance.new("Frame", pOvl)
    fm.Size = UDim2.new(0, scl("X", 260), 0, scl("Y", h))
    fm.Position = UDim2.new(0.5, -scl("X", 130), 0.5, -scl("Y", h/2))
    fm.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fm.ZIndex = 51
    fm.Visible = false
    mkCr(fm, 8)
    mkSt(fm, Color3.fromRGB(80, 80, 80), 1)
    return fm
end

local function clPops()
    pOvl.Visible = false
    for _, c in ipairs(pOvl:GetChildren()) do
        if c:IsA("Frame") then c.Visible = false end
    end
end

local function openPop(fm)
    clPops()
    pOvl.Visible = true
    fm.Visible = true
end

local aPFm = mkPopFm(170)

local aPT = Instance.new("TextLabel", aPFm)
aPT.Size = UDim2.new(1, 0, 0, scl("Y", 30))
aPT.BackgroundTransparency = 1
aPT.Text = "Add Custom Emote"
aPT.TextColor3 = Color3.new(1, 1, 1)
aPT.Font = Enum.Font.GothamBold
aPT.TextScaled = true
aPT.ZIndex = 52

local aPId = Instance.new("TextBox", aPFm)
aPId.Size = UDim2.new(1, -scl("X", 20), 0, scl("Y", 30))
aPId.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 40))
aPId.PlaceholderText = "Animation or Asset ID"
aPId.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
aPId.TextColor3 = Color3.new(1, 1, 1)
aPId.Font = Enum.Font.Gotham
aPId.TextScaled = true
aPId.ClearTextOnFocus = false
aPId.Text = ""
aPId.ZIndex = 52
mkCr(aPId, 4)
mkSt(aPId, Color3.fromRGB(70, 70, 70), 1)

local aPNm = Instance.new("TextBox", aPFm)
aPNm.Size = UDim2.new(1, -scl("X", 20), 0, scl("Y", 30))
aPNm.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 80))
aPNm.PlaceholderText = "Custom Name (Optional)"
aPNm.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
aPNm.TextColor3 = Color3.new(1, 1, 1)
aPNm.Font = Enum.Font.Gotham
aPNm.TextScaled = true
aPNm.ClearTextOnFocus = false
aPNm.Text = ""
aPNm.ZIndex = 52
mkCr(aPNm, 4)
mkSt(aPNm, Color3.fromRGB(70, 70, 70), 1)

local aPCnl = Instance.new("TextButton", aPFm)
aPCnl.Size = UDim2.new(0.45, 0, 0, scl("Y", 30))
aPCnl.Position = UDim2.new(0.025, 0, 0, scl("Y", 125))
aPCnl.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
aPCnl.Text = "Cancel"
aPCnl.TextColor3 = Color3.new(1, 1, 1)
aPCnl.Font = Enum.Font.GothamBold
aPCnl.TextScaled = true
aPCnl.ZIndex = 52
mkCr(aPCnl, 4)
aPCnl.MouseButton1Click:Connect(clPops)

local aPAdd = Instance.new("TextButton", aPFm)
aPAdd.Size = UDim2.new(0.45, 0, 0, scl("Y", 30))
aPAdd.Position = UDim2.new(0.525, 0, 0, scl("Y", 125))
aPAdd.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
aPAdd.Text = "Add Emote"
aPAdd.TextColor3 = Color3.new(1, 1, 1)
aPAdd.Font = Enum.Font.GothamBold
aPAdd.TextScaled = true
aPAdd.ZIndex = 52
mkCr(aPAdd, 4)

loadStep("Building popups")
local PR_MAX = 1000
local fW = scl("X", 230)
local fGap = scl("X", 8)
local fShowPos = UDim2.new(0, -fW - fGap, 0, 0)

local function trim(s)
    return ((s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local fSb = Instance.new("Frame")
fSb.Size = UDim2.new(0, fW, 1, 0)
fSb.Position = fShowPos
fSb.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
fSb.BackgroundTransparency = 0.15
fSb.Visible = false
fSb.Parent = mF
mkCr(fSb, 8)
mkSt(fSb, Color3.fromRGB(90, 90, 90), 1.5)

local fTitle = Instance.new("TextLabel")
fTitle.Size = UDim2.new(1, 0, 0, scl("Y", 36))
fTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fTitle.BackgroundTransparency = 0.5
fTitle.Text = "Filters"
fTitle.TextColor3 = Color3.new(1, 1, 1)
fTitle.Font = Enum.Font.GothamBold
fTitle.TextScaled = true
fTitle.Parent = fSb
mkCr(fTitle, 8)

local function mkPage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -scl("X", 20), 1, -scl("Y", 46))
    sf.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 40))
    sf.BackgroundTransparency = 1
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.ScrollBarThickness = 4
    sf.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
    sf.ScrollingDirection = Enum.ScrollingDirection.Y
    sf.Visible = false
    sf.Parent = fSb
    local ll = Instance.new("UIListLayout", sf)
    ll.Padding = UDim.new(0, 8)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 10)
    end)
    return sf
end

local function mkRow(pg, h)
    local cn = Instance.new("Frame")
    cn.Size = UDim2.new(1, 0, 0, scl("Y", h))
    cn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    cn.BackgroundTransparency = 0.4
    cn.Parent = pg
    mkCr(cn, 6)
    mkSt(cn, Color3.fromRGB(70, 70, 70), 1)
    return cn
end

local function mkRLbl(cn, txt, w)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(w, -scl("X", 10), 1, 0)
    lb.Position = UDim2.new(0, scl("X", 10), 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = txt
    lb.TextColor3 = Color3.new(1, 1, 1)
    lb.Font = Enum.Font.Gotham
    lb.TextScaled = true
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = cn
    return lb
end

local function mkFBtn(pg, tx, col)
    local cn = mkRow(pg, 45)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -scl("X", 20), 1, -scl("Y", 10))
    b.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 5))
    b.BackgroundColor3 = col or Color3.fromRGB(40, 40, 40)
    b.BackgroundTransparency = 0.2
    b.Text = tx
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = cn
    mkCr(b, 6)
    mkSt(b, Color3.fromRGB(100, 100, 100), 1)
    return b
end

local function mkFTg(pg, name, get, set)
    local cn = mkRow(pg, 40)
    mkRLbl(cn, name, 1).Size = UDim2.new(1, -scl("X", 90), 1, 0)
    local tB = Instance.new("TextButton")
    tB.Size = UDim2.new(0, scl("X", 60), 0, scl("Y", 24))
    tB.Position = UDim2.new(1, -scl("X", 70), 0.5, -scl("Y", 12))
    tB.Font = Enum.Font.GothamBold
    tB.TextScaled = true
    tB.Parent = cn
    mkCr(tB, 4)
    mkSt(tB, Color3.fromRGB(100, 100, 100), 1)
    local function uV()
        local st = get()
        tB.Text = st and "ON" or "OFF"
        tB.BackgroundColor3 = st and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(40, 40, 40)
        tB.TextColor3 = st and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        tB.BackgroundTransparency = 0.2
    end
    tB.MouseButton1Click:Connect(function() set(not get()); uV() end)
    uV()
    return uV
end

local function mkFCy(pg, name, getTxt, step)
    local cn = mkRow(pg, 40)
    mkRLbl(cn, name, 0.4)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.6, -scl("X", 14), 0, scl("Y", 24))
    b.Position = UDim2.new(0.4, scl("X", 4), 0.5, -scl("Y", 12))
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.BackgroundTransparency = 0.2
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Text = getTxt()
    b.Parent = cn
    mkCr(b, 4)
    mkSt(b, Color3.fromRGB(100, 100, 100), 1)
    b.MouseButton1Click:Connect(function() step(); b.Text = getTxt() end)
    return function() b.Text = getTxt() end
end

local function mkFBx(pg, name, ph, onChange)
    local cn = mkRow(pg, 40)
    mkRLbl(cn, name, 0.4)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(0.6, -scl("X", 14), 0, scl("Y", 24))
    tb.Position = UDim2.new(0.4, scl("X", 4), 0.5, -scl("Y", 12))
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.PlaceholderText = ph
    tb.Font = Enum.Font.Gotham
    tb.TextScaled = true
    tb.ClearTextOnFocus = false
    tb.Text = ""
    tb.Parent = cn
    mkCr(tb, 4)
    mkSt(tb, Color3.fromRGB(80, 80, 80), 1)
    tb.FocusLost:Connect(function() onChange(tb.Text) end)
    return tb
end

local function mkFSl(pg, name, mnV, mxV, dV, fmt, onChange)
    local cn = mkRow(pg, 65)
    local val = dV
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.5, -scl("X", 10), 0, scl("Y", 20))
    lb.Position = UDim2.new(0, 10, 0, 5)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextColor3 = Color3.new(1, 1, 1)
    lb.Font = Enum.Font.Gotham
    lb.TextScaled = true
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = cn
    local ib = Instance.new("TextBox")
    ib.Size = UDim2.new(0.5, -scl("X", 20), 0, scl("Y", 20))
    ib.Position = UDim2.new(0.5, scl("X", 10), 0, scl("Y", 5))
    ib.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ib.TextColor3 = Color3.new(1, 1, 1)
    ib.Font = Enum.Font.Gotham
    ib.TextScaled = true
    ib.ClearTextOnFocus = false
    ib.Parent = cn
    mkCr(ib, 4)
    mkSt(ib, Color3.fromRGB(80, 80, 80), 1)
    local bB = Instance.new("Frame")
    bB.Size = UDim2.new(1, -scl("X", 40), 0, scl("Y", 12))
    bB.Position = UDim2.new(0, scl("X", 20), 0, scl("Y", 35))
    bB.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bB.Parent = cn
    mkCr(bB, 6)
    local bF = Instance.new("Frame")
    bF.Size = UDim2.new(0, 0, 1, 0)
    bF.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    bF.Parent = bB
    mkCr(bF, 6)
    local sK = Instance.new("Frame")
    sK.Size = UDim2.new(0, scl("X", 20), 0, scl("Y", 20))
    sK.AnchorPoint = Vector2.new(0.5, 0.5)
    sK.Position = UDim2.new(0, 0, 0.5, 0)
    sK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sK.Parent = bB
    mkCr(sK, 10)
    mkSt(sK, Color3.fromRGB(0, 0, 0), 1)
    local function show()
        ib.Text = fmt(val)
        local al = math.clamp((val - mnV) / (mxV - mnV), 0, 1)
        bF.Size = UDim2.new(al, 0, 1, 0)
        sK.Position = UDim2.new(al, 0, 0.5, 0)
    end
    local function sV(v, silent)
        val = math.clamp(math.floor(v / 5 + 0.5) * 5, mnV, mxV)
        show()
        if not silent then onChange(val) end
    end
    local iD = false
    local function uD(ip)
        local al = math.clamp((ip.Position.X - bB.AbsolutePosition.X) / bB.AbsoluteSize.X, 0, 1)
        sV(mnV + (mxV - mnV) * al)
    end
    bB.InputBegan:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then iD = true; uD(ip) end
    end)
    sK.InputBegan:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then iD = true; uD(ip) end
    end)
    UIS.InputChanged:Connect(function(ip)
        if iD and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then uD(ip) end
    end)
    UIS.InputEnded:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then iD = false end
    end)
    ib.FocusLost:Connect(function()
        local p = tonumber(ib.Text)
        if p then sV(p) else show() end
    end)
    show()
    return function(v) sV(v, true) end
end

local function fmtMin(v) return v <= 0 and "Any" or (utf8.char(0xE002) .. tostring(v)) end
local function fmtMax(v) return v >= PR_MAX and "Any" or (utf8.char(0xE002) .. tostring(v)) end

local sPg = mkPage()
local sRstB = mkFBtn(sPg, "Reset Filters")

local dbTok = 0
local function savedChanged()
    dbTok = dbTok + 1
    local t = dbTok
    task.delay(0.2, function()
        if t == dbTok then sPN = 1; if rSvd then rSvd() end end
    end)
end

local uSSort = mkFCy(sPg, "Sort", function() return sSrtA[sSrtI] end, function()
    sSrtI = sSrtI % #sSrtA + 1; savedChanged()
end)
local uFav = mkFTg(sPg, "Favorites Only", function() return f_FavOnly end, function(v)
    f_FavOnly = v; savedChanged()
end)
local sCrBx = mkFBx(sPg, "Creator", "username", function(t)
    f_Creator = trim(t):lower(); savedChanged()
end)
local setSMin = mkFSl(sPg, "Min Price", 0, PR_MAX, 0, fmtMin, function(v)
    f_MinPrice = v > 0 and v or -1; savedChanged()
end)
local setSMax = mkFSl(sPg, "Max Price", 0, PR_MAX, PR_MAX, fmtMax, function(v)
    f_MaxPrice = v >= PR_MAX and -1 or v; savedChanged()
end)

sRstB.MouseButton1Click:Connect(function()
    f_FavOnly = false; f_Creator = ""; f_MinPrice = -1; f_MaxPrice = -1
    uFav(); sCrBx.Text = ""; setSMin(0); setSMax(PR_MAX)
    savedChanged()
end)

local CAT_DEBOUNCE = 0.9
local CAT_MIN_GAP = 1.5
local catSchedTok = 0
local catBusy = false
local catLastAt = -100
local catLastSig = nil
local catBackoff = 0
local catRetry = 0
local catLastPage = 0
local catStatus = function() end

local function catSig(q)
    return table.concat({q, cSI, c_Sales, c_Cat, tostring(c_Off), c_Creator:lower(), c_MinPrice, c_MaxPrice}, "|")
end

local function schedCat(instant, force, q, isRetry)
    if not isRetry then catRetry = 0 end
    catSchedTok = catSchedTok + 1
    local tk = catSchedTok
    task.spawn(function()
        if not instant then
            catStatus("Waiting...")
            task.wait(CAT_DEBOUNCE)
        end

        while true do
            if tk ~= catSchedTok then return end
            local gap = catLastAt + CAT_MIN_GAP + catBackoff - os.clock()
            if not catBusy and gap <= 0 then break end
            task.wait(math.max(gap, 0.1))
        end
        if tk ~= catSchedTok then return end
        local query = (q ~= nil) and q or cSQ
        local sig = catSig(query)
        if not force and sig == catLastSig then
            catStatus(nil)
            return
        end
        catBusy = true
        local ok = pSr and pSr(query)
        catBusy = false
        catLastAt = os.clock()
        if ok then
            catLastSig = sig
            catBackoff = 0
            catRetry = 0
        else
            catBackoff = math.min(catBackoff == 0 and 3 or catBackoff * 2, 30)
            catRetry = catRetry + 1
            if catRetry <= 4 then
                catStatus("Retrying...")
                if tk == catSchedTok then schedCat(true, true, query, true) end
            else
                catStatus("Search failed")
            end
        end
    end)
end

local function catChanged() schedCat(false, false) end

local cPg = mkPage()
local cRstB = mkFBtn(cPg, "Reset Filters")

local uCSort = mkFCy(cPg, "Sort", function() return sT[cSI][2] end, function()
    cSI = cSI % #sT + 1; catChanged()
end)
local uCSales = mkFCy(cPg, "Sales", function() return salesList[c_Sales].Name end, function()
    c_Sales = c_Sales % #salesList + 1; catChanged()
end)
local uCCat = mkFCy(cPg, "Category", function() return catList[c_Cat].Name end, function()
    c_Cat = c_Cat % #catList + 1; catChanged()
end)
local uCOff = mkFTg(cPg, "Include Off Sale", function() return c_Off end, function(v)
    c_Off = v; catChanged()
end)
local cCrBx = mkFBx(cPg, "Creator", "username", function(t)
    c_Creator = trim(t); catChanged()
end)
local setCMin = mkFSl(cPg, "Min Price", 0, PR_MAX, 0, fmtMin, function(v)
    c_MinPrice = v > 0 and v or -1; catChanged()
end)
local setCMax = mkFSl(cPg, "Max Price", 0, PR_MAX, PR_MAX, fmtMax, function(v)
    c_MaxPrice = v >= PR_MAX and -1 or v; catChanged()
end)

cRstB.MouseButton1Click:Connect(function()
    cSI = 1
    c_Sales = idxOf(salesList, Enum.SalesTypeFilter.All)
    c_Cat = idxOf(catList, Enum.CatalogCategoryFilter.None)
    c_Off = true; c_Creator = ""; c_MinPrice = -1; c_MaxPrice = -1
    uCSort(); uCSales(); uCCat(); uCOff()
    cCrBx.Text = ""; setCMin(0); setCMax(PR_MAX)
    catChanged()
end)

loadStep("Building filters")
local fOpen, fTab = false, "c"

local function showFPage()
    cPg.Visible = (fTab == "c")
    sPg.Visible = (fTab == "s")
    fTitle.Text = fTab == "c" and "Catalog Filters" or "Saved Filters"
end

local function setFSb(open)
    fOpen = open
    if open then showFPage() end
    fSb.Visible = open
end

local function toggleFSb(tab)
    if fOpen and fTab == tab then
        setFSb(false)
    else
        fTab = tab
        if fOpen then showFPage() else setFSb(true) end
    end
end

aEB.MouseButton1Click:Connect(function()
    aPId.Text = ""; aPNm.Text = ""
    openPop(aPFm)
end)

fltB.MouseButton1Click:Connect(function() toggleFSb("s") end)
cFltB.MouseButton1Click:Connect(function() toggleFSb("c") end)

aPAdd.MouseButton1Click:Connect(function()
    local id = tonumber(aPId.Text)
    local nm = aPNm.Text
    if nm == "" then nm = "Custom ID: " .. tostring(id or "") end

    if id then
        local ex = false
        for _, e in ipairs(sEmt) do
            if e.Id == id then ex = true; break end
        end
        if not ex then
            aPAdd.Text = "Adding..."
            task.spawn(function()
                local rI = gRId(id)
                table.insert(sEmt, {
                    Id = id, AssetId = id, Name = nm,
                    AnimationId = "rbxassetid://" .. tostring(rI or id),
                    Favorite = false, Price = 0, Idx = #sEmt + 1, Creator = ""
                })
                svEmt()
                if rSvd then rSvd() end
                clPops()
                aPAdd.Text = "Add Emote"
            end)
        else
            aPAdd.Text = "Already Exists!"
            task.wait(1)
            aPAdd.Text = "Add Emote"
        end
    else
        aPAdd.Text = "Invalid ID!"
        task.wait(1)
        aPAdd.Text = "Add Emote"
    end
end)

local function mkSl(sN, mnV, mxV, dV)
    cfg[sN] = dV or mnV
    local cn = Instance.new("Frame")
    cn.Size = UDim2.new(1, 0, 0, scl("Y", 65))
    cn.BackgroundTransparency = 1
    cn.Parent = stSF
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    bg.BackgroundTransparency = 0.4
    bg.Parent = cn
    mkCr(bg, 6)
    mkSt(bg, Color3.fromRGB(70, 70, 70), 1)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.5, -scl("X", 10), 0, scl("Y", 20))
    lb.Position = UDim2.new(0, 10, 0, 5)
    lb.BackgroundTransparency = 1
    lb.Text = string.format("%s: %.2f", sN, cfg[sN])
    lb.TextColor3 = Color3.new(1, 1, 1)
    lb.Font = Enum.Font.Gotham
    lb.TextScaled = true
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = bg
    local ib = Instance.new("TextBox")
    ib.Size = UDim2.new(0.5, -scl("X", 20), 0, scl("Y", 20))
    ib.Position = UDim2.new(0.5, scl("X", 10), 0, scl("Y", 5))
    ib.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ib.Text = tostring(cfg[sN])
    ib.TextColor3 = Color3.new(1, 1, 1)
    ib.Font = Enum.Font.Gotham
    ib.TextScaled = true
    ib.ClearTextOnFocus = false
    ib.Parent = bg
    mkCr(ib, 4)
    mkSt(ib, Color3.fromRGB(80, 80, 80), 1)
    local bB = Instance.new("Frame")
    bB.Size = UDim2.new(1, -scl("X", 40), 0, scl("Y", 12))
    bB.Position = UDim2.new(0, scl("X", 20), 0, scl("Y", 35))
    bB.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bB.Parent = bg
    mkCr(bB, 6)
    local bF = Instance.new("Frame")
    bF.Size = UDim2.new(0, 0, 1, 0)
    bF.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    bF.Parent = bB
    mkCr(bF, 6)
    local sK = Instance.new("Frame")
    sK.Size = UDim2.new(0, scl("X", 20), 0, scl("Y", 20))
    sK.AnchorPoint = Vector2.new(0.5, 0.5)
    sK.Position = UDim2.new(0, 0, 0.5, 0)
    sK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sK.Parent = bB
    mkCr(sK, 10)
    mkSt(sK, Color3.fromRGB(0, 0, 0), 1)
    local function uV(al)
        al = math.clamp(al, 0, 1)
        TS:Create(bF, TweenInfo.new(0.15), {Size = UDim2.new(al, 0, 1, 0)}):Play()
        TS:Create(sK, TweenInfo.new(0.15), {Position = UDim2.new(al, 0, 0.5, 0)}):Play()
    end
    local function sV(v)
        cfg[sN] = math.clamp(v, mnV, mxV)
        lb.Text = string.format("%s: %.2f", sN, cfg[sN])
        ib.Text = tostring(cfg[sN])
        uV((cfg[sN] - mnV) / (mxV - mnV))
        if cTr and cTr.IsPlaying then
            if sN == "Speed" then cTr:AdjustSpeed(cfg["Speed"])
            elseif sN == "Weight" then local w = cfg["Weight"]; cTr:AdjustWeight(w == 0 and 0.001 or w)
            elseif sN == "Time Position" and cTr.Length > 0 then cTr.TimePosition = math.clamp(v, 0, 1) * cTr.Length end
        end
    end
    local iD = false
    local function uD(ip)
        local al = math.clamp((ip.Position.X - bB.AbsolutePosition.X) / bB.AbsoluteSize.X, 0, 1)
        local nV = math.floor((mnV + (mxV - mnV) * al) * 100) / 100
        sV(nV)
    end
    bB.InputBegan:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then iD = true; uD(ip) end
    end)
    sK.InputBegan:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then iD = true; uD(ip) end
    end)
    UIS.InputChanged:Connect(function(ip)
        if iD and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then uD(ip) end
    end)
    UIS.InputEnded:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then iD = false end
    end)
    ib.FocusLost:Connect(function(eP)
        if eP then
            local p = tonumber(ib.Text)
            if p then sV(p) else ib.Text = tostring(cfg[sN]) end
        end
    end)
    cfg._s[sN] = sV
    sV(cfg[sN])
end

local function mkTg(sN)
    cfg[sN] = cfg[sN] or false
    local cn = Instance.new("Frame")
    cn.Size = UDim2.new(1, 0, 0, scl("Y", 40))
    cn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    cn.BackgroundTransparency = 0.4
    cn.Parent = stSF
    mkCr(cn, 6)
    mkSt(cn, Color3.fromRGB(70, 70, 70), 1)
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -scl("X", 90), 1, 0)
    lb.Position = UDim2.new(0, scl("X", 10), 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = sN
    lb.TextColor3 = Color3.new(1, 1, 1)
    lb.Font = Enum.Font.Gotham
    lb.TextScaled = true
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = cn
    local tB = Instance.new("TextButton")
    tB.Size = UDim2.new(0, scl("X", 60), 0, scl("Y", 24))
    tB.Position = UDim2.new(1, -scl("X", 70), 0.5, -scl("Y", 12))
    tB.TextColor3 = Color3.new(1, 1, 1)
    tB.Font = Enum.Font.GothamBold
    tB.TextScaled = true
    tB.Parent = cn
    mkCr(tB, 4)
    mkSt(tB, Color3.fromRGB(100, 100, 100), 1)
    local function uV(st)
        tB.Text = st and "ON" or "OFF"
        tB.BackgroundColor3 = st and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(40, 40, 40)
        tB.TextColor3 = st and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        tB.BackgroundTransparency = 0.2
    end
    tB.MouseButton1Click:Connect(function()
        cfg[sN] = not cfg[sN]
        uV(cfg[sN])
    end)
    uV(cfg[sN])
    cfg._t[sN] = uV
end

function cfg:ES(n, v)
    local sF = self._s[n]; if sF then sF(v) end
end

function cfg:ET(n, v)
    local tF = self._t[n]; if tF then self[n] = v; tF(v) end
end

local function mkB(tx, cb)
    local cn = Instance.new("Frame")
    cn.Size = UDim2.new(1, 0, 0, scl("Y", 45))
    cn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    cn.BackgroundTransparency = 0.4
    cn.Parent = stSF
    mkCr(cn, 6)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -scl("X", 20), 1, -scl("Y", 10))
    b.Position = UDim2.new(0, scl("X", 10), 0, scl("Y", 5))
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.BackgroundTransparency = 0.2
    b.Text = tx
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = cn
    mkCr(b, 6)
    mkSt(b, Color3.fromRGB(100, 100, 100), 1)
    b.MouseButton1Click:Connect(function() if typeof(cb) == "function" then cb() end end)
    return b
end

local rstB = mkB("Reset Settings", function() end)
mkTg("Stop Emote When Moving")
mkTg("Looped")
mkSl("Speed", 0, 5, cfg["Speed"])
mkSl("Time Position", 0, 1, cfg["Time Position"])
mkSl("Weight", 0, 1, cfg["Weight"])
mkSl("Fade In", 0, 2, cfg["Fade In"])
mkSl("Fade Out", 0, 2, cfg["Fade Out"])
mkTg("Stop Other Animations On Play")
mkTg("High Priority")

rstB.MouseButton1Click:Connect(function()
    cfg:ET("Stop Emote When Moving", true)
    cfg:ET("Stop Other Animations On Play", true)
    cfg:ET("High Priority", true)
    cfg:ES("Fade In", 0.1)
    cfg:ES("Fade Out", 0.1)
    cfg:ES("Weight", 1)
    cfg:ES("Speed", 1)
    cfg:ES("Time Position", 0)
    cfg:ET("Freeze On Finish", false)
    cfg:ET("Looped", true)
end)

loadStep("Building settings widgets")
local function fCP(kw)
    if r6 then
        return {
            IsFinished = true,
            GetCurrentPage = function() return {{Id = 115314801778772, Name = "Dance If Youre The Best", AssetId = 115314801778772, Price = 0}} end,
            AdvanceToNextPageAsync = function() end
        }
    end
    local sP = CatalogSearchParams.new()
    sP.SearchKeyword = kw or ""
    sP.CategoryFilter = catList[c_Cat]
    sP.SalesTypeFilter = salesList[c_Sales]
    sP.AssetTypes = {Enum.AvatarAssetType.EmoteAnimation}
    sP.IncludeOffSale = c_Off
    sP.SortType = sT[cSI][1]
    sP.Limit = 10
    if c_Creator ~= "" then sP.CreatorName = c_Creator end
    if c_MinPrice >= 0 then sP.MinPrice = c_MinPrice end
    if c_MaxPrice >= 0 then sP.MaxPrice = c_MaxPrice end
    local s, r = pcall(function() return AES:SearchCatalog(sP) end)
    return s and r or nil
end

local function mkCCd(it)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(0, scl("X", 120), 0, scl("Y", 180))
    cd.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    cd.BackgroundTransparency = 0.1
    mkCr(cd, 10)
    mkSt(cd, Color3.fromRGB(60, 60, 60), 1.5)

    local aI = it.AssetId or it.Id
    local tn = Instance.new("ImageLabel")
    tn.Size = UDim2.new(1, -scl("X", 10), 0, scl("Y", 90))
    tn.Position = UDim2.new(0, scl("X", 5), 0, scl("Y", 5))
    tn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    tn.BackgroundTransparency = 0.5
    tn.ScaleType = Enum.ScaleType.Fit
    tn.Image = "rbxthumb://type=Asset&id=" .. tonumber(aI) .. "&w=150&h=150"
    tn.Parent = cd
    mkCr(tn, 6)

    local nL = Instance.new("TextLabel")
    nL.Size = UDim2.new(1, -scl("X", 10), 0, scl("Y", 32))
    nL.Position = UDim2.new(0, scl("X", 5), 0, scl("Y", 100))
    nL.BackgroundTransparency = 1
    nL.Text = it.Name or "Unknown"
    nL.TextScaled = true
    nL.TextWrapped = true
    nL.Font = Enum.Font.GothamSemibold
    nL.TextColor3 = Color3.fromRGB(240, 240, 240)
    nL.Parent = cd

    mkPr(cd, it.Price)

    local sU = "https://www.roblox.com/catalog/" .. tonumber(it.Id)
    local lB = Instance.new("TextButton")
    lB.Parent = cd
    lB.Size = UDim2.new(0, scl("X", 26), 0, scl("Y", 26))
    lB.Position = UDim2.new(1, -scl("X", 31), 0, scl("Y", 10))
    lB.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    lB.BackgroundTransparency = 0.2
    lB.Text = "🔗"
    lB.Font = Enum.Font.GothamBold
    lB.TextScaled = true
    lB.TextColor3 = Color3.fromRGB(255, 255, 255)
    lB.AutoButtonColor = false
    mkCr(lB, 6)
    mkSt(lB, Color3.fromRGB(80, 80, 80), 1)
    lB.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(sU) end
        lB.Text = "✅"
        lB.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        task.wait(0.7)
        lB.Text = "🔗"
        lB.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)

    local pB = Instance.new("TextButton")
    pB.Size = UDim2.new(0.45, -scl("X", 5), 0, scl("Y", 26))
    pB.Position = UDim2.new(0, scl("X", 5), 1, -scl("Y", 32))
    pB.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    pB.BackgroundTransparency = 0.1
    pB.Text = "Play"
    pB.Font = Enum.Font.GothamBold
    pB.TextScaled = true
    pB.TextColor3 = Color3.fromRGB(10, 10, 10)
    pB.Parent = cd
    mkCr(pB, 6)
    pB.MouseButton1Click:Connect(function() plEmt(aI) end)

    local sB = Instance.new("TextButton")
    sB.Size = UDim2.new(0.45, -scl("X", 5), 0, scl("Y", 26))
    sB.Position = UDim2.new(0.55, 0, 1, -scl("Y", 32))
    sB.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    sB.BackgroundTransparency = 0.2
    sB.Text = "Save"
    sB.Font = Enum.Font.GothamBold
    sB.TextScaled = true
    sB.TextColor3 = Color3.fromRGB(255, 255, 255)
    sB.Parent = cd
    mkCr(sB, 6)
    mkSt(sB, Color3.fromRGB(30, 90, 150), 1)
    sB.MouseButton1Click:Connect(function()
        local ex = false
        for _, sI in ipairs(sEmt) do
            if sI.Id == it.Id then ex = true; break end
        end
        if not ex then
            sB.Text = "..."
            task.spawn(function()
                local rI = gRId(aI)
                table.insert(sEmt, {
                    Id = it.Id, AssetId = aI, Name = it.Name or "Unknown",
                    AnimationId = "rbxassetid://" .. tostring(rI or aI),
                    Favorite = false, Price = it.Price or 0, Idx = #sEmt + 1,
                    Creator = tostring(it.CreatorName or "")
                })
                svEmt()
                sB.Text = "Saved!"
                sB.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
                if rSvd then rSvd() end
                task.wait(1)
                sB.Text = "Save"
                sB.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
            end)
        else
            sB.Text = "Already"
            task.wait(0.7)
            sB.Text = "Save"
        end
    end)
    return cd
end

local cSFm = Instance.new("ScrollingFrame")
cSFm.Size = UDim2.new(1, -scl("X", 16), 1, -scl("Y", 100))
cSFm.Position = UDim2.new(0, scl("X", 8), 0, scl("Y", 36))
cSFm.CanvasSize = UDim2.new(0, 0, 0, 0)
cSFm.ScrollBarThickness = 6
cSFm.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
cSFm.BackgroundTransparency = 1
cSFm.Parent = cFm

local cGL = Instance.new("UIGridLayout", cSFm)
cGL.CellSize = UDim2.new(0, scl("X", 120), 0, scl("Y", 180))
cGL.CellPadding = UDim2.new(0, scl("X", 8), 0, scl("Y", 8))

local eCL = Instance.new("TextLabel", cSFm)
eCL.Size = UDim2.new(1, 0, 0, scl("Y", 36))
eCL.Position = UDim2.new(0, 0, 0.5, -scl("Y", 18))
eCL.BackgroundTransparency = 1
eCL.Text = "Nothing Silly Here :3 (except me)"
eCL.TextColor3 = Color3.new(1, 1, 1)
eCL.Font = Enum.Font.GothamBold
eCL.TextScaled = true
eCL.Visible = false

local cPrvB = Instance.new("TextButton", cFm)
cPrvB.Size = UDim2.new(0.4, -scl("X", 6), 0, scl("Y", 32))
cPrvB.Position = UDim2.new(0, scl("X", 4), 1, -scl("Y", 36))
cPrvB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
cPrvB.BackgroundTransparency = 0.2
cPrvB.Text = "< Prev"
cPrvB.Font = Enum.Font.GothamBold
cPrvB.TextScaled = true
cPrvB.TextColor3 = Color3.new(1, 1, 1)
mkCr(cPrvB, 6)
mkSt(cPrvB, Color3.fromRGB(80, 80, 80), 1)

local cNxtB = Instance.new("TextButton", cFm)
cNxtB.Size = UDim2.new(0.4, -scl("X", 6), 0, scl("Y", 32))
cNxtB.Position = UDim2.new(0.6, scl("X", 2), 1, -scl("Y", 36))
cNxtB.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
cNxtB.BackgroundTransparency = 0.2
cNxtB.Text = "Next >"
cNxtB.Font = Enum.Font.GothamBold
cNxtB.TextScaled = true
cNxtB.TextColor3 = Color3.new(1, 1, 1)
mkCr(cNxtB, 6)
mkSt(cNxtB, Color3.fromRGB(80, 80, 80), 1)

local cPgB = Instance.new("TextBox", cFm)
cPgB.Size = UDim2.new(0.2, 0, 0, scl("Y", 32))
cPgB.Position = UDim2.new(0.4, scl("X", 2), 1, -scl("Y", 36))
cPgB.BackgroundTransparency = 1
cPgB.Font = Enum.Font.Gotham
cPgB.TextScaled = true
cPgB.TextColor3 = Color3.new(1, 1, 1)
cPgB.Text = "1 / Enter page"
catStatus = function(t)
    cPgB.Text = t or (tostring(cPN) .. " / Enter page")
end

local pEL = Instance.new("TextLabel", cFm)
pEL.Size = UDim2.new(0.3, 0, 0, scl("Y", 24))
pEL.Position = UDim2.new(0.35, 0, 1, -scl("Y", 68))
pEL.BackgroundTransparency = 1
pEL.TextColor3 = Color3.fromRGB(200, 200, 200)
pEL.Font = Enum.Font.Gotham
pEL.TextScaled = true
pEL.Text = ""
pEL.Visible = false

local function uPUI()
    cPrvB.Visible = (cPN > 1)
    if cPC and typeof(cPC.IsFinished) == "boolean" then
        cNxtB.Visible = not cPC.IsFinished
    else cNxtB.Visible = true end
end

local cRId = 0
local function rCP(pD)
    cRId = cRId + 1
    local mR = cRId
    cPgB.Text = "Loading..."
    for _, c in ipairs(cSFm:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local it = nil
    local s, r = pcall(function() return pD:GetCurrentPage() end)
    if s then it = r else cPgB.Text = "ERROR"; return end
    if mR ~= cRId then return end
    if it and #it > 0 then
        eCL.Visible = false
        local mTI = cTId
        local sTm = os.clock()
        for _, i in ipairs(it) do
            if cTId ~= mTI or mR ~= cRId then break end
            local cd = mkCCd(i)
            cd.Parent = cSFm
            if os.clock() - sTm > 0.005 then
                RS.RenderStepped:Wait()
                sTm = os.clock()
            end
        end
    else
        eCL.Visible = true
    end
    if mR == cRId then
        cSFm.CanvasSize = UDim2.new(0, 0, 0, cGL.AbsoluteContentSize.Y + 8)
        cPgB.Text = tostring(cPN) .. " / Enter page"
        uPUI()
    end
end

local function gPO(tP)
    local iP = fCP(cSQ)
    if not iP then return nil end
    for i = 2, tP do
        if iP.IsFinished then break end
        local s = pcall(function() iP:AdvanceToNextPageAsync() end)
        if not s then break end
        if i < tP then task.wait(0.4) end
    end
    return iP
end

pSr = function(q)
    local nq = q or ""
    cPgB.Text = "Loading..."
    local pg = fCP(nq)
    if not pg then return false end
    cSQ = nq
    cPN = 1
    cPC = pg
    rCP(cPC)
    return true
end

rfB.MouseButton1Click:Connect(function() schedCat(true, true, sBx.Text) end)
sBx.FocusLost:Connect(function(eP) if eP then schedCat(true, false, sBx.Text) end end)

local function gNP()
    if not cPC or cPC.IsFinished then return end
    if os.clock() - catLastPage < 0.6 then return end
    catLastPage = os.clock()
    local s = pcall(function() cPC:AdvanceToNextPageAsync() end)
    if s then
        cPN = cPN + 1
        rCP(cPC)
    else
        local tP = cPN + 1
        local nC = gPO(tP)
        if nC then
            cPC = nC
            cPN = math.min(tP, cPN + 1)
            rCP(cPC)
        end
    end
end

local function gPP()
    if not cPC or cPN <= 1 then return end
    if os.clock() - catLastPage < 0.6 then return end
    catLastPage = os.clock()
    local s = pcall(function() cPC:AdvanceToPreviousPageAsync() end)
    if s then
        cPN = math.max(1, cPN - 1)
        rCP(cPC)
    else
        local tP = math.max(1, cPN - 1)
        local nC = gPO(tP)
        if nC then
            cPC = nC
            cPN = tP
            rCP(cPC)
        end
    end
end

cNxtB.MouseButton1Click:Connect(gNP)
cPrvB.MouseButton1Click:Connect(gPP)

UIS.InputBegan:Connect(function(ip, gP)
    if gP then return end
    if ip.UserInputType == Enum.UserInputType.Keyboard then
        if ip.KeyCode == Enum.KeyCode.Right then gNP()
        elseif ip.KeyCode == Enum.KeyCode.Left then gPP() end
    end
end)

cPgB.FocusLost:Connect(function(eP)
    if not eP then return end
    local sn = cPgB.Text:gsub("%s+", "")
    local pN = tonumber(sn:match("%d+"))
    if not pN or pN < 1 then
        pEL.Text = "Invalid page"
        pEL.Visible = true
        task.delay(2, function() if pEL then pEL.Visible = false end end)
        cPgB.Text = tostring(cPN) .. " / Enter page"
        return
    end
    local tN = math.floor(pN)
    if tN == cPN then
        cPgB.Text = tostring(cPN) .. " / Enter page"
        return
    end
    cPgB.Text = "Loading..."
    local s, r = pcall(function() return gPO(tN) end)
    if not s or not r then
        pEL.Text = "Fetch failed"
        pEL.Visible = true
        task.delay(2, function() if pEL then pEL.Visible = false end end)
        cPgB.Text = tostring(cPN) .. " / Enter page"
        return
    end
    cPC = r
    cPN = math.max(1, tN)
    rCP(cPC)
end)

local function mkSCd(it)
    local cd = Instance.new("Frame")
    cd.Size = UDim2.new(0, scl("X", 120), 0, scl("Y", 200))
    cd.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    cd.BackgroundTransparency = 0.1
    mkCr(cd, 10)
    mkSt(cd, Color3.fromRGB(60, 60, 60), 1.5)

    local tn = Instance.new("ImageLabel")
    tn.Size = UDim2.new(1, -scl("X", 10), 0, scl("Y", 100))
    tn.Position = UDim2.new(0, scl("X", 5), 0, scl("Y", 5))
    tn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    tn.BackgroundTransparency = 0.5
    tn.ScaleType = Enum.ScaleType.Fit
    tn.Image = "rbxthumb://type=Asset&id=" .. tonumber(it.AssetId or it.Id) .. "&w=150&h=150"
    tn.Parent = cd
    mkCr(tn, 6)

    local nL = Instance.new("TextLabel")
    nL.Size = UDim2.new(1, -scl("X", 10), 0, scl("Y", 36))
    nL.Position = UDim2.new(0, scl("X", 5), 0, scl("Y", 110))
    nL.BackgroundTransparency = 1
    nL.Text = it.Name or "Unknown"
    nL.TextScaled = true
    nL.TextWrapped = true
    nL.Font = Enum.Font.GothamSemibold
    nL.TextColor3 = Color3.fromRGB(240, 240, 240)
    nL.Parent = cd

    mkPr(cd, it.Price)

    local pB = Instance.new("TextButton")
    pB.Size = UDim2.new(0.45, -scl("X", 5), 0, scl("Y", 26))
    pB.Position = UDim2.new(0, scl("X", 5), 1, -scl("Y", 32))
    pB.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    pB.BackgroundTransparency = 0.1
    pB.Text = "Play"
    pB.Font = Enum.Font.GothamBold
    pB.TextScaled = true
    pB.TextColor3 = Color3.fromRGB(10, 10, 10)
    pB.Parent = cd
    mkCr(pB, 6)
    pB.MouseButton1Click:Connect(function() plEmt(it.Id) end)

    local rmB = Instance.new("TextButton")
    rmB.Size = UDim2.new(0.45, -scl("X", 5), 0, scl("Y", 26))
    rmB.Position = UDim2.new(0.55, 0, 1, -scl("Y", 32))
    rmB.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    rmB.BackgroundTransparency = 0.2
    rmB.Text = "Remove"
    rmB.Font = Enum.Font.GothamBold
    rmB.TextScaled = true
    rmB.TextColor3 = Color3.fromRGB(255, 255, 255)
    rmB.Parent = cd
    mkCr(rmB, 6)
    mkSt(rmB, Color3.fromRGB(120, 40, 40), 1)

    local cB = Instance.new("TextButton")
    cB.Size = UDim2.new(0, scl("X", 26), 0, scl("Y", 26))
    cB.Position = UDim2.new(1, -scl("X", 31), 0, scl("Y", 10))
    cB.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    cB.BackgroundTransparency = 0.2
    cB.Text = "📋"
    cB.Font = Enum.Font.GothamBold
    cB.TextScaled = true
    cB.TextColor3 = Color3.new(1, 1, 1)
    cB.Parent = cd
    mkCr(cB, 6)
    mkSt(cB, Color3.fromRGB(80, 80, 80), 1)
    cB.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard((it.AnimationId:gsub("rbxassetid://", ""))) end
        cB.Text = "✅"
        cB.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        task.wait(0.7)
        cB.Text = "📋"
        cB.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)

    local fB = Instance.new("TextButton")
    fB.Size = UDim2.new(0, scl("X", 26), 0, scl("Y", 26))
    fB.Position = UDim2.new(1, -scl("X", 31), 0, scl("Y", 42))
    fB.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    fB.BackgroundTransparency = 0.2
    fB.Text = it.Favorite and "★" or "☆"
    fB.Font = Enum.Font.GothamBold
    fB.TextScaled = true
    fB.TextColor3 = it.Favorite and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
    fB.Parent = cd
    mkCr(fB, 6)
    mkSt(fB, Color3.fromRGB(80, 80, 80), 1)
    fB.MouseButton1Click:Connect(function()
        it.Favorite = not it.Favorite
        fB.Text = it.Favorite and "★" or "☆"
        fB.TextColor3 = it.Favorite and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
        svEmt()
        if rSvd then rSvd() end
    end)

    rmB.MouseButton1Click:Connect(function()
        for i, sI in ipairs(sEmt) do
            if sI.Id == it.Id then
                table.remove(sEmt, i)
                svEmt()
                if rSvd then rSvd() end
                break
            end
        end
    end)
    return cd
end

sPgB.FocusLost:Connect(function(eP)
    if eP then
        local p = tonumber(sPgB.Text:match("%d+"))
        if p then
            sPN = math.clamp(p, 1, sMxP)
            rSvd()
        else sPgB.Text = sPN .. " / " .. sMxP end
    end
end)

sPrvB.MouseButton1Click:Connect(function()
    if sPN > 1 then sPN = sPN - 1; rSvd() end
end)

sNxtB.MouseButton1Click:Connect(function()
    if sPN < sMxP then sPN = sPN + 1; rSvd() end
end)

rSvd = function()
    sRId = sRId + 1
    local mR = sRId
    for _, c in ipairs(sSFm:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local sQ = (sSBx.Text or ""):lower()
    local fL = {}

    for _, it in ipairs(sEmt) do
        if sQ == "" or (it.Name and it.Name:lower():find(sQ, 1, true)) then
            local pass = true
            if f_FavOnly and not it.Favorite then pass = false end
            local p = tonumber(it.Price) or 0
            if f_MaxPrice >= 0 and p > f_MaxPrice then pass = false end
            if f_MinPrice >= 0 and p < f_MinPrice then pass = false end
            if f_Creator ~= "" then
                local cr = tostring(it.Creator or ""):lower()
                if not cr:find(f_Creator, 1, true) then pass = false end
            end

            if pass then table.insert(fL, it) end
        end
    end

    table.sort(fL, function(a, b)
        if a.Favorite ~= b.Favorite then return a.Favorite end
        if sSrtI == 1 then return (a.Idx or 0) > (b.Idx or 0)
        elseif sSrtI == 2 then return (a.Idx or 0) < (b.Idx or 0)
        elseif sSrtI == 3 then return (a.Name or ""):lower() < (b.Name or ""):lower()
        elseif sSrtI == 4 then return (a.Name or ""):lower() > (b.Name or ""):lower()
        elseif sSrtI == 5 then return (tonumber(a.Price) or 0) > (tonumber(b.Price) or 0)
        elseif sSrtI == 6 then return (tonumber(a.Price) or 0) < (tonumber(b.Price) or 0) end
        return false
    end)
    sMxP = math.max(1, math.ceil(#fL / 12))
    if sPN > sMxP then sPN = sMxP end
    sPgB.Text = sPN .. " / " .. sMxP
    sPrvB.Visible = (sPN > 1)
    sNxtB.Visible = (sPN < sMxP)
    local st = (sPN - 1) * 12 + 1
    local en = math.min(st + 11, #fL)
    if #fL > 0 then
        eSL.Visible = false
        local mTI = cTId
        local sTm = os.clock()
        for i = st, en do
            if cTId ~= mTI or mR ~= sRId then break end
            local cd = mkSCd(fL[i])
            cd.Parent = sSFm
            if os.clock() - sTm > 0.005 then
                RS.RenderStepped:Wait()
                sTm = os.clock()
            end
        end
    else
        eSL.Visible = true
    end
    if mR == sRId then
        sSFm.CanvasSize = UDim2.new(0, 0, 0, sGL.AbsoluteContentSize.Y + 8)
    end
end

cTb.MouseButton1Click:Connect(function()
    fTab = "c"; if fOpen then showFPage() end
    cTId = cTId + 1
    cFm.Visible = true; sFm.Visible = false
    cTb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sTb.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
end)

sSBx:GetPropertyChangedSignal("Text"):Connect(function()
    sPN = 1; rSvd()
end)

sTb.MouseButton1Click:Connect(function()
    fTab = "s"; if fOpen then showFPage() end
    cTId = cTId + 1
    cFm.Visible = false; sFm.Visible = true
    cTb.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    sTb.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    rSvd()
end)

loadStep("Loading catalog")
if pSr("") then catLastSig = catSig(""); catLastAt = os.clock() end
loadStep("Building toggle button")

local function tMUI() mG.Enabled = not mG.Enabled end

local tG = Instance.new("ScreenGui")
tG.Name = "ToggleButtonGui"
tG.ResetOnSpawn = false
tG.Parent = cG
tG.Enabled = false

local tB = Instance.new("TextButton")
tB.Parent = tG
tB.Text = "G"
tB.Font = Enum.Font.GothamSemibold
tB.TextScaled = true
tB.Size = UDim2.new(0, 50, 0, 50)
tB.Position = UDim2.new(0, 20, 0.5, -50)
tB.AnchorPoint = Vector2.new(0, 0.5)
tB.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
tB.BackgroundTransparency = 0.2
tB.TextColor3 = Color3.new(1, 1, 1)
tB.Active = true
pcall(function() tB.Draggable = true end)
mkCr(tB, 12)
mkSt(tB, Color3.fromRGB(120, 120, 120), 2)
local aRC = Instance.new("UIAspectRatioConstraint")
aRC.Parent = tB
aRC.AspectRatio = 1
tB.MouseButton1Click:Connect(tMUI)

UIS.InputBegan:Connect(function(ip, gP)
    if gP then return end
    if ip.UserInputType == Enum.UserInputType.Keyboard and ip.KeyCode == Enum.KeyCode.G then tMUI() end
end)

loadStep("Loading saved list")
rSvd()
loadStep("Ready")
setFSb(true)
mG.Enabled = true
tG.Enabled = true
ldG:Destroy()

task.spawn(function()
    local function sCl(c)
        local h = c:WaitForChild("HumanoidRootPart")
        local bP = {}
        h.CanCollide = true
        local function aP(p)
            if p:IsA("BasePart") and p ~= h then table.insert(bP, p) end
        end
        for _, p in pairs(c:GetDescendants()) do aP(p) end
        local dC = c.DescendantAdded:Connect(aP)
        local hC
        hC = RS.Heartbeat:Connect(function()
            if not c or not c.Parent then hC:Disconnect(); dC:Disconnect(); return end
            for i = 1, #bP do
                local p = bP[i]
                if p and p.Parent then p.CanCollide = false end
            end
        end)
    end
    if lP.Character then sCl(lP.Character) end
    lP.CharacterAdded:Connect(sCl)
end)
