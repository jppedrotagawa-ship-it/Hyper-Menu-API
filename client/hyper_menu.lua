-- ===========================================================================
--  Hyper Menu (Lua) - menu classico desenhado no jogo (estilo Shark)
--
--  Navegacao: setas + ENTER + BACKSPACE (volta/fecha)
--  Tipos de item: toggle [x], cycle <valor>, acao >>, lista modal
--  Abre/fecha: tecla configurada (padrao F9)
-- ===========================================================================

HyperMenu = {}

local C = HyperMenuConfig
local A = C.accent

-- ---------------------------------------------------------------- helpers
local function myPed() return PlayerPedId() end
local function inVeh() return IsPedInAnyVehicle(myPed(), false) end
local function myVeh() return GetVehiclePedIsIn(myPed(), false) end

local function notify(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString('~b~[Hyper]~w~ ' .. text)
    DrawNotification(false, false)
end

local function setWeather(name)
    SetWeatherTypePersist(name)
    SetWeatherTypeNowPersist(name)
end

-- --------------------------------------------------------------- framework
local Menu = HyperMenu

Menu.open = false
Menu.categories = {}
Menu.catIdx = 1
Menu.cursor = 0
Menu.scroll = 0
Menu.modal = nil        -- { title, items, cursor, scroll }
Menu.target = nil       -- jogador alvo nas listas
Menu.loops = {}

-- registra loop por-frame que roda enquanto o toggle estiver ativo
local function addLoop(key, state, fn)
    Menu.loops[key] = { active = state, fn = fn }
end

-- construtores de categoria
local function category(name)
    local cat = { name = name, items = {} }
    Menu.categories[#Menu.categories + 1] = cat
    return cat
end

local function opt(label, kind, cfg)
    return { label = label, kind = kind, cfg = cfg or {}, state = false }
end

-- item vira uma lista modal (ex.: jogadores, veiculos)
local function openModal(title, items)
    Menu.modal = { title = title, items = items, cursor = 0, scroll = 0 }
end

local function closeModal()
    Menu.modal = nil
    Menu.target = nil
end

-- ------------------------------------------------------------- categorias
-- LOCAIS
local locais = category('Locais')
locais.items = {
    opt('Godmode', 'toggle', { key = 'god', loop = function(s)
        local p = myPed()
        SetPlayerInvincible(PlayerId(), true)
        SetEntityInvincible(p, true)
        SetEntityProofs(p, true, true, true, true, true, true, true, true)
    end, off = function()
        local p = myPed()
        SetPlayerInvincible(PlayerId(), false)
        SetEntityInvincible(p, false)
        SetEntityProofs(p, false, false, false, false, false, false, false, false)
    end }),
    opt('Invisivel', 'toggle', { key = 'invis', loop = function(s)
        local p = myPed()
        SetEntityVisible(p, false, false)
        SetEntityAlpha(p, 0, true)
    end, off = function()
        local p = myPed()
        SetEntityVisible(p, true, false)
        SetEntityAlpha(p, 255, true)
    end }),
    opt('Sem Ragdoll', 'toggle', { key = 'ragdoll', on = function(s)
        SetPedCanRagdoll(myPed(), not s)
    end }),
    opt('Stamina Infinita', 'toggle', { key = 'stamina', loop = function(s)
        RestorePlayerStamina(PlayerId(), 1.0)
    end }),
    opt('Super Velocidade', 'toggle', { key = 'sprint', loop = function(s)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
    end, off = function()
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end }),
    opt('Curar', 'action', { run = function()
        SetEntityHealth(myPed(), 200)
        notify('curado')
    end }),
    opt('Colete', 'action', { run = function()
        SetPedArmour(myPed(), 100)
        notify('colete 100')
    end }),
    opt('Limpar Visual', 'action', { run = function()
        local p = myPed()
        ClearPedBloodDamage(p)
        ClearPedWetness(p)
        ResetPedVisibleDamage(p)
        notify('visual limpo')
    end }),
}

-- ARMA
local arma = category('Arma')
arma.items = {
    opt('Municao Infinita', 'toggle', { key = 'ammo', loop = function(s)
        local p = myPed()
        SetPedInfiniteAmmo(p, true)
        SetPedInfiniteAmmoClip(p, true)
    end, off = function()
        local p = myPed()
        SetPedInfiniteAmmo(p, false)
        SetPedInfiniteAmmoClip(p, false)
    end }),
    opt('Municao Explosiva', 'toggle', { key = 'exp', loop = function(s)
        SetExplosiveAmmoThisFrame(myPed(), true)
    end }),
    opt('Municao Incendiaria', 'toggle', { key = 'fire', loop = function(s)
        SetFireAmmoThisFrame(myPed(), true)
    end }),
    opt('Pistola', 'action', { run = function()
        GiveWeaponToPed(myPed(), GetHashKey('WEAPON_PISTOL'), 9999, false, true)
    end }),
    opt('SMG', 'action', { run = function()
        GiveWeaponToPed(myPed(), GetHashKey('WEAPON_SMG'), 9999, false, true)
    end }),
    opt('Fuzil de Assalto', 'action', { run = function()
        GiveWeaponToPed(myPed(), GetHashKey('WEAPON_ASSAULTRIFLE'), 9999, false, true)
    end }),
    opt('Sniper', 'action', { run = function()
        GiveWeaponToPed(myPed(), GetHashKey('WEAPON_SNIPERRIFLE'), 9999, false, true)
    end }),
    opt('RPG', 'action', { run = function()
        GiveWeaponToPed(myPed(), GetHashKey('WEAPON_RPG'), 9999, false, true)
    end }),
    opt('Todas as Armas', 'action', { run = function()
        local p = myPed()
        for _, w in ipairs({ 'WEAPON_PISTOL', 'WEAPON_SMG', 'WEAPON_ASSAULTRIFLE',
                             'WEAPON_SNIPERRIFLE', 'WEAPON_RPG', 'WEAPON_COMBATMG',
                             'WEAPON_KNIFE', 'WEAPON_STUNGUN' }) do
            GiveWeaponToPed(p, GetHashKey(w), 9999, false, true)
        end
        notify('todas as armas')
    end }),
    opt('Remover Armas', 'action', { run = function()
        RemoveAllPedWeapons(myPed(), true)
        notify('armas removidas')
    end }),
}

-- VEICULO
local veiculo = category('Veiculo')
veiculo.items = {
    opt('Reparar', 'action', { run = function()
        local v = myVeh()
        if v == 0 then notify('sem veiculo') return end
        SetVehicleFixed(v)
        SetVehicleDirtLevel(v, 0.0)
        SetVehicleEngineHealth(v, 1000.0)
        SetVehiclePetrolTankHealth(v, 4000.0)
        notify('reparado')
    end }),
    opt('Ligar Motor', 'action', { run = function()
        local v = myVeh()
        if v == 0 then notify('sem veiculo') return end
        SetVehicleEngineOn(v, true, true, false)
        notify('motor ligado')
    end }),
    opt('Pneus Blindados', 'toggle', { key = 'tyres', on = function(s)
        local v = myVeh()
        if v ~= 0 then SetVehicleBulletProofTyres(v, s) end
    end }),
    opt('Tuning Maximo', 'action', { run = function()
        local v = myVeh()
        if v == 0 then notify('sem veiculo') return end
        SetVehicleModKit(v, 0)
        for mt = 0, 49 do
            local mx = GetNumVehicleMods(v, mt)
            if mx > 0 then SetVehicleMod(v, mt, mx - 1, false) end
        end
        SetVehicleWheelType(v, 7)
        SetVehicleWindowTint(v, 3)
        notify('tuning maximo')
    end }),
    opt('Lavar', 'action', { run = function()
        local v = myVeh()
        if v == 0 then notify('sem veiculo') return end
        SetVehicleDirtLevel(v, 0.0)
        notify('lavado')
    end }),
    opt('Velocidade Maxima', 'toggle', { key = 'topspeed', loop = function(s)
        local v = myVeh()
        if v ~= 0 then SetEntityMaxSpeed(v, 0.0) end
    end }),
    opt('Apagar Veiculo', 'action', { run = function()
        local v = myVeh()
        if v == 0 then notify('sem veiculo') return end
        SetEntityAsMissionEntity(v, true, true)
        DeleteVehicle(v)
        notify('veiculo apagado')
    end }),
    opt('Spawnar Veiculo', 'list', { run = function()
        local models = {
            { 'Zentorno', 'zentorno' }, { 'Sultan RS', 'sultanrs' },
            { 'Buffalo', 'buffalo' }, { 'Elegy RH8', 'elegy2' },
            { 'Bati 801', 'bati' }, { 'Deluxo', 'deluxo' },
            { 'Toreador', 'toreador' }, { 'Adder', 'adder' },
            { 'Kuruma', 'kuruma2' }, { 'Oppressor MK2', 'oppressor2' },
            { 'Dubsta 6x6', 'dubsta3' }, { 'Faggio', 'faggio2' },
        }
        local items = {}
        for _, m in ipairs(models) do
            items[#items + 1] = { label = m[1], run = function()
                local hash = GetHashKey(m[2])
                RequestModel(hash)
                local t = GetGameTimer()
                while not HasModelLoaded(hash) and GetGameTimer() - t < 4000 do Citizen.Wait(10) end
                if HasModelLoaded(hash) then
                    local p = myPed()
                    local c = GetEntityCoords(p)
                    local v = CreateVehicle(hash, c.x + 4.0, c.y, c.z, GetEntityHeading(p), true, false)
                    SetVehicleOnGroundProperly(v)
                    TaskWarpPedIntoVehicle(p, v, -1)
                    notify('' .. m[1] .. ' spawnado')
                end
            end }
        end
        openModal('Spawnar Veiculo', items)
    end }),
}

-- TELEPORTE
local teleporte = category('Teleporte')
local function tpWaypoint()
    local blip = GetFirstBlipInfoId(8)
    if blip == 0 then notify('defina um waypoint') return end
    local x, y = GetBlipInfoIdCoord(blip)
    local found, z = GetGroundZFor_3DCoord(x, y, 250.0, true)
    if not found then found, z = GetGroundZFor_3DCoord(x, y, 50.0, true) end
    if not found then notify('coordenadas invalidas') return end
    local p = myPed()
    SetEntityCoords(p, x, y, z + 1.0, false, false, false, false)
    ClearPedTasksImmediately(p)
    notify('teleportado')
end

teleporte.items = {
    opt('Teleporte ao Waypoint', 'action', { run = tpWaypoint }),
    opt('Hotspots', 'list', { run = function()
        local spots = {
            { 'Aeroporto', { -1034.3, -2733.8, 13.8 } },
            { 'Casino', { 944.6, 36.6, 71.9 } },
            { 'Vinewood', { 348.5, 195.0, 103.0 } },
            { 'Monte Chilliad', { 508.0, 5603.0, 799.0 } },
            { 'Banco Pacific', { 253.3, 221.0, 101.6 } },
            { 'Ponte Grande', { 34.0, -1646.0, 29.6 } },
        }
        local items = {}
        for _, s in ipairs(spots) do
            items[#items + 1] = { label = s[1], run = function()
                local p = myPed()
                SetEntityCoords(p, s[2][1], s[2][2], s[2][3], false, false, false, false)
                ClearPedTasksImmediately(p)
                notify('teleportado para ' .. s[1])
            end }
        end
        openModal('Hotspots', items)
    end }),
    opt('Para o Jogador mais Proximo', 'action', { run = function()
        local players = GetActivePlayers()
        local closest = nil
        local closestDist = 1e9
        local me = myPed()
        local mc = GetEntityCoords(me)
        for _, pl in ipairs(players) do
            if pl ~= PlayerId() then
                local pc = GetEntityCoords(GetPlayerPed(pl))
                local d = #(mc - pc)
                if d < closestDist then closestDist = d; closest = pl end
            end
        end
        if closest then
            local c = GetEntityCoords(GetPlayerPed(closest))
            SetEntityCoords(me, c.x, c.y, c.z + 1.0, false, false, false, false)
            notify('teleportado ate o jogador')
        else
            notify('nenhum jogador')
        end
    end }),
}

-- VISUAL
local visual = category('Visual')
visual.items = {
    opt('Tempo', 'cycle', { key = 'weather', options = {
        { 'Ensolarado', 'EXTRASUNNY' }, { 'Limpo', 'CLEAR' }, { 'Nublado', 'CLOUDS' },
        { 'Chuva', 'RAIN' }, { 'Nevoeiro', 'FOGGY' }, { 'Tempestade', 'THUNDER' },
        { 'Neve', 'SNOW' },
    }, value = 1, onChange = function(opts, i)
        setWeather(opts[i][2])
    end }),
    opt('Horario', 'cycle', { key = 'time', options = {
        { 'Meia-noite', 0, 0 }, { 'Madrugada', 3, 0 }, { 'Manha', 9, 0 },
        { 'Tarde', 14, 0 }, { 'Entardecer', 18, 0 }, { 'Noite', 23, 0 },
    }, value = 3, onChange = function(opts, i)
        SetClockTime(opts[i][2], opts[i][3], 0)
    end }),
    opt('Congelar Tempo', 'toggle', { key = 'freezew', loop = function(s)
        SetFreezeWeatherType(true)
    end, off = function()
        SetFreezeWeatherType(false)
    end }),
}

-- JOGADORES (modal dinamico por jogador)
local jogadores = category('Jogadores')
local function playerItemsPlayers()
    local items = {}
    local players = GetActivePlayers()
    if #players == 0 then items[#items + 1] = { label = 'nenhum jogador', run = function() end } end
    -- acoes em grupo
    items[#items + 1] = { label = 'Todos: Matar', run = function()
        for _, pl in ipairs(GetActivePlayers()) do
            if pl ~= PlayerId() then SetEntityHealth(GetPlayerPed(pl), 0) end
        end
        notify('todos mortos')
    end }
    items[#items + 1] = { label = 'Todos: Explodir', run = function()
        for _, pl in ipairs(GetActivePlayers()) do
            if pl ~= PlayerId() then
                local c = GetEntityCoords(GetPlayerPed(pl))
                AddExplosion(c.x, c.y, c.z, 0, 99.0, true, false, 0.5)
            end
        end
        notify('todos explodidos')
    end }
    items[#items + 1] = { label = 'Todos: Para Mim', run = function()
        local me = myPed()
        local mc = GetEntityCoords(me)
        for _, pl in ipairs(GetActivePlayers()) do
            if pl ~= PlayerId() then
                SetEntityCoords(GetPlayerPed(pl), mc.x + 2.0, mc.y, mc.z, false, false, false, false)
            end
        end
        notify('todos teleportados')
    end }
    for _, pl in ipairs(players) do
        if pl ~= PlayerId() then
            items[#items + 1] = { label = GetPlayerName(pl), sub = pl }
        end
    end
    return items
end

local function targetActions(pl)
    local name = GetPlayerName(pl)
    return {
        { label = 'Teleportar ate ' .. name, run = function()
            local c = GetEntityCoords(GetPlayerPed(pl))
            SetEntityCoords(myPed(), c.x, c.y, c.z + 1.0, false, false, false, false)
        end },
        { label = 'Trazer para mim', run = function()
            local c = GetEntityCoords(myPed())
            SetEntityCoords(GetPlayerPed(pl), c.x + 2.0, c.y, c.z, false, false, false, false)
        end },
        { label = 'Matar', run = function()
            SetEntityHealth(GetPlayerPed(pl), 0)
        end },
        { label = 'Explodir', run = function()
            local c = GetEntityCoords(GetPlayerPed(pl))
            AddExplosion(c.x, c.y, c.z, 0, 99.0, true, false, 0.5)
        end },
        { label = 'Congelar', run = function()
            FreezeEntityPosition(GetPlayerPed(pl), true)
        end },
        { label = 'Descongelar', run = function()
            FreezeEntityPosition(GetPlayerPed(pl), false)
        end },
        { label = 'Dar Carro', run = function()
            local hash = GetHashKey('zentorno')
            RequestModel(hash)
            local t = GetGameTimer()
            while not HasModelLoaded(hash) and GetGameTimer() - t < 4000 do Citizen.Wait(10) end
            if HasModelLoaded(hash) then
                local c = GetEntityCoords(GetPlayerPed(pl))
                local v = CreateVehicle(hash, c.x + 4.0, c.y, c.z, GetEntityHeading(GetPlayerPed(pl)), true, false)
                SetVehicleOnGroundProperly(v)
                SetPedIntoVehicle(GetPlayerPed(pl), v, -1)
                notify('carro entregue')
            end
        end },
    }
end

jogadores.items = {
    opt('Lista de Jogadores', 'list', { run = function()
        openModal('Jogadores', playerItemsPlayers())
    end }),
}

-- DIVERSOS
local diversos = category('Diversos')
diversos.items = {
    opt('Aimbot (assistir)', 'toggle', { key = 'aim', loop = function(s)
        local p = myPed()
        if IsPlayerFreeAiming(PlayerId()) then
            local t = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if t ~= 0 and IsEntityAPed(t) and t ~= p and not IsEntityDead(t) then
                local camPos = GetGameplayCamCoord()
                local tpos = GetEntityCoords(t)
                local dh = tpos - camPos
                local dist = #dh
                if dist <= C.aimRange then
                    local base = GetEntityHeading(p)
                    local absH = math.atan2(dh.y, dh.x) * (180.0 / math.pi)
                    local relH = absH - base
                    if relH > 180 then relH = relH - 360 end
                    if relH < -180 then relH = relH + 360 end
                    if math.abs(relH) <= C.aimFov then
                        SetGameplayCamRelativeHeading(relH)
                    end
                    local absP = math.atan2(tpos.z - camPos.z, dist) * (180.0 / math.pi)
                    if math.abs(absP) <= 35 then
                        SetGameplayCamRelativePitch(absP, 0.98)
                    end
                end
            end
        end
        Citizen.Wait(10)
    end }),
    opt('Auto-Reparar', 'toggle', { key = 'autorep', loop = function(s)
        local v = myVeh()
        if v ~= 0 then
            SetVehicleFixed(v)
            SetVehicleDirtLevel(v, 0.0)
        end
        Citizen.Wait(200)
    end }),
}

-- ------------------------------------------------------- navegacao (input)
local Controls = { up = 27, down = 173, left = 174, right = 175, enter = 201, back = 177 }
local WheelUp = 19   -- INPUT_MOUSE_UP (scroll pra cima)
local WheelDown = 20 -- INPUT_MOUSE_DOWN (scroll pra baixo)

local pressed = { up = false, down = false, left = false, right = false, enter = false, back = false }
local debounce = 80

local function readInput()
    local now = GetGameTimer()
    if now < (readInput._t or 0) then return end
    readInput._t = now + debounce
    for k, id in pairs(Controls) do
        pressed[k] = IsControlJustPressed(0, id) or IsControlJustPressed(2, id)
    end
    -- scroll do mouse tambem navega (so com o menu aberto)
    if IsControlJustPressed(0, WheelUp) or IsControlJustPressed(2, WheelUp) then pressed.up = true end
    if IsControlJustPressed(0, WheelDown) or IsControlJustPressed(2, WheelDown) then pressed.down = true end
end
readInput._t = 0

-- itens visiveis da categoria/modais
local function visibleItems()
    if Menu.modal then return Menu.modal.items end
    local cat = Menu.categories[Menu.catIdx]
    return cat and cat.items or {}
end

local function clampCursor()
    local items = visibleItems()
    local max = #items - 1
    if Menu.cursor > max then Menu.cursor = max end
    if Menu.cursor < 0 then Menu.cursor = 0 end
end

-- ----------------------------------------------------------------- open
local function setOpen(s)
    Menu.open = s
    if s then
        Menu.catIdx = 1
        Menu.cursor = 0
        Menu.scroll = 0
        closeModal()
    end
end

local function selectItem(item)
    if not item then return end
    if item.sub then
        openModal(item.label, targetActions(item.sub))
        return
    end
    local cfg = item.cfg
    if item.kind == 'toggle' then
        item.state = not item.state
        addLoop(cfg.key, item.state, cfg.loop)
        if item.state then
            if cfg.on then cfg.on(true) end
            if cfg.loop then cfg.loop(true) Citizen.Wait(0) end
        else
            if cfg.off then cfg.off() end
        end
    elseif item.kind == 'cycle' then
        cfg.value = cfg.value % #cfg.options + 1
        if cfg.onChange then cfg.onChange(cfg.options, cfg.value) end
    elseif item.kind == 'action' then
        if cfg.run then cfg.run() end
    elseif item.kind == 'list' then
        if cfg.run then cfg.run() end
    end
end

local function navigate()
    if Menu.modal then
        local m = Menu.modal
        if pressed.back then closeModal() return end
        if pressed.up then
            m.cursor = m.cursor - 1
            if m.cursor < 0 then m.cursor = #m.items - 1 end
            if m.cursor < m.scroll then m.scroll = m.cursor end
        elseif pressed.down then
            m.cursor = m.cursor + 1
            if m.cursor > #m.items - 1 then m.cursor = 0 end
            if m.cursor >= m.scroll + C.maxVisible then m.scroll = m.cursor - C.maxVisible + 1 end
        elseif pressed.enter then
            selectItem(m.items[m.cursor + 1])
        end
        return
    end
    if pressed.left then
        Menu.catIdx = Menu.catIdx - 1
        if Menu.catIdx < 1 then Menu.catIdx = #Menu.categories end
        Menu.cursor = 0
        Menu.scroll = 0
    elseif pressed.right then
        Menu.catIdx = Menu.catIdx % #Menu.categories + 1
        Menu.cursor = 0
        Menu.scroll = 0
    elseif pressed.up then
        Menu.cursor = Menu.cursor - 1
        if Menu.cursor < 0 then Menu.cursor = #visibleItems() - 1 end
        if Menu.cursor < Menu.scroll then Menu.scroll = Menu.cursor end
    elseif pressed.down then
        Menu.cursor = Menu.cursor + 1
        if Menu.cursor > #visibleItems() - 1 then Menu.cursor = 0 end
        if Menu.cursor >= Menu.scroll + C.maxVisible then Menu.scroll = Menu.cursor - C.maxVisible + 1 end
    elseif pressed.enter then
        local items = Menu.categories[Menu.catIdx].items
        selectItem(items[Menu.cursor + 1])
    elseif pressed.back then
        setOpen(false)
    end
end

-- ------------------------------------------------------------- desenho
local function rect(x, y, w, h, r, g, b, a)
    if a <= 0 then return end
    if a > 255 then a = 255 end
    if w < 0 or h < 0 then return end
    DrawRect(x + w / 2, y + h / 2, w, h, r, g, b, a)
end

local function text(x, y, s, scale, r, g, b, right, wrap)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.0, scale or 0.34)
    SetTextColour(r or 255, g or 255, b or 255, 255)
    SetTextDropShadow(1, 0, 0, 0, 200)
    if right and wrap then SetTextWrap(wrap[1], wrap[2]) end
    SetTextJustification(right and 2 or 0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(s)
    EndTextCommandDisplayText(x, y)
end

local LEFT_W  = 170
local RIGHT_W = 380
local TOTAL_W = LEFT_W + RIGHT_W
local HEAD_H  = 46
local ITEM_H  = 34
local CAT_H   = 31
local FOOT_H  = 26

-- brilho ao redor do item selecionado
local function glow(x, y, w, h, r, g, b, a)
    rect(x - 4, y - 4, w + 8, h + 8, r, g, b, math.floor(a * 0.30))
    rect(x - 1, y - 1, w + 2, h + 2, r, g, b, math.floor(a * 0.50))
end

local function drawHeader(x0, y0, title, w)
    rect(x0, y0, w, HEAD_H, 9, 12, 22, 248)
    -- borda accent com pulso
    local p = 0.55 + 0.45 * math.sin(GetGameTimer() / 420)
    rect(x0, y0 + HEAD_H - 3, w, 3, A.r, A.g, A.b, math.floor(150 + 105 * p))
    text(x0 + 14, y0 + 10, 'HYPER MENU', 0.45, A.r, A.g, A.b)
    text(x0 + 14, y0 + 27, title:upper(), 0.27, 165, 180, 200)
    text(x0 + w - 12, y0 + 10, 'v' .. (C.github.currentVersion or ''), 0.26,
         110, 125, 150, true, { x0, x0 + w - 12 })
end

local function drawCatPanel(x0, y0, h)
    rect(x0, y0, LEFT_W, h, 8, 11, 20, 235)
    for i, cat in ipairs(Menu.categories) do
        local y = y0 + (i - 1) * CAT_H
        local sel = i == Menu.catIdx
        if sel then
            rect(x0, y, LEFT_W, CAT_H, A.r, A.g, A.b, 55)
            rect(x0, y, 3, CAT_H, A.r, A.g, A.b, 255)
            text(x0 + 12, y + 7, cat.name, 0.31, 255, 255, 255)
        else
            text(x0 + 12, y + 7, cat.name, 0.31, 138, 150, 170)
            text(x0 + LEFT_W - 10, y + 7, '>>', 0.27, 60, 70, 86, true, { x0, x0 + LEFT_W - 10 })
        end
    end
end

local function drawItems(x0, y0, items, sc, cu, iw)
    local wrap = { x0 + 40, x0 + iw - 12 }
    local maxRows = math.min(C.maxVisible, #items)
    for i = sc + 1, sc + maxRows do
        local it = items[i]
        if not it then break end
        local y = y0 + (i - sc - 1) * ITEM_H
        local sel = (i - 1) == cu
        if sel then
            glow(x0 + 4, y + 1, iw - 8, ITEM_H - 2, A.r, A.g, A.b, 170)
            rect(x0 + 4, y + 1, iw - 8, ITEM_H - 2, A.r, A.g, A.b, 85)
            rect(x0 + 4, y + 2, 2, ITEM_H - 4, A.r, A.g, A.b, 255)
        end
        text(x0 + 14, y + 7, it.label, sel and 0.35 or 0.33,
             sel and 255 or 205, sel and 255 or 215, sel and 255 or 225)

        if it.kind == 'toggle' then
            local on = it.state
            text(x0 + iw - 12, y + 8, on and '[ON]' or '[OFF]', 0.29,
                 on and 52 or 140, on and 211 or 150, on and 153 or 170, true, wrap)
        elseif it.kind == 'cycle' then
            local cur = it.cfg.options[it.cfg.value]
            text(x0 + iw - 12, y + 8, '< ' .. (cur and cur[1] or '') .. ' >', 0.28,
                 120, 180, 255, true, wrap)
        elseif it.kind == 'list' then
            text(x0 + iw - 12, y + 8, '>>', 0.29, 120, 180, 255, true, wrap)
        elseif it.kind == 'action' then
            text(x0 + iw - 12, y + 8, '>>', 0.29, 205, 215, 230, true, wrap)
        end
    end
    -- indicador de scroll
    if sc + maxRows < #items then
        local y = y0 + maxRows * ITEM_H - 14
        text(x0 + iw - 12, y, 'v', 0.30, A.r, A.g, A.b, true, wrap)
    end
end

local function drawUI()
    if not Menu.open then return end
    local resW, resH = GetActiveScreenResolution()
    local x0 = math.floor(resW / 2 - TOTAL_W / 2)
    local y0 = math.floor(resH * 0.16)

    local modal = Menu.modal
    local items = modal and modal.items or Menu.categories[Menu.catIdx].items
    local title = modal and modal.title or Menu.categories[Menu.catIdx].name

    local maxRows = math.min(C.maxVisible, #items)
    local bodyH = math.max(maxRows * ITEM_H, #Menu.categories * CAT_H)
    local H = HEAD_H + bodyH + FOOT_H

    -- sombra + fundo
    rect(x0 - 3, y0 - 3, TOTAL_W + 6, H + 6, 0, 0, 0, 130)
    rect(x0, y0, TOTAL_W, H, 5, 8, 16, 237)

    drawHeader(x0, y0, title, TOTAL_W)

    -- painel esquerdo (categorias)
    if modal then
        rect(x0, y0 + HEAD_H, LEFT_W, bodyH, 8, 11, 20, 130)
        text(x0 + 12, y0 + HEAD_H + 12, 'SUBMENU', 0.30, 120, 134, 156)
        text(x0 + 12, y0 + HEAD_H + 30, title:upper(), 0.34, 255, 255, 255)
    else
        drawCatPanel(x0, y0 + HEAD_H, bodyH)
    end

    -- separador
    rect(x0 + LEFT_W, y0 + HEAD_H, 2, bodyH, A.r, A.g, A.b, 45)

    -- itens
    drawItems(x0 + LEFT_W, y0 + HEAD_H, items,
              modal and modal.scroll or Menu.scroll,
              modal and modal.cursor or Menu.cursor, RIGHT_W)

    -- rodape
    rect(x0, y0 + H - FOOT_H, TOTAL_W, FOOT_H, 6, 9, 17, 240)
    text(x0 + 12, y0 + H - FOOT_H + 6, 'SETAS / ENTER / BACKSPACE', 0.26, 130, 144, 165)
    text(x0 + TOTAL_W - 12, y0 + H - FOOT_H + 6,
         #items .. ' ITEM(S)', 0.26, 130, 144, 165, true, { x0, x0 + TOTAL_W - 12 })
end

-- ----------------------------------------------------------------- open
RegisterCommand('+hypermenu', function()
    setOpen(not Menu.open)
end, false)
RegisterKeyMapping('+hypermenu', 'Hyper Menu', 'keyboard', C.menuKey)

-- update thread: loops ativos + navegacao + draw
Citizen.CreateThread(function()
    local blink = 0
    while true do
        Citizen.Wait(0)
        if Menu.open then
            for _, id in pairs(Controls) do DisableControlAction(0, id, true) end
            DisableControlAction(0, WheelUp, true)
            DisableControlAction(0, WheelDown, true)
            readInput()
            navigate()
            drawUI()
        elseif C.openWithScroll then
            -- aba com o scroll do mouse (como menus injetados classicos)
            if IsControlJustPressed(0, WheelUp) or IsControlJustPressed(2, WheelUp)
               or IsControlJustPressed(0, WheelDown) or IsControlJustPressed(2, WheelDown) then
                setOpen(true)
            end
        end
        for _, l in pairs(Menu.loops) do
            if l.active and l.fn then l.fn(true) end
        end
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(2500)
    notify('carregado - role o mouse ou aperte ' .. C.menuKey .. ' para abrir')
end)