--[[==========================================================================
    Storm  —  Menu FiveM 

    TOUCHES
      SUPPR           ouvrir / fermer le menu
      TAB             basculer barre laterale <-> contenu
      HAUT / BAS      naviguer
      GAUCHE / DROITE modifier une valeur
      PGUP / PGDN     valeur secondaire (texture des vetements)
      ENTREE          valider / ouvrir un sous-menu
      FIN             effacer (slot de tenue, bind, config vehicule)
      RETOUR ARRIERE  remonter d'un niveau
==========================================================================]]

-- ============================ CONFIG / THEME ============================

local CFG = {
    key = {
        toggle = 0x2E, tab = 0x09, enter = 0x0D, clear = 0x23, back = 0x08,
        up = 0x26, down = 0x28, left = 0x25, right = 0x27,
        pgup = 0x21, pgdn = 0x22,
    },

    accent   = { r = 236, g = 72,  b = 98  },
    accentDk = { r = 150, g = 34,  b = 60  },
    accent2  = { r = 168, g = 120, b = 255 },
    bg       = { r = 14,  g = 15,  b = 21  },
    panel    = { r = 22,  g = 24,  b = 33  },
    card     = { r = 30,  g = 33,  b = 45  },
    cardAlt  = { r = 26,  g = 28,  b = 39  },
    chip     = { r = 44,  g = 47,  b = 62  },
    textHi   = { r = 233, g = 236, b = 243 },
    textDim  = { r = 141, g = 147, b = 163 },
    offCol   = { r = 62,  g = 66,  b = 82  },

    sidebarX = 0.075, sidebarW = 0.135,
    contentX = 0.325, contentW = 0.305,
    topY = 0.15, rowH = 0.032, sideRowH = 0.033,
    bannerH = 0.070, maxRows = 12,

    accentPresets = {
        { "Corail", { 236, 72, 98 },   { 150, 34, 60 } },
        { "Cyan",   { 0, 208, 245 },   { 12, 104, 138 } },
        { "Violet", { 168, 108, 255 }, { 92, 46, 158 } },
        { "Vert",   { 64, 220, 130 },  { 24, 118, 76 } },
        { "Or",     { 245, 190, 60 },  { 150, 108, 20 } },
        { "Rose",   { 255, 92, 180 },  { 156, 34, 106 } },
        { "Blanc",  { 236, 238, 245 }, { 120, 124, 138 } },
    },
    bgPresets = {
        { "Nuit",    { 14, 15, 21 }, { 22, 24, 33 }, { 30, 33, 45 }, { 26, 28, 39 } },
        { "Ardoise", { 20, 24, 32 }, { 30, 36, 48 }, { 40, 47, 62 }, { 35, 41, 55 } },
        { "Encre",   { 10, 10, 14 }, { 16, 16, 22 }, { 24, 24, 32 }, { 19, 19, 26 } },
        { "Charbon", { 26, 26, 26 }, { 36, 36, 36 }, { 48, 48, 48 }, { 42, 42, 42 } },
    },
    posPresets = {
        { "Gauche", 0.075, 0.325 },
        { "Centre", 0.335, 0.585 },
        { "Droite", 0.590, 0.840 },
    },
}

-- ============================== ETAT ==============================

local S = {
    open = false, unloaded = false,
    focus = "sidebar", sideIdx = 1, itemIdx = 1, subNode = nil,

    -- apparence
    alpha = 0.96, accentIdx = 1, bgIdx = 1, posIdx = 1,

    -- vetements / tenues
    outfits = {},

    -- vehicule
    neonIdx = 1, smokeIdx = 1, ghostIdx = 1, vehSlots = {},
    rgbR = 255, rgbG = 0, rgbB = 0, windows = false,
    plate = { " ", " ", " ", " ", " ", " ", " ", " " },
    win = {}, locked = false, powerMult = 1.0, torqueMult = 1.0,
    muteSiren = false, highBeam = false, interiorLight = false,
    driftTyres = false, lightR = 255, lightG = 255, lightB = 255, lightMult = 1.0,

    -- joueur
    godmode = false, noRagdoll = false, fireProof = false, infLungs = false,
    superJump = false, invisible = false, autoHeal = false,
    runSpeed = 1.0, swimSpeed = 1.0, pedModelIdx = 1,

    -- monde
    hour = 12, freezeTime = false, weatherIdx = 1, freezeWeather = false,
    gravityIdx = 1, blackout = false, trafficIdx = 5, pedDensIdx = 5,

    -- scripts importes (LUA)
    tkOn = false, tkVeh = nil, tkFly = false, tkSpeed = 50.0,
    atOn = false, atV1 = nil, atV2 = nil, atStuck = false,
    atOx = 0.0, atOy = -1.9, atOz = 0.2, atRx = 0.0, atRz = 0.0,
    tpOn = false, tpVeh = nil,

    -- troll : reglages generaux
    waterproof = false, popBang = false, drift = false, driftBak = nil,
    godVeh = false, vehJump = false, moonGrav = false, autoRight = false,
    rocket = false, noColl = false, noCollVeh = nil,

    -- troll : tank
    tankOn = false, tankForce = 55.0, tankRadius = 7.0, tankLift = 9.0,
    tankScale = 1.0, tankGod = true, tankPeds = false,

    -- troll : destruction
    dRadius = 15.0, dForce = 70.0, dLift = 14.0, dPeds = false,
    dShock = false, dMagnet = false, dLevit = false, dCrush = false,
    dWake = false, dPanic = false, dBoom = false,
    levitated = {}, boomCd = {},

    -- divers
    hazard = false,

    -- confirmation des actions destructrices
    confirmId = nil, confirmUntil = 0,

    -- binds
    binds = {}, bindPrev = {}, bindCapture = nil,
}

-- ============================ UTILITAIRES ============================

local function ped() return PlayerPedId() end

local function notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("Storm - " .. msg)
    EndTextCommandThefeedPostTicker(false, false)
end

-- Gestion des touches avec detection de front + repetition automatique.
-- On ne depend plus de la semantique exacte d'IsRawKeyPressed (front ou niveau
-- selon les executeurs) : le comportement est identique dans les deux cas.
local kState = {}

local function keyEdge(vk, repeatable)
    local st = kState[vk]
    if not st then
        st = { down = false, next = 0 }
        kState[vk] = st
    end
    local down = IsRawKeyPressed(vk)
    local now = GetGameTimer()
    local fired = false

    if down and not st.down then
        fired = true
        st.next = now + 300          -- pause avant la repetition
    elseif down and st.down and repeatable and now >= st.next then
        fired = true
        st.next = now + 55           -- cadence de repetition
    end

    st.down = down
    return fired
end

-- navigation et valeurs : repetition active (on peut maintenir la touche)
local function key(vk) return keyEdge(vk, true) end
-- actions et bascules : un seul declenchement par appui
local function keyOnce(vk) return keyEdge(vk, false) end

local function sound(name)
    PlaySoundFrontend(-1, name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

local function veh()
    local p = ped()
    if IsPedInAnyVehicle(p, false) then return GetVehiclePedIsIn(p, false) end
    return nil
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function cycle(v, lo, hi)
    if v > hi then return lo end
    if v < lo then return hi end
    return v
end

-- Controle reseau : sans ca le vrai proprietaire resynchronise l'entite -> desync
local function grab(e)
    if not DoesEntityExist(e) then return end
    local ok, net = pcall(NetworkGetEntityIsNetworked, e)
    if ok and net then
        local okc, has = pcall(NetworkHasControlOfEntity, e)
        if okc and not has then pcall(NetworkRequestControlOfEntity, e) end
    end
end

local function force(e, fx, fy, fz, ox, oy, oz)
    grab(e)
    ApplyForceToEntity(e, 1, fx, fy, fz, ox or 0.0, oy or 0.0, oz or 0.0,
        0, true, true, true, false, true)
end

-- parcourt vehicules (+ pietons) autour d'un point
local function around(origin, radius, withPeds, selfVeh, selfPed, fn)
    local pool = GetGamePool("CVehicle")
    for i = 1, #pool do
        local e = pool[i]
        if e ~= selfVeh and DoesEntityExist(e) then
            local c = GetEntityCoords(e)
            local d = #(origin - c)
            if d > 0.1 and d < radius then fn(e, c, d, false) end
        end
    end
    if withPeds then
        local peds = GetGamePool("CPed")
        for i = 1, #peds do
            local e = peds[i]
            if e ~= selfPed and DoesEntityExist(e) and not IsPedInAnyVehicle(e, false) then
                local c = GetEntityCoords(e)
                local d = #(origin - c)
                if d > 0.1 and d < radius then fn(e, c, d, true) end
            end
        end
    end
end

local function camDir()
    local r = GetGameplayCamRot(2)
    local yaw, pitch = math.rad(r.z), math.rad(r.x)
    local cp = math.cos(pitch)
    return -math.sin(yaw) * cp, math.cos(yaw) * cp, math.sin(pitch)
end

-- ============================ DESSIN ============================

local function uiA(a) return math.floor((a or 255) * S.alpha) end

local function txt(x, y, s, scale, c, a, centered)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextScale(scale, scale)
    SetTextColour(c.r, c.g, c.b, a or 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(centered or false)
    AddTextComponentString(s)
    DrawText(x, y)
end

local function rect(x, y, w, h, c, a)
    DrawRect(x, y, w, h, c.r, c.g, c.b, a or 255)
end

local function raw(x, y, w, h, r, g, b, a)
    DrawRect(x, y, w, h, r, g, b, a)
end

local function grad(cx, cy, w, h, c1, c2, steps, alpha)
    steps = steps or 8
    local sh = h / steps
    local top = cy - h / 2
    local a = uiA(alpha or 255)
    for i = 0, steps - 1 do
        local t = (steps == 1) and 0 or (i / (steps - 1))
        raw(cx, top + sh * i + sh / 2, w, sh + 0.0004,
            math.floor(c1.r + (c2.r - c1.r) * t),
            math.floor(c1.g + (c2.g - c1.g) * t),
            math.floor(c1.b + (c2.b - c1.b) * t), a)
    end
end

local function shadow(cx, cy, w, h)
    raw(cx, cy + 0.0016, w + 0.0055, h + 0.0045, 0, 0, 0, uiA(70))
    raw(cx, cy + 0.0010, w + 0.0028, h + 0.0024, 0, 0, 0, uiA(90))
end

local function switch(cx, cy, on)
    local w, h = 0.0225, 0.0112
    if on then
        grad(cx, cy, w, h, CFG.accent, CFG.accentDk, 4)
    else
        rect(cx, cy, w, h, CFG.offCol, uiA(255))
    end
    raw(cx, cy - h / 2 + 0.0008, w - 0.0016, 0.0010, 255, 255, 255, uiA(on and 70 or 26))
    local kx = on and (cx + w / 2 - 0.0040) or (cx - w / 2 + 0.0040)
    raw(kx, cy + 0.0008, 0.0072, 0.0072, 0, 0, 0, uiA(80))
    raw(kx, cy, 0.0072, 0.0072, 250, 250, 253, 255)
end

local function chip(rightX, cy, s, col)
    s = tostring(s)
    local c = col or CFG.textDim
    local w = 0.017 + (#s * 0.0052)
    local cx = rightX - w / 2
    local h = CFG.rowH * 0.56
    rect(cx, cy, w, h, CFG.chip, uiA(255))
    raw(cx, cy - h / 2 + 0.0007, w, 0.0009, 255, 255, 255, uiA(22))
    raw(cx - w / 2 + 0.0020, cy, 0.0028, h * 0.62, c.r, c.g, c.b, 255)
    txt(cx - w / 2 + 0.0082, cy - 0.0086, s, 0.26, CFG.textHi, 255, false)
end

-- ======================= VETEMENTS & TENUES =======================

local CLOTHES = {
    { 1, "Masque", false }, { 2, "Cheveux", false }, { 3, "Torse / Bras", false },
    { 4, "Jambes", false }, { 5, "Sac a dos", false }, { 6, "Chaussures", false },
    { 7, "Accessoires", false }, { 8, "Sous-vetement", false },
    { 9, "Gilet pare-balles", false }, { 11, "Veste / Torse 2", false },
}

local PROPS = {
    { 0, "Chapeau / Casquette", true }, { 1, "Lunettes", true },
    { 2, "Oreilles", true }, { 6, "Montre", true }, { 7, "Bracelet", true },
}

local ALLWEAR = {}
for _, v in ipairs(CLOTHES) do ALLWEAR[#ALLWEAR + 1] = v end
for _, v in ipairs(PROPS) do ALLWEAR[#ALLWEAR + 1] = v end

local function wearGet(id, isProp)
    local p = ped()
    if isProp then return GetPedPropIndex(p, id), GetPedPropTextureIndex(p, id) end
    return GetPedDrawableVariation(p, id), GetPedTextureVariation(p, id)
end

local function wearSet(id, isProp, d, t)
    local p = ped()
    if isProp then
        if d < 0 then ClearPedProp(p, id) else SetPedPropIndex(p, id, d, t, true) end
    else
        SetPedComponentVariation(p, id, d, t, 0)
    end
end

local function wearDraw(id, isProp, dir)
    local p = ped()
    local d = wearGet(id, isProp)
    local maxd = isProp and GetNumberOfPedPropDrawableVariations(p, id)
        or GetNumberOfPedDrawableVariations(p, id)
    if maxd <= 0 then return end
    local lo = isProp and -1 or 0
    d = cycle(d + dir, lo, maxd - 1)
    wearSet(id, isProp, d, 0)
end

local function wearTex(id, isProp, dir)
    local p = ped()
    local d, t = wearGet(id, isProp)
    if d < 0 then return end
    local maxt = isProp and GetNumberOfPedPropTextureVariations(p, id, d)
        or GetNumberOfPedTextureVariations(p, id, d)
    if maxt <= 0 then return end
    wearSet(id, isProp, d, cycle(t + dir, 0, maxt - 1))
end

local OUTFIT_SLOTS = 8

local function outfitSave(i)
    local data = {}
    for k, w in ipairs(ALLWEAR) do
        local d, t = wearGet(w[1], w[3])
        data[k] = { d = d, t = t }
    end
    S.outfits[i] = data
    pcall(SetResourceKvp, "Storm_outfit_" .. i, json.encode(data))
    notify("tenue sauvegardee (slot " .. i .. ")")
end

local function outfitLoad(i)
    local data = S.outfits[i]
    if not data then notify("slot vide") return end
    for k, w in ipairs(ALLWEAR) do
        local sv = data[k]
        if sv then wearSet(w[1], w[3], sv.d, sv.t) end
    end
    notify("tenue chargee (slot " .. i .. ")")
end

local function outfitClear(i)
    S.outfits[i] = nil
    pcall(DeleteResourceKvp, "Storm_outfit_" .. i)
    notify("slot " .. i .. " efface")
end

-- ========================= VEHICULE (LSC) =========================

local NEONS = {
    { 255, 0, 0, "Rouge" }, { 0, 100, 255, "Bleu" }, { 0, 255, 60, "Vert" },
    { 170, 0, 255, "Violet" }, { 255, 255, 255, "Blanc" }, { 255, 230, 0, "Jaune" },
    { 0, 255, 255, "Cyan" }, { 255, 0, 150, "Rose" },
}
local PLATES = { "Bleu/Blanc", "Jaune/Bleu", "Jaune/Noir", "Bleu/Blanc 2", "Bleu/Blanc 3", "Dakota" }
local GHOST_STEPS = { 255, 204, 153, 102, 51 }

-- lecture / ecriture d'un mod, tolerant a l'absence de vehicule
local function modGet(t)
    local v = veh()
    if not v then return "--" end
    local cur, max = GetVehicleMod(v, t), GetNumVehicleMods(v, t)
    if max <= 0 then return "N/A" end
    return (cur == -1) and "Stock" or ((cur + 1) .. "/" .. max)
end

local function modSet(t, dir)
    local v = veh()
    if not v then notify("montez dans un vehicule") return end
    SetVehicleModKit(v, 0)
    local max = GetNumVehicleMods(v, t)
    if max <= 0 then return end
    SetVehicleMod(v, t, cycle(GetVehicleMod(v, t) + dir, -1, max - 1), false)
end

local function togMod(t)
    local v = veh()
    if not v then return false end
    return IsToggleModOn(v, t)
end

local function togModSet(t)
    local v = veh()
    if not v then notify("montez dans un vehicule") return end
    SetVehicleModKit(v, 0)
    ToggleVehicleMod(v, t, not IsToggleModOn(v, t))
end

local function handGet(f)
    local v = veh()
    if not v then return nil end
    return GetVehicleHandlingFloat(v, "CHandlingData", f)
end

local function handSet(f, val)
    local v = veh()
    if v then SetVehicleHandlingFloat(v, "CHandlingData", f, val) end
end

-- construit directement une entree de menu pour un champ de handling
local function HAND(label, f, step, lo, hi, fmt)
    return {
        kind = "num", label = label,
        get = function()
            local x = handGet(f)
            return x and string.format(fmt or "%.1f", x) or "--"
        end,
        change = function(d)
            local x = handGet(f)
            if not x then notify("montez dans un vehicule") return end
            handSet(f, clamp(x + d * step, lo, hi))
        end,
    }
end

-- slots de configuration vehicule
local VEH_SLOTS = 4

local function vehCapture(v)
    local cfg = { mods = {}, tog = {} }
    SetVehicleModKit(v, 0)
    for t = 0, 48 do cfg.mods[t] = GetVehicleMod(v, t) end
    for t = 17, 22 do cfg.tog[t] = IsToggleModOn(v, t) end
    local c1, c2 = GetVehicleColours(v)
    cfg.c1, cfg.c2 = c1, c2
    cfg.wheel = GetVehicleWheelType(v)
    cfg.tint = GetVehicleWindowTint(v)
    cfg.plate = GetVehicleNumberPlateTextIndex(v)
    cfg.neon = IsVehicleNeonLightEnabled(v, 0)
    cfg.neonIdx = S.neonIdx
    return cfg
end

local function vehApply(v, cfg)
    SetVehicleModKit(v, 0)
    for t = 0, 48 do
        if cfg.mods[t] ~= nil then SetVehicleMod(v, t, cfg.mods[t], false) end
    end
    for t = 17, 22 do
        if cfg.tog[t] ~= nil then ToggleVehicleMod(v, t, cfg.tog[t]) end
    end
    SetVehicleColours(v, cfg.c1 or 0, cfg.c2 or 0)
    SetVehicleWheelType(v, cfg.wheel or 0)
    SetVehicleWindowTint(v, cfg.tint or 0)
    SetVehicleNumberPlateTextIndex(v, cfg.plate or 0)
    if cfg.neon then
        local c = NEONS[cfg.neonIdx or 1]
        SetVehicleNeonLightsColour(v, c[1], c[2], c[3])
        for i = 0, 3 do SetVehicleNeonLightEnabled(v, i, true) end
    end
end

local function vehSlotSave(i)
    local v = veh()
    if not v then notify("montez dans un vehicule") return end
    local cfg = vehCapture(v)
    S.vehSlots[i] = cfg
    pcall(SetResourceKvp, "Storm_veh_" .. i, json.encode(cfg))
    notify("config vehicule sauvegardee (slot " .. i .. ")")
end

local function vehSlotLoad(i)
    local v = veh()
    if not v then notify("montez dans un vehicule") return end
    local cfg = S.vehSlots[i]
    if not cfg then notify("slot vide") return end
    vehApply(v, cfg)
    notify("config appliquee (slot " .. i .. ")")
end

local function vehSlotClear(i)
    S.vehSlots[i] = nil
    pcall(DeleteResourceKvp, "Storm_veh_" .. i)
    notify("slot config " .. i .. " efface")
end

-- ============================ JOUEUR ============================

local PED_MODELS = {
    "mp_m_freemode_01", "mp_f_freemode_01", "a_m_y_business_01",
    "s_m_y_cop_01", "s_m_m_paramedic_01", "a_m_m_farmer_01",
    "u_m_y_zombie_01", "s_m_y_swat_01", "ig_trevor", "ig_michael", "ig_franklin",
}

local function applyPedModel()
    local name = PED_MODELS[S.pedModelIdx]
    local hash = GetHashKey(name)
    RequestModel(hash)
    local tries = 0
    while not HasModelLoaded(hash) and tries < 200 do
        Wait(0)
        tries = tries + 1
    end
    if HasModelLoaded(hash) then
        SetPlayerModel(PlayerId(), hash)
        SetPedDefaultComponentVariation(ped())
        SetModelAsNoLongerNeeded(hash)
        notify("modele applique : " .. name)
    else
        notify("modele indisponible")
    end
end

local function doHeal()
    local p = ped()
    SetEntityMaxHealth(p, 200)
    SetEntityHealth(p, 200)
    SetPedArmour(p, 100)
    ClearPedBloodDamage(p)
    notify("soigne")
end

local function doRevive()
    local pid, p = PlayerId(), ped()
    local c = GetEntityCoords(p)
    NetworkResurrectLocalPlayer(c.x, c.y, c.z, GetEntityHeading(p), true, false)
    SetEntityMaxHealth(p, 200)
    SetEntityHealth(p, 200)
    SetPedArmour(p, 100)
    ClearPedTasksImmediately(p)
    ClearPedSecondaryTask(p)
    ResetPedRagdollTimer(p)
    SetPedCanRagdoll(p, false)
    SetPlayerControl(pid, true, 0)
    FreezeEntityPosition(p, false)
    SetEntityCollision(p, true, true)
    SetEntityVisible(p, true, false)
    SetPlayerSprint(pid, true)
    ClearPedBloodDamage(p)
    ClearPedLastWeaponDamage(p)
    CreateThread(function()
        local dl = GetGameTimer() + 2000
        while GetGameTimer() < dl and not S.unloaded do
            Wait(0)
            local q = ped()
            if GetEntityHealth(q) < 200 then SetEntityHealth(q, 200) end
            ResetPedRagdollTimer(q)
            ClearPedTasksImmediately(q)
            SetPlayerControl(pid, true, 0)
        end
        SetPedCanRagdoll(ped(), true)
    end)
    notify("revive applique")
end

CreateThread(function()
    while not S.unloaded do
        local active = S.godmode or S.noRagdoll or S.fireProof or S.infLungs
            or S.superJump or S.invisible or S.autoHeal
        if active then
            Wait(0)
            local p = ped()
            if S.godmode then
                SetEntityInvincible(p, true)
                SetPlayerInvincible(PlayerId(), true)
            end
            if S.noRagdoll then SetPedCanRagdoll(p, false) end
            if S.fireProof then SetEntityProofs(p, false, true, false, false, false, false, false, false) end
            if S.infLungs then SetPedMaxTimeUnderwater(p, 9999.0) end
            if S.superJump then SetSuperJumpThisFrame(PlayerId()) end
            if S.invisible then SetEntityVisible(p, false, false) end
            if S.autoHeal and GetEntityHealth(p) < GetEntityMaxHealth(p) then
                SetEntityHealth(p, math.min(GetEntityMaxHealth(p), GetEntityHealth(p) + 1))
            end
        else
            Wait(250)
        end
    end
end)

-- appliquer en continu les multiplicateurs de vitesse
CreateThread(function()
    while not S.unloaded do
        Wait(200)
        local pid = PlayerId()
        SetRunSprintMultiplierForPlayer(pid, S.runSpeed)
        SetSwimMultiplierForPlayer(pid, S.swimSpeed)
    end
end)

-- ============================= MONDE =============================

local WEATHERS = {
    "CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST", "RAIN", "CLEARING",
    "THUNDER", "SMOG", "FOGGY", "SNOW", "SNOWLIGHT", "BLIZZARD", "XMAS", "HALLOWEEN",
}
local GRAVITY = { { "Normale", 9.8 }, { "Lune", 2.4 }, { "Faible", 0.5 }, { "Zero", 0.0 } }

local function applyWeather()
    local w = WEATHERS[S.weatherIdx]
    SetWeatherTypeOverTime(w, 5.0)
    CreateThread(function()
        Wait(6000)
        pcall(SetWeatherTypeNowPersist, w)
    end)
    notify("meteo : " .. w)
end

local function applyGravity()
    pcall(SetGravityLevel, S.gravityIdx - 1)
    notify("gravite : " .. GRAVITY[S.gravityIdx][1])
end

CreateThread(function()
    while not S.unloaded do
        if S.freezeTime or S.freezeWeather or S.blackout
            or S.trafficIdx ~= 5 or S.pedDensIdx ~= 5 then
            Wait(0)
            if S.freezeTime then NetworkOverrideClockTime(math.floor(S.hour), 0, 0) end
            if S.freezeWeather then
                SetWeatherTypeNow(WEATHERS[S.weatherIdx])
                SetOverrideWeather(WEATHERS[S.weatherIdx])
            end
            if S.blackout then SetArtificialLightsState(true) end
            if S.trafficIdx ~= 5 then
                local m = (S.trafficIdx - 1) / 4.0
                SetVehicleDensityMultiplierThisFrame(m)
                SetRandomVehicleDensityMultiplierThisFrame(m)
                SetParkedVehicleDensityMultiplierThisFrame(m)
            end
            if S.pedDensIdx ~= 5 then
                local m = (S.pedDensIdx - 1) / 4.0
                SetPedDensityMultiplierThisFrame(m)
                SetScenarioPedDensityMultiplierThisFrame(m, m)
            end
        else
            Wait(300)
        end
    end
end)

-- ================== LUA : TELEKINESIE / ATTACHE / TP ==================

local function tkReset()
    if S.tkVeh and DoesEntityExist(S.tkVeh) then
        SetEntityDrawOutline(S.tkVeh, false)
        if S.tkFly then SetEntityHasGravity(S.tkVeh, true) end
    end
    S.tkVeh, S.tkFly = nil, false
end

CreateThread(function()
    while not S.unloaded do
        if S.tkOn then
            Wait(0)
            if IsControlJustPressed(0, 246) then -- Y
                if S.tkVeh and DoesEntityExist(S.tkVeh) then SetEntityDrawOutline(S.tkVeh, false) end
                local pc = GetEntityCoords(ped())
                local pool, best, bd = GetGamePool("CVehicle"), nil, 10.0
                for i = 1, #pool do
                    local d = #(pc - GetEntityCoords(pool[i]))
                    if d < bd then best, bd = pool[i], d end
                end
                S.tkVeh = best
            end
            if S.tkVeh and DoesEntityExist(S.tkVeh) then
                if IsControlPressed(0, 191) then
                    SetEntityDrawOutline(S.tkVeh, true)
                    SetEntityDrawOutlineColor(255, 255, 0, 255)
                else
                    SetEntityDrawOutline(S.tkVeh, false)
                end
                if IsControlJustReleased(0, 14) then S.tkSpeed = math.max(10.0, S.tkSpeed - 10.0) end
                if IsControlJustReleased(0, 15) then S.tkSpeed = math.min(200.0, S.tkSpeed + 10.0) end
                if IsControlPressed(0, 45) then -- R
                    grab(S.tkVeh)
                    if not S.tkFly then
                        S.tkFly = true
                        SetEntityHasGravity(S.tkVeh, false)
                    end
                    local r = GetGameplayCamRot(2)
                    SetEntityRotation(S.tkVeh, r.x, r.y, r.z, 2, true)
                    local dx, dy, dz = camDir()
                    SetEntityVelocity(S.tkVeh, dx * S.tkSpeed, dy * S.tkSpeed, dz * S.tkSpeed)
                elseif S.tkFly then
                    S.tkFly = false
                    SetEntityHasGravity(S.tkVeh, true)
                end
            end
        else
            Wait(250)
        end
    end
end)

local function atAttach()
    if S.atV1 and S.atV2 then
        AttachEntityToEntity(S.atV2, S.atV1, -1, S.atOx, S.atOy, S.atOz,
            S.atRx, 0.0, S.atRz, false, true, false, false, 2, true)
        S.atStuck = true
    end
end

local function atReset()
    if S.atV2 and DoesEntityExist(S.atV2) then
        SetEntityDrawOutline(S.atV2, false)
        if S.atStuck then
            DetachEntity(S.atV2, true, true)
            SetEntityCollision(S.atV2, true, true)
            SetEntityCompletelyDisableCollision(S.atV2, false, false)
        end
    end
    S.atV1, S.atV2, S.atStuck = nil, nil, false
    S.atOx, S.atOy, S.atOz, S.atRx, S.atRz = 0.0, -1.9, 0.2, 0.0, 0.0
end

local function atTarget()
    local p = ped()
    local cc = GetGameplayCamCoord()
    local dx, dy, dz = camDir()
    local ray = StartExpensiveSynchronousShapeTestLosProbe(cc.x, cc.y, cc.z,
        cc.x + dx * 1500.0, cc.y + dy * 1500.0, cc.z + dz * 1500.0, 10, p, 7)
    local _, hit, _, _, ent = GetShapeTestResult(ray)
    if hit and DoesEntityExist(ent) and IsEntityAVehicle(ent) then return ent end

    local pool, best, bestD = GetGamePool("CVehicle"), nil, math.huge
    for i = 1, #pool do
        local v2 = pool[i]
        if DoesEntityExist(v2) then
            local c = GetEntityCoords(v2)
            local d3 = #(cc - c)
            if d3 <= 200.0 then
                local on, sx, sy = GetScreenCoordFromWorldCoord(c.x, c.y, c.z)
                if on then
                    local ddx, ddy = sx - 0.5, sy - 0.5
                    local sd = math.sqrt(ddx * ddx + ddy * ddy)
                    local maxSd = (3.0 / 90.0) * math.max(0.01, 100.0 / d3)
                    if sd <= maxSd and sd < bestD then best, bestD = v2, sd end
                end
            end
        end
    end
    return best
end

CreateThread(function()
    while not S.unloaded do
        if S.atOn then
            Wait(0)
            if IsControlJustPressed(0, 311) then -- K
                local t = atTarget()
                local cur = veh()
                if S.atV2 then SetEntityDrawOutline(S.atV2, false) end
                if t and t ~= cur then
                    S.atV2 = t
                    SetEntityDrawOutline(t, true)
                    SetEntityDrawOutlineColor(255, 0, 255, 255)
                    SetEntityDrawOutlineShader(1)
                else
                    S.atV2 = nil
                end
            end
            if S.atV2 and DoesEntityExist(S.atV2) and not S.atStuck then
                SetEntityDrawOutline(S.atV2, true)
                SetEntityDrawOutlineColor(255, 0, 255, 255)
            end
            if IsControlJustPressed(0, 74) then -- H
                local cur = veh()
                if cur and S.atV2 and DoesEntityExist(S.atV2) and cur ~= S.atV2 then
                    if S.atStuck then
                        DetachEntity(S.atV2, true, true)
                        SetEntityCollision(S.atV2, true, true)
                    end
                    grab(S.atV2)
                    S.atV1 = cur
                    atAttach()
                    SetEntityCollision(S.atV2, false, true)
                    SetEntityCompletelyDisableCollision(S.atV2, true, true)
                    SetEntityDrawOutline(S.atV2, false)
                end
            end
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while not S.unloaded do
        if S.atOn and not S.open and S.atStuck and S.atV1 and S.atV2 then
            Wait(0)
            local ch = false
            if not IsControlPressed(0, 36) then
                if IsControlPressed(0, 172) then S.atOy = S.atOy + 0.35 ch = true end
                if IsControlPressed(0, 173) then S.atOy = S.atOy - 0.35 ch = true end
                if IsControlPressed(0, 174) then S.atOx = S.atOx - 0.15 ch = true end
                if IsControlPressed(0, 175) then S.atOx = S.atOx + 0.15 ch = true end
            else
                if IsControlPressed(0, 172) then S.atOz = S.atOz + 0.15 ch = true end
                if IsControlPressed(0, 173) then S.atOz = S.atOz - 0.15 ch = true end
                if IsControlPressed(0, 175) then S.atRz = S.atRz - 4.0 ch = true end
                if IsControlPressed(0, 174) then S.atRz = S.atRz + 4.0 ch = true end
            end
            if IsControlPressed(0, 245) then S.atRx = S.atRx + 4.0 ch = true end
            if IsControlPressed(0, 303) then S.atRx = S.atRx - 4.0 ch = true end
            if ch then
                SetEntityCompletelyDisableCollision(S.atV2, true, true)
                atAttach()
                Wait(100)
            end
        else
            Wait(120)
        end
    end
end)

RegisterCommand("detachveh", function()
    if S.atV2 and S.atStuck then
        DetachEntity(S.atV2, true, true)
        SetEntityCollision(S.atV2, true, true)
        SetEntityCompletelyDisableCollision(S.atV2, false, false)
        SetEntityDrawOutline(S.atV2, false)
        S.atStuck = false
    end
end, false)

CreateThread(function()
    while not S.unloaded do
        Wait(1000)
        if S.tpOn then
            local v = GetVehiclePedIsIn(ped(), false)
            if v ~= 0 then S.tpVeh = v end
        end
    end
end)

CreateThread(function()
    while not S.unloaded do
        Wait(0)
        if S.tpOn and IsControlJustReleased(0, 104) then -- H
            if S.tpVeh and DoesEntityExist(S.tpVeh) then
                grab(S.tpVeh)
                SetEntityCoords(S.tpVeh, 15000.0, 15000.0, 2500.0, false, false, false, true)
                SetEntityHeading(S.tpVeh, 0.0)
                notify("vehicule teleporte")
            else
                notify("aucun vehicule precedent")
            end
        end
    end
end)

-- ===================== TROLL : EFFETS SIMPLES =====================

CreateThread(function()
    while not S.unloaded do
        if S.waterproof or S.godVeh or S.vehJump or S.moonGrav or S.autoRight
            or S.rocket or S.popBang then
            Wait(0)
            local p = ped()
            local v = IsPedInAnyVehicle(p, false) and GetVehiclePedIsIn(p, false) or nil

            if v then
                if S.waterproof then
                    SetVehicleEngineOn(v, true, true, false)
                    SetVehicleUndriveable(v, false)
                    SetVehiclePetrolTankHealth(v, 1000.0)
                    SetPedMaxTimeUnderwater(p, 9999.0)
                    if IsEntityInWater(v) then
                        local vel = GetEntityVelocity(v)
                        local lift = 1.2
                        if vel.z < 0.0 then lift = lift - vel.z * 0.9 end
                        force(v, 0.0, 0.0, lift)
                    end
                end

                if S.godVeh then
                    SetEntityInvincible(v, true)
                    SetVehicleCanBeVisiblyDamaged(v, false)
                    SetVehicleStrong(v, true)
                    SetVehicleTyresCanBurst(v, false)
                    SetEntityProofs(v, true, true, true, true, true, true, true, true)
                end

                if S.vehJump and IsRawKeyPressed(0x4A) then -- J
                    force(v, 0.0, 0.0, 12.0)
                    Wait(300)
                end

                if S.rocket and IsRawKeyPressed(0x42) then -- B
                    local f = GetEntityForwardVector(v)
                    force(v, f.x * 22.0, f.y * 22.0, f.z * 22.0 + 1.0)
                end

                if S.moonGrav and IsEntityInAir(v) then
                    local vel = GetEntityVelocity(v)
                    if vel.z < 0.0 then SetEntityVelocity(v, vel.x, vel.y, vel.z * 0.90) end
                end

                if S.popBang and GetPedInVehicleSeat(v, -1) == p then
                    if GetVehicleCurrentRpm(v) > 0.55 and not IsControlPressed(0, 71)
                        and math.random() < 0.05 then
                        pcall(function()
                            RequestNamedPtfxAsset("veh_backfire")
                            if HasNamedPtfxAssetLoaded("veh_backfire") then
                                for _, b in ipairs({ "exhaust", "exhaust_2", "exhaust_3", "exhaust_4" }) do
                                    local bi = GetEntityBoneIndexByName(v, b)
                                    if bi ~= -1 then
                                        UseParticleFxAssetNextCall("veh_backfire")
                                        StartParticleFxNonLoopedOnEntityBone("veh_backfire_muzzle",
                                            v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, bi, 1.0, false, false, false)
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while not S.unloaded do
        if S.autoRight then
            Wait(250)
            local v = veh()
            if v and math.abs(GetEntityRoll(v)) > 75.0 and GetEntitySpeed(v) < 3.0 then
                SetVehicleOnGroundProperly(v)
            end
        else
            Wait(400)
        end
    end
end)

CreateThread(function()
    while not S.unloaded do
        if S.noColl and S.noCollVeh and DoesEntityExist(S.noCollVeh) then
            Wait(100)
            local c = GetEntityCoords(S.noCollVeh)
            for _, pool in ipairs({ GetGamePool("CVehicle"), GetGamePool("CPed"), GetGamePool("CObject") }) do
                for i = 1, #pool do
                    local e = pool[i]
                    if e ~= S.noCollVeh and DoesEntityExist(e)
                        and #(c - GetEntityCoords(e)) <= 60.0 then
                        SetEntityNoCollisionEntity(S.noCollVeh, e, true)
                    end
                end
            end
        else
            Wait(300)
        end
    end
end)

-- ======================== TROLL : MODE TANK ========================

CreateThread(function()
    while not S.unloaded do
        if S.tankOn then
            Wait(0)
            local p = ped()
            local v = IsPedInAnyVehicle(p, false) and GetVehiclePedIsIn(p, false) or nil
            if v then
                local origin = GetEntityCoords(v)
                if S.tankGod then
                    SetEntityInvincible(v, true)
                    SetVehicleStrong(v, true)
                    SetVehicleTyresCanBurst(v, false)
                end
                local sc = clamp(GetEntitySpeed(v) / 12.0, 0.35, 2.5)
                sc = 1.0 + (sc - 1.0) * S.tankScale
                local pw = S.tankForce * sc
                around(origin, S.tankRadius, S.tankPeds, v, p, function(e, c, d, isPed)
                    local dx, dy = (c.x - origin.x) / d, (c.y - origin.y) / d
                    force(e, dx * pw, dy * pw, S.tankLift)
                    if isPed then
                        SetPedToRagdoll(e, 2000, 2000, 0, false, false, false)
                    else
                        SetVehicleOutOfControl(e, false, true)
                    end
                end)
            end
        else
            Wait(250)
        end
    end
end)

-- ======================= TROLL : DESTRUCTION =======================

local function levitStop()
    for e in pairs(S.levitated) do
        if DoesEntityExist(e) then
            grab(e)
            SetEntityHasGravity(e, true)
        end
    end
    S.levitated = {}
end

CreateThread(function()
    local shockPrev = false
    while not S.unloaded do
        if S.dShock or S.dMagnet or S.dLevit or S.dCrush or S.dWake or S.dPanic or S.dBoom then
            Wait(0)
            local p = ped()
            local v = IsPedInAnyVehicle(p, false) and GetVehiclePedIsIn(p, false) or nil
            local origin = GetEntityCoords(v or p)

            local shockNow = S.dShock and IsRawKeyPressed(0x58) -- X
            if shockNow and not shockPrev then
                around(origin, S.dRadius, S.dPeds, v, p, function(e, c, d, isPed)
                    local dx, dy = (c.x - origin.x) / d, (c.y - origin.y) / d
                    local fo = 1.0 - (d / S.dRadius) * 0.5
                    local f = S.dForce * fo * (isPed and 0.4 or 1.0)
                    force(e, dx * f, dy * f, S.dLift * fo)
                    if isPed then SetPedToRagdoll(e, 2000, 2000, 0, false, false, false) end
                end)
            end
            shockPrev = shockNow

            if S.dMagnet and IsRawKeyPressed(0x56) then -- V
                around(origin, S.dRadius, S.dPeds, v, p, function(e, c, d, isPed)
                    local dx, dy = (origin.x - c.x) / d, (origin.y - c.y) / d
                    local f = S.dForce * 0.35 * (isPed and 0.4 or 1.0)
                    force(e, dx * f, dy * f, 1.5)
                end)
            end

            if S.dLevit and IsRawKeyPressed(0x43) then -- C
                around(origin, S.dRadius, S.dPeds, v, p, function(e)
                    if not S.levitated[e] then
                        grab(e)
                        SetEntityHasGravity(e, false)
                        S.levitated[e] = true
                    end
                    force(e, 0.0, 0.0, S.dLift * 0.45)
                end)
            elseif next(S.levitated) then
                levitStop()
            end

            if S.dCrush and IsRawKeyPressed(0x4E) then -- N
                around(origin, S.dRadius, S.dPeds, v, p, function(e, c, d, isPed)
                    force(e, 0.0, 0.0, -S.dForce * 0.8)
                    if not isPed then
                        grab(e)
                        SetVehicleOutOfControl(e, false, true)
                    end
                end)
            end

            if S.dWake and v then
                local sp = GetEntitySpeed(v)
                if sp > 4.0 then
                    around(origin, S.dRadius * 0.5, S.dPeds, v, p, function(e, c, d)
                        local dx, dy = (c.x - origin.x) / d, (c.y - origin.y) / d
                        local f = S.dForce * 0.5 * math.min(sp / 15.0, 2.0)
                        force(e, dx * f, dy * f, S.dLift * 0.25)
                    end)
                end
            end

            if S.dPanic then
                around(origin, S.dRadius, false, v, p, function(e)
                    grab(e)
                    SetVehicleOutOfControl(e, false, true)
                end)
            end

            if S.dBoom and v then
                local now = GetGameTimer()
                around(origin, 3.2, false, v, p, function(e, c, d)
                    if d < 2.6 then
                        local last = S.boomCd[e]
                        if not last or (now - last) > 3000 then
                            S.boomCd[e] = now
                            grab(e)
                            if not pcall(NetworkExplodeVehicle, e, true, false, false) then
                                AddExplosion(c.x, c.y, c.z, 4, 1.0, true, false, 1.0)
                            end
                        end
                    end
                end)
            end
        else
            if next(S.levitated) then levitStop() end
            Wait(250)
        end
    end
end)

-- ======================= CONSTRUCTEURS D'ENTREES =======================

local function TOG(label, get, set, msgOn, msgOff)
    return {
        kind = "toggle", label = label, get = get,
        set = function(v)
            set(v)
            notify(v and (msgOn or (label .. " active")) or (msgOff or (label .. " desactive")))
        end,
    }
end

-- interrupteur adosse a un champ de S
local function FLAG(label, field, onSet)
    return TOG(label,
        function() return S[field] end,
        function(v)
            S[field] = v
            if onSet then onSet(v) end
        end)
end

local function NUM(label, get, change)
    return { kind = "num", label = label, get = get, change = change }
end

-- valeur numerique simple adossee a un champ de S
local function VAL(label, field, step, lo, hi, fmt)
    return NUM(label,
        function() return string.format(fmt or "%.0f", S[field]) end,
        function(d) S[field] = clamp(S[field] + d * step, lo, hi) end)
end

-- selecteur dans une liste, adosse a un index dans S
local function PICK(label, field, list, name, onChange)
    return NUM(label,
        function() return name(list[S[field]]) end,
        function(d)
            S[field] = cycle(S[field] + d, 1, #list)
            if onChange then onChange() end
        end)
end

local function ACT(label, run, confirm)
    return { kind = "action", label = label, run = run, confirm = confirm }
end
local function SUB(label, child) return { kind = "menu", label = label, child = child } end
local BACK = { kind = "back", label = "<< Retour" }

local function node(title, items, needVeh)
    return { title = title, items = items, needVeh = needVeh }
end

local function withBack(n)
    table.insert(n.items, 1, BACK)
    return n
end

-- ============================ MENUS ============================

-- ---- Vetements / Accessoires ----
local mClothes, mProps = {}, {}
for _, w in ipairs(CLOTHES) do
    local id = w[1]
    mClothes[#mClothes + 1] = {
        kind = "num", label = w[2],
        get = function()
            local d, t = wearGet(id, false)
            return d .. " / " .. t
        end,
        change = function(dir) wearDraw(id, false, dir) end,
        alt = function(dir) wearTex(id, false, dir) end,
    }
end
for _, w in ipairs(PROPS) do
    local id = w[1]
    mProps[#mProps + 1] = {
        kind = "num", label = w[2],
        get = function()
            local d, t = wearGet(id, true)
            return d .. " / " .. t
        end,
        change = function(dir) wearDraw(id, true, dir) end,
        alt = function(dir) wearTex(id, true, dir) end,
    }
end

local mOutfits = {}
for i = 1, OUTFIT_SLOTS do
    mOutfits[i] = { kind = "outfit", slot = i, label = "Tenue " .. i }
end

-- ============================ VEHICULE : LS CUSTOMS ============================
-- Catalogue complet des modTypes GTA V. Les noms de pieces sont lus dans le jeu
-- (GetModTextLabel + GetLabelText) : on affiche "Spoiler carbone" plutot que "3/12".

local WHEEL_TYPES = {
    "Sport", "Muscle", "Lowrider", "SUV", "Tout-terrain", "Tuner",
    "Moto", "Haut de gamme", "Benny's Original", "Benny's Bespoke",
    "Open Wheel", "Street",
}

local HEADLIGHT_COLORS = {
    "Blanc", "Bleu", "Bleu electrique", "Vert menthe", "Vert citron",
    "Jaune", "Or", "Orange", "Rouge", "Rose poudre", "Rose vif",
    "Violet", "Lumiere noire",
}

-- prepare toujours le kit avant de toucher aux mods
local function kit(v)
    if v then SetVehicleModKit(v, 0) end
    return v
end

local function modName(v, t, idx)
    if idx == -1 then return "Stock" end
    local ok, lbl = pcall(GetModTextLabel, v, t, idx)
    if ok and lbl then
        local s = GetLabelText(lbl)
        if s and s ~= "NULL" and s ~= "" then
            if #s > 18 then s = string.sub(s, 1, 17) .. "." end
            return s
        end
    end
    return "Niveau " .. (idx + 1)
end

-- entree de menu pour un mod classique
local function MOD(label, t)
    return {
        kind = "num", label = label,
        get = function()
            local v = kit(veh())
            if not v then return "--" end
            local max = GetNumVehicleMods(v, t)
            if max <= 0 then return "N/A" end
            return modName(v, t, GetVehicleMod(v, t))
        end,
        change = function(d) modSet(t, d) end,
    }
end

-- entree de menu pour un mod a bascule
local function MODTOG(label, t)
    return TOG(label, function() return togMod(t) end, function() togModSet(t) end)
end

-- couleur indexee 0-159
local function COLOR(label, get, set)
    return {
        kind = "num", label = label,
        get = function()
            local v = veh()
            if not v then return "--" end
            return tostring(get(v))
        end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            set(v, cycle(get(v) + d, 0, 159))
        end,
    }
end

-- ---- Performance ----
local nPerf = withBack(node("Performance", {
    MOD("Moteur", 11),
    MOD("Freins", 12),
    MOD("Transmission", 13),
    MOD("Suspension", 15),
    MOD("Blindage", 16),
    MOD("Klaxon", 14),
    MODTOG("Turbo", 18),
    MODTOG("Nitro", 17),
    MODTOG("Caisson de basses", 19),
    MODTOG("Hydraulique", 21),
    TOG("Pneus increvables", function()
        local v = veh()
        return v and not GetVehicleTyresCanBurst(v) or false
    end, function(on)
        local v = veh()
        if v then SetVehicleTyresCanBurst(v, not on) end
    end),
}, true))

-- ---- Carrosserie ----
local nBody = withBack(node("Carrosserie", {
    MOD("Spoiler", 0),
    MOD("Pare-choc avant", 1),
    MOD("Pare-choc arriere", 2),
    MOD("Bas de caisse", 3),
    MOD("Echappement", 4),
    MOD("Arceau / Chassis", 5),
    MOD("Calandre", 6),
    MOD("Capot", 7),
    MOD("Aile gauche", 8),
    MOD("Aile droite", 9),
    MOD("Toit", 10),
}, true))

-- ---- Chassis / details exterieurs ----
local nChassis = withBack(node("Chassis & details", {
    MOD("Bloc moteur", 39),
    MOD("Filtre a air", 40),
    MOD("Jambes de force", 41),
    MOD("Cache-arches", 42),
    MOD("Antennes", 43),
    MOD("Finition exterieure", 44),
    MOD("Reservoir", 45),
    MOD("Fenetres", 46),
    MOD("Coffre", 37),
    MOD("Hydraulique (piece)", 38),
}, true))

-- ---- Interieur ----
local nInterior = withBack(node("Interieur", {
    MOD("Design interieur", 27),
    MOD("Ornements", 28),
    MOD("Tableau de bord", 29),
    MOD("Compteurs", 30),
    MOD("Haut-parleurs portes", 31),
    MOD("Sieges", 32),
    MOD("Volant", 33),
    MOD("Levier de vitesse", 34),
    MOD("Plaques interieures", 35),
    MOD("Enceintes", 36),
    COLOR("Couleur interieur", function(v)
        local ok, c = pcall(GetVehicleInteriorColour, v)
        return (ok and c) or 0
    end, function(v, c) pcall(SetVehicleInteriorColour, v, c) end),
    COLOR("Couleur tableau de bord", function(v)
        local ok, c = pcall(GetVehicleDashboardColour, v)
        return (ok and c) or 0
    end, function(v, c) pcall(SetVehicleDashboardColour, v, c) end),
}, true))

-- ---- Roues & pneus ----
local nWheels = withBack(node("Roues & Pneus", {
    {
        kind = "num", label = "Type de jantes",
        get = function()
            local v = veh()
            if not v then return "--" end
            return WHEEL_TYPES[GetVehicleWheelType(v) + 1] or "?"
        end,
        change = function(d)
            local v = kit(veh())
            if not v then notify("montez dans un vehicule") return end
            SetVehicleWheelType(v, cycle(GetVehicleWheelType(v) + d, 0, 11))
        end,
    },
    MOD("Jantes avant", 23),
    MOD("Jantes arriere", 24),
    TOG("Jantes personnalisees", function()
        local v = veh()
        if not v then return false end
        local ok, r = pcall(GetVehicleModVariation, v, 23)
        return ok and r or false
    end, function(on)
        local v = kit(veh())
        if not v then notify("montez dans un vehicule") return end
        SetVehicleMod(v, 23, GetVehicleMod(v, 23), on)
    end),
    COLOR("Couleur des jantes", function(v)
        local _, w = GetVehicleExtraColours(v)
        return w
    end, function(v, c)
        local p = GetVehicleExtraColours(v)
        SetVehicleExtraColours(v, p, c)
    end),
    {
        kind = "num", label = "Couleur fumee de pneus",
        get = function() return NEONS[S.smokeIdx][4] end,
        change = function(d)
            local v = kit(veh())
            if not v then notify("montez dans un vehicule") return end
            S.smokeIdx = cycle(S.smokeIdx + d, 1, #NEONS)
            ToggleVehicleMod(v, 20, true)
            local c = NEONS[S.smokeIdx]
            SetVehicleTyreSmokeColor(v, c[1], c[2], c[3])
        end,
    },
    MODTOG("Fumee de pneus", 20),
}, true))

-- ---- Peinture ----
local nPaint = withBack(node("Peinture", {
    COLOR("Couleur primaire", function(v)
        local c1 = GetVehicleColours(v)
        return c1
    end, function(v, c)
        local _, c2 = GetVehicleColours(v)
        SetVehicleColours(v, c, c2)
    end),
    COLOR("Couleur secondaire", function(v)
        local _, c2 = GetVehicleColours(v)
        return c2
    end, function(v, c)
        local c1 = GetVehicleColours(v)
        SetVehicleColours(v, c1, c)
    end),
    COLOR("Couleur perlee", function(v)
        local p = GetVehicleExtraColours(v)
        return p
    end, function(v, c)
        local _, w = GetVehicleExtraColours(v)
        SetVehicleExtraColours(v, c, w)
    end),
    VAL("Rouge (perso.)", "rgbR", 5, 0, 255),
    VAL("Vert (perso.)", "rgbG", 5, 0, 255),
    VAL("Bleu (perso.)", "rgbB", 5, 0, 255),
    ACT("Appliquer RGB en primaire", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleCustomPrimaryColour(v, S.rgbR, S.rgbG, S.rgbB)
        notify("couleur primaire personnalisee")
    end),
    ACT("Appliquer RGB en secondaire", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleCustomSecondaryColour(v, S.rgbR, S.rgbG, S.rgbB)
        notify("couleur secondaire personnalisee")
    end),
    {
        kind = "num", label = "Vitres teintees",
        get = function()
            local v = veh()
            if not v then return "--" end
            local names = { "Aucune", "Noire", "Fumee", "Legere", "Limousine", "Verte", "Standard" }
            return names[GetVehicleWindowTint(v) + 1] or "?"
        end,
        change = function(d)
            local v = veh()
            if v then SetVehicleWindowTint(v, cycle(GetVehicleWindowTint(v) + d, 0, 6)) end
        end,
    },
    {
        kind = "num", label = "Transparence",
        get = function() return math.floor(GHOST_STEPS[S.ghostIdx] / 255 * 100 + 0.5) .. " %" end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            S.ghostIdx = cycle(S.ghostIdx + d, 1, #GHOST_STEPS)
            local a = GHOST_STEPS[S.ghostIdx]
            if a >= 255 then ResetEntityAlpha(v) else SetEntityAlpha(v, a, false) end
        end,
    },
}, true))

-- ---- Eclairage & neons ----
local nLights = withBack(node("Eclairage & Neons", {
    MODTOG("Phares xenon", 22),
    {
        kind = "num", label = "Couleur des phares",
        get = function()
            local v = veh()
            if not v then return "--" end
            local ok, c = pcall(GetVehicleHeadlightsColour, v)
            if not ok or not c or c < 0 or c > 12 then return "Defaut" end
            return HEADLIGHT_COLORS[c + 1] or "?"
        end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            local ok, c = pcall(GetVehicleHeadlightsColour, v)
            c = (ok and c and c >= 0 and c <= 12) and c or 0
            SetVehicleHeadlightsColour(v, cycle(c + d, 0, 12))
        end,
    },
    {
        kind = "num", label = "Couleur des neons",
        get = function() return NEONS[S.neonIdx][4] end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            S.neonIdx = cycle(S.neonIdx + d, 1, #NEONS)
            local c = NEONS[S.neonIdx]
            SetVehicleNeonLightsColour(v, c[1], c[2], c[3])
        end,
    },
    TOG("Neon avant", function()
        local v = veh()
        return v and IsVehicleNeonLightEnabled(v, 2) or false
    end, function(on)
        local v = veh()
        if v then SetVehicleNeonLightEnabled(v, 2, on) end
    end),
    TOG("Neon arriere", function()
        local v = veh()
        return v and IsVehicleNeonLightEnabled(v, 3) or false
    end, function(on)
        local v = veh()
        if v then SetVehicleNeonLightEnabled(v, 3, on) end
    end),
    TOG("Neon gauche", function()
        local v = veh()
        return v and IsVehicleNeonLightEnabled(v, 0) or false
    end, function(on)
        local v = veh()
        if v then SetVehicleNeonLightEnabled(v, 0, on) end
    end),
    TOG("Neon droit", function()
        local v = veh()
        return v and IsVehicleNeonLightEnabled(v, 1) or false
    end, function(on)
        local v = veh()
        if v then SetVehicleNeonLightEnabled(v, 1, on) end
    end),
    ACT("Allumer tous les neons", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        local c = NEONS[S.neonIdx]
        SetVehicleNeonLightsColour(v, c[1], c[2], c[3])
        for i = 0, 3 do SetVehicleNeonLightEnabled(v, i, true) end
        notify("neons allumes")
    end),
    ACT("Eteindre tous les neons", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        for i = 0, 3 do SetVehicleNeonLightEnabled(v, i, false) end
        notify("neons eteints")
    end),
}, true))

-- ---- Plaque ----
local nPlate = withBack(node("Plaque", {
    {
        kind = "num", label = "Style de plaque",
        get = function()
            local v = veh()
            if not v then return "--" end
            return PLATES[GetVehicleNumberPlateTextIndex(v) + 1] or "?"
        end,
        change = function(d)
            local v = veh()
            if v then SetVehicleNumberPlateTextIndex(v, cycle(GetVehicleNumberPlateTextIndex(v) + d, 0, 5)) end
        end,
    },
    MOD("Support de plaque", 25),
    MOD("Plaque personnalisee", 26),
}, true))

-- ---- Livrees & extras ----
local nLivery = withBack(node("Livrees & Extras", {
    {
        kind = "num", label = "Livree",
        get = function()
            local v = kit(veh())
            if not v then return "--" end
            local n = GetVehicleLiveryCount(v)
            if n <= 0 then return "N/A" end
            return (GetVehicleLivery(v) + 1) .. " / " .. n
        end,
        change = function(d)
            local v = kit(veh())
            if not v then notify("montez dans un vehicule") return end
            local n = GetVehicleLiveryCount(v)
            if n <= 0 then return end
            SetVehicleLivery(v, cycle(GetVehicleLivery(v) + d, 0, n - 1))
        end,
    },
    {
        kind = "num", label = "Livree de toit",
        get = function()
            local v = veh()
            if not v then return "--" end
            local ok, n = pcall(GetVehicleRoofLiveryCount, v)
            if not ok or not n or n <= 0 then return "N/A" end
            local _, c = pcall(GetVehicleRoofLivery, v)
            return ((c or 0) + 1) .. " / " .. n
        end,
        change = function(d)
            local v = veh()
            if not v then return end
            local ok, n = pcall(GetVehicleRoofLiveryCount, v)
            if not ok or not n or n <= 0 then return end
            local _, c = pcall(GetVehicleRoofLivery, v)
            pcall(SetVehicleRoofLivery, v, cycle((c or 0) + d, 0, n - 1))
        end,
    },
    MOD("Livree (mod)", 48),
    ACT("Activer tous les extras", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        for i = 1, 14 do
            if DoesExtraExist(v, i) then SetVehicleExtra(v, i, 0) end
        end
        notify("extras actives")
    end),
    ACT("Desactiver tous les extras", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        for i = 1, 14 do
            if DoesExtraExist(v, i) then SetVehicleExtra(v, i, 1) end
        end
        notify("extras desactives")
    end),
}, true))

-- extras individuels : une ligne par extra (1 a 14)
do
    local items = {}
    for i = 1, 14 do
        items[#items + 1] = TOG("Extra " .. i, function()
            local v = veh()
            if not v or not DoesExtraExist(v, i) then return false end
            return IsVehicleExtraTurnedOn(v, i)
        end, function(on)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            if not DoesExtraExist(v, i) then notify("extra " .. i .. " inexistant") return end
            SetVehicleExtra(v, i, on and 0 or 1)
        end)
    end
    local nExtras = withBack(node("Extras individuels", items, true))
    nLivery.items[#nLivery.items + 1] = SUB("Extras individuels", nExtras)
end

-- ---- Texte de plaque (editeur caractere par caractere) ----
local PLATE_CHARS = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

local function plateSync()
    local v = veh()
    if not v then return end
    local cur = GetVehicleNumberPlateText(v) or ""
    for i = 1, 8 do
        local ch = string.sub(cur, i, i)
        if ch == "" then ch = " " end
        S.plate[i] = ch
    end
end

local function plateString()
    local out = ""
    for i = 1, 8 do out = out .. (S.plate[i] or " ") end
    return out
end

do
    local items = {}
    for i = 1, 8 do
        items[#items + 1] = {
            kind = "num", label = "Caractere " .. i,
            get = function()
                local c = S.plate[i] or " "
                return (c == " ") and "[vide]" or c
            end,
            change = function(d)
                local c = S.plate[i] or " "
                local pos = string.find(PLATE_CHARS, c, 1, true) or 1
                pos = cycle(pos + d, 1, #PLATE_CHARS)
                S.plate[i] = string.sub(PLATE_CHARS, pos, pos)
            end,
        }
    end
    items[#items + 1] = ACT("Appliquer la plaque", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleNumberPlateText(v, plateString())
        notify("plaque : " .. plateString())
    end)
    items[#items + 1] = ACT("Lire la plaque actuelle", function()
        if not veh() then notify("montez dans un vehicule") return end
        plateSync()
        notify("plaque lue : " .. plateString())
    end)
    S.nPlateText = withBack(node("Texte de plaque", items, true))
end

-- ---- Portes ----
local DOOR_NAMES = {
    [0] = "Porte avant gauche", [1] = "Porte avant droite",
    [2] = "Porte arriere gauche", [3] = "Porte arriere droite",
    [4] = "Capot", [5] = "Coffre",
}

do
    local items = {}
    for i = 0, 5 do
        local idx = i
        items[#items + 1] = TOG(DOOR_NAMES[idx], function()
            local v = veh()
            if not v then return false end
            return GetVehicleDoorAngleRatio(v, idx) > 0.1
        end, function(on)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            if on then SetVehicleDoorOpen(v, idx, false, false)
            else SetVehicleDoorShut(v, idx, false) end
        end)
    end
    items[#items + 1] = ACT("Arracher toutes les portes", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        for i = 0, 5 do SetVehicleDoorBroken(v, i, false) end
        notify("portes arrachees")
    end, true)
    items[#items + 1] = TOG("Verrouiller le vehicule", function() return S.locked end, function(on)
        S.locked = on
        local v = veh()
        if v then SetVehicleDoorsLocked(v, on and 2 or 1) end
    end)
    S.nDoors = withBack(node("Portes", items, true))
end

-- ---- Vitres ----
do
    local names = { [0] = "Vitre avant gauche", [1] = "Vitre avant droite",
                    [2] = "Vitre arriere gauche", [3] = "Vitre arriere droite" }
    local items = {}
    for i = 0, 3 do
        local idx = i
        items[#items + 1] = TOG(names[idx], function()
            return S.win[idx] or false
        end, function(on)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            S.win[idx] = on
            if on then RollDownWindow(v, idx) else RollUpWindow(v, idx) end
        end)
    end
    items[#items + 1] = ACT("Briser toutes les vitres", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        for i = 0, 7 do SmashVehicleWindow(v, i) end
        notify("vitres brisees")
    end, true)
    items[#items + 1] = ACT("Reparer les vitres", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleFixed(v)
        notify("vitres reparees")
    end)
    S.nWindows = withBack(node("Vitres", items, true))
end

-- ---- Pneus ----
do
    local names = { [0] = "Avant gauche", [1] = "Avant droit",
                    [2] = "Milieu gauche", [3] = "Milieu droit",
                    [4] = "Arriere gauche", [5] = "Arriere droit" }
    local items = {}
    for i = 0, 5 do
        local idx = i
        items[#items + 1] = TOG(names[idx] .. " creve", function()
            local v = veh()
            if not v then return false end
            return IsVehicleTyreBurst(v, idx, false)
        end, function(on)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            if on then SetVehicleTyreBurst(v, idx, true, 1000.0)
            else SetVehicleTyreFixed(v, idx) end
        end)
    end
    items[#items + 1] = ACT("Reparer tous les pneus", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        for i = 0, 5 do SetVehicleTyreFixed(v, i) end
        notify("pneus repares")
    end)
    S.nTyres = withBack(node("Pneus", items, true))
end

-- ---- Roues avancees (Benny's) ----
local nWheelAdv = withBack(node("Roues avancees", {
    {
        kind = "num", label = "Taille des jantes",
        get = function()
            local v = veh()
            if not v then return "--" end
            local ok, s = pcall(GetVehicleWheelSize, v)
            return (ok and s) and string.format("%.2f", s) or "N/A"
        end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            local ok, s = pcall(GetVehicleWheelSize, v)
            if not ok or not s then return end
            pcall(SetVehicleWheelSize, v, clamp(s + d * 0.05, 0.1, 3.0))
        end,
    },
    {
        kind = "num", label = "Largeur des jantes",
        get = function()
            local v = veh()
            if not v then return "--" end
            local ok, w = pcall(GetVehicleWheelWidth, v)
            return (ok and w) and string.format("%.2f", w) or "N/A"
        end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            local ok, w = pcall(GetVehicleWheelWidth, v)
            if not ok or not w then return end
            pcall(SetVehicleWheelWidth, v, clamp(w + d * 0.05, 0.1, 3.0))
        end,
    },
    ACT("Reinitialiser taille / largeur", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        pcall(SetVehicleWheelSize, v, 1.0)
        pcall(SetVehicleWheelWidth, v, 1.0)
        notify("jantes reinitialisees")
    end),
    TOG("Pneus drift", function() return S.driftTyres end, function(on)
        S.driftTyres = on
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        if not pcall(SetDriftTyresEnabled, v, on) then
            notify("pneus drift non supportes ici")
        end
    end),
}, true))

-- ---- Moteur & etat ----
local nEngine = withBack(node("Moteur & Etat", {
    {
        kind = "num", label = "Puissance moteur",
        get = function() return string.format("x%.1f", S.powerMult) end,
        change = function(d)
            S.powerMult = clamp(S.powerMult + d * 0.5, 1.0, 20.0)
            local v = veh()
            if v then SetVehicleEnginePowerMultiplier(v, (S.powerMult - 1.0) * 100.0) end
        end,
    },
    {
        kind = "num", label = "Couple moteur",
        get = function() return string.format("x%.1f", S.torqueMult) end,
        change = function(d)
            S.torqueMult = clamp(S.torqueMult + d * 0.5, 1.0, 20.0)
            local v = veh()
            if v then SetVehicleEngineTorqueMultiplier(v, S.torqueMult) end
        end,
    },
    {
        kind = "num", label = "Niveau de salete",
        get = function()
            local v = veh()
            if not v then return "--" end
            return string.format("%.1f", GetVehicleDirtLevel(v))
        end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            SetVehicleDirtLevel(v, clamp(GetVehicleDirtLevel(v) + d * 1.0, 0.0, 15.0))
        end,
    },
    {
        kind = "num", label = "Sante moteur",
        get = function()
            local v = veh()
            if not v then return "--" end
            return string.format("%.0f", GetVehicleEngineHealth(v))
        end,
        change = function(d)
            local v = veh()
            if not v then notify("montez dans un vehicule") return end
            SetVehicleEngineHealth(v, clamp(GetVehicleEngineHealth(v) + d * 100.0, 0.0, 1000.0))
        end,
    },
    TOG("Moteur allume", function()
        local v = veh()
        return v and GetIsVehicleEngineRunning(v) or false
    end, function(on)
        local v = veh()
        if v then SetVehicleEngineOn(v, on, true, true) end
    end),
    ACT("Vider le reservoir", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleFuelLevel(v, 0.0)
        notify("reservoir vide")
    end),
    ACT("Faire le plein", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleFuelLevel(v, 100.0)
        notify("plein effectue")
    end),
}, true))

-- rattachements tardifs : ces noeuds parents sont construits plus haut,
-- leurs enfants n'existent qu'ici.
nPlate.items[#nPlate.items + 1] = SUB("Texte de plaque", S.nPlateText)

nLights.items[#nLights.items + 1] = VAL("Rouge (neon/xenon)", "lightR", 5, 0, 255)
nLights.items[#nLights.items + 1] = VAL("Vert (neon/xenon)", "lightG", 5, 0, 255)
nLights.items[#nLights.items + 1] = VAL("Bleu (neon/xenon)", "lightB", 5, 0, 255)

nLights.items[#nLights.items + 1] = ACT("Appliquer RGB aux neons", function()
    local v = veh()
    if not v then notify("montez dans un vehicule") return end
    SetVehicleNeonLightsColour(v, S.lightR, S.lightG, S.lightB)
    for i = 0, 3 do SetVehicleNeonLightEnabled(v, i, true) end
    notify("neons en couleur personnalisee")
end)

nLights.items[#nLights.items + 1] = ACT("Appliquer RGB aux xenons", function()
    local v = veh()
    if not v then notify("montez dans un vehicule") return end
    SetVehicleModKit(v, 0)
    ToggleVehicleMod(v, 22, true)
    if not pcall(SetVehicleXenonLightsCustomColor, v, S.lightR, S.lightG, S.lightB) then
        notify("xenon RGB non supporte ici")
        return
    end
    notify("xenons en couleur personnalisee")
end)

nLights.items[#nLights.items + 1] = {
    kind = "num", label = "Luminosite des phares",
    get = function() return string.format("x%.1f", S.lightMult) end,
    change = function(d)
        S.lightMult = clamp(S.lightMult + d * 0.1, 0.0, 5.0)
        local v = veh()
        if v then pcall(SetVehicleLightMultiplier, v, S.lightMult) end
    end,
}

nLights.items[#nLights.items + 1] = TOG("Sirene (vehicules d'urgence)",
    function()
        local v = veh()
        return v and IsVehicleSirenOn(v) or false
    end,
    function(on)
        local v = veh()
        if v then SetVehicleSiren(v, on) end
    end)

nLights.items[#nLights.items + 1] = TOG("Sirene silencieuse",
    function() return S.muteSiren end,
    function(on)
        S.muteSiren = on
        local v = veh()
        if v then SetVehicleHasMutedSirens(v, on) end
    end)

nLights.items[#nLights.items + 1] = TOG("Pleins phares",
    function() return S.highBeam end,
    function(on)
        S.highBeam = on
        local v = veh()
        if v then SetVehicleLights(v, on and 2 or 0) end
    end)

nLights.items[#nLights.items + 1] = TOG("Lumiere interieure",
    function() return S.interiorLight end,
    function(on)
        S.interiorLight = on
        local v = veh()
        if v then SetVehicleInteriorlight(v, on) end
    end)

-- ---- Configurations sauvegardees ----
local mVehSlots = {}
for i = 1, VEH_SLOTS do
    mVehSlots[i] = { kind = "vehslot", slot = i, label = "Config " .. i }
end
local nVehSlots = withBack(node("Configurations", mVehSlots))

-- ---- Racine Vehicule ----
local nVehicle = node("Vehicule", {
    ACT("Upgrade Max (performance)", function()
        local v = kit(veh())
        if not v then notify("montez dans un vehicule") return end
        for _, m in ipairs({ 11, 12, 13, 15, 16 }) do
            local mx = GetNumVehicleMods(v, m)
            if mx > 0 then SetVehicleMod(v, m, mx - 1, false) end
        end
        ToggleVehicleMod(v, 18, true)
        ToggleVehicleMod(v, 22, true)
        notify("performance au maximum")
    end),
    ACT("Tout au maximum (esthetique incluse)", function()
        local v = kit(veh())
        if not v then notify("montez dans un vehicule") return end
        for t = 0, 48 do
            if t ~= 14 and t ~= 23 and t ~= 24 then
                local mx = GetNumVehicleMods(v, t)
                if mx > 0 then SetVehicleMod(v, t, mx - 1, false) end
            end
        end
        for _, t in ipairs({ 18, 19, 20, 21, 22 }) do ToggleVehicleMod(v, t, true) end
        notify("toutes les pieces au maximum")
    end),
    ACT("Tout remettre d'origine", function()
        local v = kit(veh())
        if not v then notify("montez dans un vehicule") return end
        for t = 0, 48 do
            if GetNumVehicleMods(v, t) > 0 then SetVehicleMod(v, t, -1, false) end
        end
        for _, t in ipairs({ 17, 18, 19, 20, 21, 22 }) do ToggleVehicleMod(v, t, false) end
        for i = 0, 3 do SetVehicleNeonLightEnabled(v, i, false) end
        SetVehicleWindowTint(v, 0)
        notify("vehicule remis d'origine")
    end, true),
    ACT("Reparer", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleFixed(v)
        SetVehicleDeformationFixed(v)
        SetVehicleEngineHealth(v, 1000.0)
        SetVehicleBodyHealth(v, 1000.0)
        SetVehiclePetrolTankHealth(v, 1000.0)
        notify("vehicule repare")
    end),
    ACT("Nettoyer", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        SetVehicleDirtLevel(v, 0.0)
        WashDecalsFromVehicle(v, 1.0)
        notify("vehicule nettoye")
    end),
    SUB("Performance", nPerf),
    SUB("Carrosserie", nBody),
    SUB("Chassis & details", nChassis),
    SUB("Interieur", nInterior),
    SUB("Roues & Pneus", nWheels),
    SUB("Peinture", nPaint),
    SUB("Eclairage & Neons", nLights),
    SUB("Plaque", nPlate),
    SUB("Roues avancees", nWheelAdv),
    SUB("Moteur & Etat", nEngine),
    SUB("Portes", S.nDoors),
    SUB("Vitres", S.nWindows),
    SUB("Pneus", S.nTyres),
    SUB("Livrees & Extras", nLivery),
    SUB("Configurations", nVehSlots),
    ACT("Ouvrir / fermer les portes", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        if GetVehicleDoorAngleRatio(v, 0) > 0.1 then
            SetVehicleDoorsShut(v, false)
            notify("portes fermees")
        else
            for i = 0, 5 do SetVehicleDoorOpen(v, i, false, false) end
            notify("portes ouvertes")
        end
    end),
    ACT("Baisser / remonter les vitres", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        S.windows = not S.windows
        for i = 0, 3 do
            if S.windows then RollDownWindow(v, i) else RollUpWindow(v, i) end
        end
        notify(S.windows and "vitres baissees" or "vitres remontees")
    end),
    ACT("Capote (cabriolet)", function()
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        local st = GetConvertibleRoofState(v)
        if st == 0 or st == 1 then RaiseConvertibleRoof(v, false) else LowerConvertibleRoof(v, false) end
        notify("capote actionnee")
    end),
    TOG("Feux de detresse", function() return S.hazard end, function(on)
        S.hazard = on
        local v = veh()
        if v then
            SetVehicleIndicatorLights(v, 0, on)
            SetVehicleIndicatorLights(v, 1, on)
        end
    end),
    TOG("No Collision (entites)", function() return S.noColl end, function(on)
        S.noColl = on
        if on then
            S.noCollVeh = veh()
        elseif S.noCollVeh and DoesEntityExist(S.noCollVeh) then
            SetEntityCollision(S.noCollVeh, true, true)
            S.noCollVeh = nil
        end
    end),
}, false)

-- ---- Joueur ----
local mPlayer = {
    FLAG("Godmode", "godmode", function(v)
        if not v then
            SetEntityInvincible(ped(), false)
            SetPlayerInvincible(PlayerId(), false)
        end
    end),
    FLAG("Anti-ragdoll", "noRagdoll", function(v)
        if not v then SetPedCanRagdoll(ped(), true) end
    end),
    FLAG("Ignifuge", "fireProof", function(v)
        if not v then SetEntityProofs(ped(), false, false, false, false, false, false, false, false) end
    end),
    FLAG("Poumons infinis", "infLungs", function(v)
        if not v then SetPedMaxTimeUnderwater(ped(), 30.0) end
    end),
    FLAG("Super saut", "superJump"),
    FLAG("Invisibilite", "invisible", function(v)
        if not v then SetEntityVisible(ped(), true, false) end
    end),
    FLAG("Regeneration auto", "autoHeal"),
    VAL("Vitesse de course", "runSpeed", 0.05, 1.0, 1.49, "%.2f"),
    VAL("Vitesse de nage", "swimSpeed", 0.05, 1.0, 1.49, "%.2f"),
    PICK("Modele de personnage", "pedModelIdx", PED_MODELS, function(m) return m end),
    ACT("Appliquer le modele", applyPedModel),
    ACT("Soigner", doHeal),
    ACT("Revive", doRevive),
}

-- ---- Monde ----
local mWorld = {
    NUM("Heure", function() return string.format("%02d h", math.floor(S.hour)) end, function(d)
        S.hour = cycle(S.hour + d, 0, 23)
        NetworkOverrideClockTime(math.floor(S.hour), 0, 0)
    end),
    FLAG("Figer l'heure", "freezeTime", function(v)
        if not v then pcall(NetworkClearClockTimeOverride) end
    end),
    PICK("Meteo", "weatherIdx", WEATHERS, function(w) return w end, applyWeather),
    FLAG("Figer la meteo", "freezeWeather", function(v)
        if not v then pcall(ClearOverrideWeather) end
    end),
    PICK("Gravite", "gravityIdx", GRAVITY, function(g) return g[1] end, applyGravity),
    FLAG("Blackout", "blackout", function(v)
        if not v then SetArtificialLightsState(false) end
    end),
    NUM("Densite du trafic", function()
        return (S.trafficIdx == 5) and "Normale" or (math.floor((S.trafficIdx - 1) / 4 * 100) .. " %")
    end, function(d) S.trafficIdx = clamp(S.trafficIdx + d, 1, 5) end),
    NUM("Densite des pietons", function()
        return (S.pedDensIdx == 5) and "Normale" or (math.floor((S.pedDensIdx - 1) / 4 * 100) .. " %")
    end, function(d) S.pedDensIdx = clamp(S.pedDensIdx + d, 1, 5) end),
}

-- ---- Troll : sous-menus ----
local nTank = withBack(node("Mode Tank", {
    FLAG("Activer le Mode Tank", "tankOn", function(v)
        if not v then
            local x = veh()
            if x then
                SetEntityInvincible(x, false)
                SetVehicleTyresCanBurst(x, true)
            end
        end
    end),
    VAL("Force de projection", "tankForce", 5.0, 5.0, 300.0),
    VAL("Rayon d'action", "tankRadius", 0.5, 2.0, 40.0, "%.1f m"),
    VAL("Poussee verticale", "tankLift", 1.0, 0.0, 50.0),
    NUM("Influence de la vitesse", function()
        return math.floor(S.tankScale * 100 + 0.5) .. " %"
    end, function(d) S.tankScale = clamp(S.tankScale + d * 0.1, 0.0, 2.0) end),
    FLAG("Vehicule invincible", "tankGod"),
    FLAG("Projeter les pietons", "tankPeds"),
}))

local nDest = withBack(node("Destruction", {
    FLAG("Onde de choc (X)", "dShock"),
    FLAG("Aimant / attirer (V)", "dMagnet"),
    FLAG("Levitation (C)", "dLevit", function(v) if not v then levitStop() end end),
    FLAG("Ecrasement au sol (N)", "dCrush"),
    FLAG("Sillage en roulant", "dWake"),
    FLAG("Panique des conducteurs", "dPanic"),
    FLAG("Explosion au contact", "dBoom"),
    VAL("Rayon d'action", "dRadius", 2.0, 3.0, 100.0, "%.0f m"),
    VAL("Force", "dForce", 10.0, 5.0, 400.0),
    VAL("Poussee verticale", "dLift", 2.0, 0.0, 80.0),
    FLAG("Inclure les pietons", "dPeds"),
}))

local nHandling = withBack(node("Comportement", {
    HAND("Cambrage des roues", "fCamberStiffnesss", 2.0, 0.0, 30.0),
    HAND("Rigidite anti-roulis", "fAntiRollBarForce", 0.5, 0.0, 20.0),
    HAND("Masse", "fMass", 100.0, 200.0, 6000.0, "%.0f kg"),
    HAND("Vitesse maximale", "fInitialDriveMaxFlatVel", 5.0, 10.0, 300.0, "%.0f"),
    NUM("Transmission", function()
        local x = handGet("fDriveBiasFront")
        if not x then return "--" end
        if x < 0.2 then return "Propulsion" end
        if x > 0.8 then return "Traction" end
        return "4 roues motrices"
    end, function(d)
        local x = handGet("fDriveBiasFront")
        if not x then notify("montez dans un vehicule") return end
        local steps = { 0.0, 0.5, 1.0 }
        local idx = 1
        for i, s in ipairs(steps) do if math.abs(x - s) < 0.05 then idx = i break end end
        handSet("fDriveBiasFront", steps[cycle(idx + d, 1, 3)])
    end),
    TOG("Mode Drift", function() return S.drift end, function(on)
        local v = veh()
        if not v then notify("montez dans un vehicule") return end
        if on then
            S.driftBak = {
                handGet("fTractionLossMult"), handGet("fTractionCurveMax"), handGet("fTractionCurveMin"),
            }
            handSet("fTractionLossMult", 8.0)
            handSet("fTractionCurveMax", 1.2)
            handSet("fTractionCurveMin", 0.8)
        elseif S.driftBak then
            handSet("fTractionLossMult", S.driftBak[1])
            handSet("fTractionCurveMax", S.driftBak[2])
            handSet("fTractionCurveMin", S.driftBak[3])
            S.driftBak = nil
        end
        S.drift = on
    end),
}, true))

local mTroll = {
    SUB("Mode Tank", nTank),
    SUB("Destruction", nDest),
    SUB("Comportement (handling)", nHandling),
    FLAG("Waterproof (rouler sur l'eau)", "waterproof", function(v)
        if not v then SetPedMaxTimeUnderwater(ped(), 30.0) end
    end),
    FLAG("Echappement Sport (Pop & Bang)", "popBang"),
    FLAG("Vehicule Indestructible", "godVeh", function(v)
        if not v then
            local x = veh()
            if x then
                SetEntityInvincible(x, false)
                SetVehicleCanBeVisiblyDamaged(x, true)
                SetVehicleTyresCanBurst(x, true)
            end
        end
    end),
    FLAG("Saut de Vehicule (J)", "vehJump"),
    FLAG("Rocket Boost (B)", "rocket"),
    FLAG("Gravite Lunaire", "moonGrav"),
    FLAG("Anti-retournement", "autoRight"),
}

-- ---- LUA (scripts importes) ----
local mLua = {
    FLAG("Controle Vehicule (Y / R)", "tkOn", function(v) if not v then tkReset() end end),
    FLAG("Attacher Vehicule (K / H)", "atOn", function(v) if not v then atReset() end end),
    FLAG("Teleporter dernier vehicule (H)", "tpOn", function(v) if not v then S.tpVeh = nil end end),
}

-- ---- Options ----
local function applyAccent()
    local p = CFG.accentPresets[S.accentIdx]
    CFG.accent.r, CFG.accent.g, CFG.accent.b = p[2][1], p[2][2], p[2][3]
    CFG.accentDk.r, CFG.accentDk.g, CFG.accentDk.b = p[3][1], p[3][2], p[3][3]
end

local function applyBg()
    local p = CFG.bgPresets[S.bgIdx]
    local function set(t, v) t.r, t.g, t.b = v[1], v[2], v[3] end
    set(CFG.bg, p[2]) set(CFG.panel, p[3]) set(CFG.card, p[4]) set(CFG.cardAlt, p[5])
end

local function applyPos()
    local p = CFG.posPresets[S.posIdx]
    CFG.sidebarX, CFG.contentX = p[2], p[3]
end

local saveSettings -- defini plus bas (persistance)

local mOptions = {
    PICK("Position du menu", "posIdx", CFG.posPresets, function(p) return p[1] end,
        function() applyPos() saveSettings() end),
    PICK("Couleur d'accent", "accentIdx", CFG.accentPresets, function(p) return p[1] end,
        function() applyAccent() saveSettings() end),
    PICK("Couleur du fond", "bgIdx", CFG.bgPresets, function(p) return p[1] end,
        function() applyBg() saveSettings() end),
    NUM("Opacite du fond", function() return math.floor(S.alpha * 100 + 0.5) .. " %" end,
        function(d)
            S.alpha = clamp(S.alpha + d * 0.05, 0.15, 1.0)
            saveSettings()
        end),
    ACT("Decharger le script", function()
        S.unloaded = true
        S.open = false
        notify("script decharge")
    end, true),
}

-- ============================== BINDS ==============================

local BIND_KEYS = {}
do
    local function add(vk, n) BIND_KEYS[#BIND_KEYS + 1] = { vk = vk, name = n } end
    for i = 0, 11 do add(0x70 + i, "F" .. (i + 1)) end
    for i = 0, 9 do add(0x30 + i, tostring(i)) end
    for i = 0, 25 do add(0x41 + i, string.char(65 + i)) end
    for i = 0, 9 do add(0x60 + i, "NUM" .. i) end
    add(0x6A, "NUM*") add(0x6B, "NUM+") add(0x6D, "NUM-")
    add(0x6E, "NUM.") add(0x6F, "NUM/") add(0x2D, "INSER") add(0x24, "ORIGINE")
end

local VK_NAME = {}
for _, k in ipairs(BIND_KEYS) do VK_NAME[k.vk] = k.name end

-- Toute entree activable devient bindable, automatiquement.
local mBinds = {}
do
    local function collect(list, prefix)
        for _, it in ipairs(list) do
            local run
            if it.kind == "toggle" then
                run = function() it.set(not it.get()) end
            elseif it.kind == "action" then
                run = it.run
            end
            if run then
                mBinds[#mBinds + 1] = {
                    kind = "bind", id = prefix .. "|" .. it.label,
                    label = prefix .. " · " .. it.label, run = run,
                }
            end
        end
    end
    collect(mPlayer, "JOUEUR")
    collect(mWorld, "MONDE")
    collect(mTroll, "TROLL")
    collect(nTank.items, "TANK")
    collect(nDest.items, "DEST")
    collect(nHandling.items, "HANDL")
    collect(mLua, "LUA")
    collect(nVehicle.items, "VEH")
end

local function bindName(id)
    local vk = S.binds[id]
    if not vk then return "--" end
    return VK_NAME[vk] or ("0x" .. string.format("%X", vk))
end

-- =========================== PERSISTANCE ===========================

saveSettings = function()
    local data = {
        accent = S.accentIdx, bg = S.bgIdx, pos = S.posIdx,
        alpha = S.alpha, binds = S.binds,
    }
    pcall(SetResourceKvp, "Storm_settings", json.encode(data))
end

local function loadAll()
    -- reglages + binds
    local ok, rawStr = pcall(GetResourceKvpString, "Storm_settings")
    if ok and rawStr then
        local okd, d = pcall(json.decode, rawStr)
        if okd and d then
            S.accentIdx = d.accent or S.accentIdx
            S.bgIdx = d.bg or S.bgIdx
            S.posIdx = d.pos or S.posIdx
            S.alpha = d.alpha or S.alpha
            S.binds = d.binds or {}
            applyAccent() applyBg() applyPos()
        end
    end
    -- tenues
    for i = 1, OUTFIT_SLOTS do
        local o, r2 = pcall(GetResourceKvpString, "Storm_outfit_" .. i)
        if o and r2 then
            local od, dd = pcall(json.decode, r2)
            if od and dd then S.outfits[i] = dd end
        end
    end
    -- configs vehicule
    for i = 1, VEH_SLOTS do
        local o, r2 = pcall(GetResourceKvpString, "Storm_veh_" .. i)
        if o and r2 then
            local od, dd = pcall(json.decode, r2)
            if od and dd then S.vehSlots[i] = dd end
        end
    end
end

-- ========================= BARRE LATERALE =========================

local CATS = {
    { "Vetements",   function() return mClothes, "Vetements" end },
    { "Accessoires", function() return mProps, "Accessoires" end },
    { "Tenues",      function() return mOutfits, "Tenues" end },
    { "Vehicule",    function() return nVehicle.items, "Vehicule" end },
    { "Joueur",      function() return mPlayer, "Joueur" end },
    { "Monde",       function() return mWorld, "Monde" end },
    { "Troll",       function() return mTroll, "Troll" end },
    { "LUA",         function() return mLua, "LUA" end },
    { "Binds",       function() return mBinds, "Binds" end },
    { "Options",     function() return mOptions, "Options" end },
}

local function activeItems()
    if S.subNode then
        return S.subNode.items, S.subNode.title, S.subNode.needVeh
    end
    local items, title = CATS[S.sideIdx][2]()
    return items, title, false
end

-- ============================= RENDU =============================

local function bounds()
    local left = CFG.sidebarX - CFG.sidebarW / 2
    local right = CFG.contentX + CFG.contentW / 2
    local w = right - left
    return left + w / 2, w
end

local function drawBanner()
    local cx, w = bounds()
    local h = CFG.bannerH - 0.008
    local cy = CFG.topY + h / 2
    shadow(cx, cy, w, h)
    grad(cx, cy, w, h, { r = 32, g = 34, b = 47 }, CFG.bg, 12)
    rect(cx, CFG.topY + 0.0013, w, 0.0026, CFG.accent, uiA(255))
    grad(cx, CFG.topY + h - 0.0016, w, 0.0032, CFG.accent, CFG.accentDk, 4)
    local ty = CFG.topY + 0.020
    rect(cx - 0.088, ty + 0.0035, 0.011, 0.011, CFG.accent, uiA(255))
    rect(cx - 0.088, ty + 0.0035, 0.005, 0.005, CFG.bg, uiA(255))
    txt(cx, ty - 0.0075, "Storm", 0.66, CFG.textHi, 255, true)
    -- ligne de contexte : vehicule courant, ou etat du joueur
    local info
    local v = veh()
    if v then
        local nm = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(v)))
        if not nm or nm == "NULL" or nm == "" then nm = "Vehicule" end
        info = string.upper(nm) .. "   ·   " .. math.floor(GetEntitySpeed(v) * 3.6) .. " km/h"
    else
        local c = GetEntityCoords(ped())
        info = string.format("A PIED   ·   %.0f  %.0f  %.0f", c.x, c.y, c.z)
    end
    txt(cx, CFG.topY + 0.043, info, 0.20, CFG.accent, 210, true)
end

local function drawSidebar()
    local top = CFG.topY + CFG.bannerH
    local n = #CATS
    local h = n * (CFG.sideRowH + 0.0016) + 0.010
    shadow(CFG.sidebarX, top + h / 2 - 0.005, CFG.sidebarW, h)
    rect(CFG.sidebarX, top + h / 2 - 0.005, CFG.sidebarW, h, CFG.panel, uiA(245))

    local y = top + 0.0035
    for i, c in ipairs(CATS) do
        local act = (i == S.sideIdx)
        local lx = CFG.sidebarX - CFG.sidebarW / 2 + 0.014
        if act and S.focus == "sidebar" then
            grad(CFG.sidebarX, y, CFG.sidebarW - 0.007, CFG.sideRowH, CFG.accent, CFG.accentDk, 6)
            raw(CFG.sidebarX, y - CFG.sideRowH / 2 + 0.0007, CFG.sidebarW - 0.007, 0.0009,
                255, 255, 255, uiA(60))
            txt(lx, y - CFG.sideRowH / 2 + 0.0055, string.upper(c[1]), 0.30,
                { r = 16, g = 14, b = 18 }, 255, false)
        elseif act then
            rect(CFG.sidebarX, y, CFG.sidebarW - 0.007, CFG.sideRowH, CFG.card, uiA(245))
            rect(CFG.sidebarX - CFG.sidebarW / 2 + 0.0055, y, 0.0030, CFG.sideRowH * 0.62,
                CFG.accent, uiA(255))
            txt(lx, y - CFG.sideRowH / 2 + 0.0055, string.upper(c[1]), 0.30, CFG.accent, 255, false)
        else
            txt(lx, y - CFG.sideRowH / 2 + 0.0055, string.upper(c[1]), 0.30, CFG.textDim, 255, false)
        end
        y = y + CFG.sideRowH + 0.0016
    end
end

local function hintText()
    if S.focus == "sidebar" then
        return "HAUT/BAS  categorie      TAB / ENTREE  entrer"
    end
    local cat = CATS[S.sideIdx][1]
    if cat == "Tenues" then
        return "ENTREE  sauver / charger      FIN  effacer      TAB  retour"
    elseif cat == "Vetements" or cat == "Accessoires" then
        return "GAUCHE/DROITE  style      PGUP/PGDN  texture      TAB  retour"
    elseif cat == "Binds" then
        return "ENTREE  assigner      FIN  supprimer      TAB  retour"
    end
    return "GAUCHE/DROITE  modifier      ENTREE  valider      TAB  retour"
end

local function drawValue(it, vx, cy)
    local k = it.kind
    if k == "toggle" then
        switch(vx - 0.011, cy, it.get())
    elseif k == "num" then
        chip(vx, cy, it.get())
    elseif k == "action" then
        chip(vx, cy, "OK", CFG.accent2)
    elseif k == "menu" then
        txt(vx - 0.006, cy - CFG.rowH / 2 + 0.0055, ">", 0.32, CFG.accent2, 255, false)
    elseif k == "back" then
        txt(vx - 0.006, cy - CFG.rowH / 2 + 0.0055, "<", 0.32, CFG.textDim, 255, false)
    elseif k == "outfit" then
        local used = S.outfits[it.slot] ~= nil
        chip(vx, cy, used and "OCCUPEE" or "VIDE", used and CFG.accent or nil)
    elseif k == "vehslot" then
        local used = S.vehSlots[it.slot] ~= nil
        chip(vx, cy, used and "OCCUPEE" or "VIDE", used and CFG.accent or nil)
    elseif k == "bind" then
        if S.bindCapture == it.id then
            chip(vx, cy, "APPUYEZ...", CFG.accent)
        else
            chip(vx, cy, bindName(it.id), S.binds[it.id] and CFG.accent or nil)
        end
    end
end

local function drawContent()
    local items, title, needVeh = activeItems()
    local blocked = needVeh and not veh()
    local total = #items
    local vis = math.min(total, CFG.maxRows)

    local first = 1
    if total > CFG.maxRows then
        first = clamp(S.itemIdx - math.floor(CFG.maxRows / 2), 1, total - CFG.maxRows + 1)
    end

    local headH, footH = 0.038, 0.024
    local bodyH = (blocked and CFG.rowH or vis * (CFG.rowH + 0.0014)) + 0.009
    local panelH = headH + bodyH + footH
    local top = CFG.topY + CFG.bannerH
    local pcy = top + panelH / 2 - 0.005

    shadow(CFG.contentX, pcy, CFG.contentW, panelH)
    rect(CFG.contentX, pcy, CFG.contentW, panelH, CFG.panel, uiA(245))

    local y = top + headH / 2 - 0.005
    grad(CFG.contentX, y, CFG.contentW, headH, { r = 34, g = 37, b = 50 }, CFG.panel, 6)
    txt(CFG.contentX - CFG.contentW / 2 + 0.012, y - 0.0085, string.upper(title),
        0.35, CFG.textHi, 255, false)
    if not blocked and total > 0 then
        txt(CFG.contentX + CFG.contentW / 2 - 0.012, y - 0.0075,
            S.itemIdx .. " / " .. total, 0.26, CFG.textDim, 255, false)
    end
    rect(CFG.contentX, y + headH / 2 - 0.0008, CFG.contentW, 0.0016, CFG.accent, uiA(190))

    y = top + headH + 0.004

    if blocked then
        txt(CFG.contentX, y + CFG.rowH / 2 - 0.0095, "Montez dans un vehicule...",
            0.30, CFG.textDim, 255, true)
    else
        local lx = CFG.contentX - CFG.contentW / 2 + 0.012
        local vx = CFG.contentX + CFG.contentW / 2 - 0.012

        for slot = 0, vis - 1 do
            local i = first + slot
            local it = items[i]
            if it then
                local cy = y + CFG.rowH / 2
                local sel = (i == S.itemIdx) and S.focus == "content"
                if sel then
                    grad(CFG.contentX, cy, CFG.contentW - 0.008, CFG.rowH,
                        { r = 62, g = 34, b = 46 }, { r = 34, g = 27, b = 38 }, 6)
                    rect(CFG.contentX - CFG.contentW / 2 + 0.0062, cy, 0.0032, CFG.rowH * 0.66,
                        CFG.accent, uiA(255))
                else
                    rect(CFG.contentX, cy, CFG.contentW - 0.008, CFG.rowH,
                        (i % 2 == 0) and CFG.cardAlt or CFG.card, uiA(210))
                end
                txt(lx, cy - CFG.rowH / 2 + 0.0058, it.label, 0.295,
                    sel and CFG.accent or CFG.textHi, 255, false)
                drawValue(it, vx, cy)
                y = y + CFG.rowH + 0.0014
            end
        end

        if total > CFG.maxRows then
            local tx = CFG.contentX + CFG.contentW / 2 - 0.0032
            local tt = top + headH + 0.004
            local th = vis * (CFG.rowH + 0.0014)
            raw(tx, tt + th / 2, 0.0022, th, 255, 255, 255, uiA(28))
            local thumb = math.max(0.010, th * (vis / total))
            local prog = (total > vis) and ((first - 1) / (total - vis)) or 0
            rect(tx, tt + thumb / 2 + (th - thumb) * prog, 0.0022, thumb, CFG.accent, uiA(235))
        end
    end

    local fcy = top + panelH - footH / 2 - 0.005
    raw(CFG.contentX, fcy - footH / 2, CFG.contentW, 0.0012, 255, 255, 255, uiA(24))
    txt(CFG.contentX, fcy - 0.0082, hintText(), 0.215, CFG.textDim, 255, true)
end

-- ============================== INPUT ==============================

local function goBack()
    if S.subNode then
        S.subNode = S.subNode.parent
        S.itemIdx = 1
        return true
    end
    return false
end

-- Les actions destructrices demandent une seconde pression dans les 2 s.
local function needsConfirm(it)
    if not it.confirm then return false end
    local now = GetGameTimer()
    if S.confirmId == it.label and now < S.confirmUntil then
        S.confirmId, S.confirmUntil = nil, 0
        return false
    end
    S.confirmId, S.confirmUntil = it.label, now + 2000
    notify("confirmez : appuyez a nouveau sur ENTREE")
    sound("ERROR")
    return true
end

local function handleInput()
    if S.focus == "sidebar" then
        if key(CFG.key.up) or key(CFG.key.left) then
            S.sideIdx = cycle(S.sideIdx - 1, 1, #CATS)
            S.itemIdx, S.subNode = 1, nil
            sound("NAV_UP_DOWN")
        end
        if key(CFG.key.down) or key(CFG.key.right) then
            S.sideIdx = cycle(S.sideIdx + 1, 1, #CATS)
            S.itemIdx, S.subNode = 1, nil
            sound("NAV_UP_DOWN")
        end
        if keyOnce(CFG.key.tab) or keyOnce(CFG.key.enter) then
            S.focus = "content"
            sound("SELECT")
        end
        return
    end

    local items, _, needVeh = activeItems()
    local blocked = needVeh and not veh()

    if keyOnce(CFG.key.tab) then
        S.focus = "sidebar"
        sound("BACK")
        return
    end
    if keyOnce(CFG.key.back) then
        if not goBack() then S.focus = "sidebar" end
        sound("BACK")
        return
    end

    if key(CFG.key.up) then
        S.itemIdx = cycle(S.itemIdx - 1, 1, #items)
        sound("NAV_UP_DOWN")
    elseif key(CFG.key.down) then
        S.itemIdx = cycle(S.itemIdx + 1, 1, #items)
        sound("NAV_UP_DOWN")
    end

    if blocked then return end
    local it = items[S.itemIdx]
    if not it then return end

    local dir = 0
    if key(CFG.key.left) then dir = -1 elseif key(CFG.key.right) then dir = 1 end
    if dir ~= 0 and it.change then
        it.change(dir)
        sound("NAV_LEFT_RIGHT")
    end

    local alt = 0
    if key(CFG.key.pgup) then alt = 1 elseif key(CFG.key.pgdn) then alt = -1 end
    if alt ~= 0 and it.alt then
        it.alt(alt)
        sound("NAV_LEFT_RIGHT")
    end

    if keyOnce(CFG.key.enter) then
        local k = it.kind
        if (k == "action" or k == "toggle") and needsConfirm(it) then return end
        sound("SELECT")
        if k == "back" then
            goBack()
        elseif k == "menu" then
            it.child.parent = S.subNode   -- nil au premier niveau
            S.subNode = it.child
            S.itemIdx = 1
        elseif k == "toggle" then
            it.set(not it.get())
        elseif k == "action" then
            it.run()
        elseif k == "outfit" then
            if S.outfits[it.slot] then outfitLoad(it.slot) else outfitSave(it.slot) end
        elseif k == "vehslot" then
            if S.vehSlots[it.slot] then vehSlotLoad(it.slot) else vehSlotSave(it.slot) end
        elseif k == "bind" then
            S.bindCapture = it.id
            notify("appuyez sur la touche a assigner")
        end
    end

    if keyOnce(CFG.key.clear) then
        if it.kind == "outfit" and S.outfits[it.slot] then
            outfitClear(it.slot)
        elseif it.kind == "vehslot" and S.vehSlots[it.slot] then
            vehSlotClear(it.slot)
        elseif it.kind == "bind" and S.binds[it.id] then
            S.binds[it.id] = nil
            saveSettings()
            notify("bind supprime")
        end
    end
end

-- ======================== BOUCLES PRINCIPALES ========================

CreateThread(loadAll)

-- capture d'un bind
CreateThread(function()
    while not S.unloaded do
        if S.bindCapture then
            Wait(0)
            for _, k in ipairs(BIND_KEYS) do
                if IsRawKeyPressed(k.vk) then
                    for id, vk in pairs(S.binds) do
                        if vk == k.vk then S.binds[id] = nil end
                    end
                    S.binds[S.bindCapture] = k.vk
                    saveSettings()
                    notify("touche assignee : " .. k.name)
                    S.bindCapture = nil
                    Wait(250)
                    break
                end
            end
        else
            Wait(150)
        end
    end
end)

-- declenchement des binds (menu ferme uniquement)
CreateThread(function()
    while not S.unloaded do
        Wait(0)
        if not S.open and not S.bindCapture then
            for _, b in ipairs(mBinds) do
                local vk = S.binds[b.id]
                if vk then
                    local down = IsRawKeyPressed(vk)
                    if down and not S.bindPrev[b.id] then b.run() end
                    S.bindPrev[b.id] = down
                end
            end
        else
            Wait(100)
        end
    end
end)

-- rendu + navigation
CreateThread(function()
    while not S.unloaded do
        Wait(0)
        if S.open then
            drawBanner()
            drawSidebar()
            drawContent()
            handleInput()
        else
            Wait(200)
        end
    end
end)

-- ouverture / fermeture
CreateThread(function()
    while not S.unloaded do
        Wait(0)
        if keyOnce(CFG.key.toggle) then
            S.open = not S.open
            sound(S.open and "SELECT" or "BACK")
            if S.open then
                -- on reprend la ou on s'etait arrete
                S.focus = "sidebar"
                S.subNode = nil
                S.itemIdx = 1
            end
        end
    end
end)
