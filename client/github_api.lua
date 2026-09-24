-- ===========================================================================
--  GitHub API (Lua) - consulta repositorio/releases do projeto
--
--  Uso:
--    GitHubApi.getLatestRelease(function(tag) print(tag) end)
--    GitHubApi.getFile('nui/index.html', function(content) ... end)
--    GitHubApi.checkUpdate('1.0.0', function(remoteTag) ... end)
--
--  Com token (HyperMenuConfig.github.token) o limite sobe de 60/h para 5000/h.
-- ===========================================================================

GitHubApi = {}

local C = HyperMenuConfig.github

local function urlRelease()
    return 'https://api.github.com/repos/' .. C.owner .. '/' .. C.repo .. '/releases/latest'
end

local function urlFile(path)
    return 'https://raw.githubusercontent.com/' .. C.owner .. '/' .. C.repo .. '/' .. C.branch .. '/' .. path
end

local function headers()
    local h = { ['User-Agent'] = 'hyper-menu/' .. (C.currentVersion or '1.0.0') }
    if C.token and C.token ~= '' then h['Authorization'] = 'token ' .. C.token end
    return h
end

-- comparacao simples de versao "1.2.3" (retorna novo > atual)
local function isNewer(atual, novo)
    if not atual or not novo then return false end
    local function split(s)
        local t = {}
        for v in string.gmatch(s, '%d+') do t[#t + 1] = tonumber(v) end
        return t
    end
    local a, b = split(atual), split(novo)
    for i = 1, math.max(#a, #b) do
        local x = a[i] or 0
        local y = b[i] or 0
        if y > x then return true elseif y < x then return false end
    end
    return false
end

-- GET generico com callback(ok, body)
function GitHubApi:get(url, cb)
    if not C.owner or C.owner == 'SEU_USUARIO' then
        cb(false, '[github] configure HyperMenuConfig.github.owner/repo')
        return
    end
    PerformHttpRequest(url, function(status, body)
        cb(status == 200 and body or false, body)
    end, 'GET', '', headers())
end

-- tag da ultima release ("v1.2.3")
function GitHubApi:getLatestRelease(cb)
    self:get(urlRelease(), function(ok, body)
        if not ok or not body then cb(nil) return end
        local tag = string.match(body, '"tag_name"%s*:%s*"([^"]+)"')
        cb(tag)
    end)
end

-- conteudo bruto de um arquivo do repo (ex.: 'menu/opcoes.json')
function GitHubApi:getFile(path, cb)
    self:get(urlFile(path), function(ok, body)
        cb(ok and body or nil)
    end)
end

-- verifica se existe release mais nova que `atual`
function GitHubApi:checkUpdate(atual, cb)
    self:getLatestRelease(function(tag)
        local remote = tag and tag:gsub('^v', '') or nil
        cb(remote, remote and isNewer(atual, remote))
    end)
end

-- ------------------------------------------------ checagem no start
if C.checkUpdate then
    Citizen.CreateThread(function()
        Citizen.Wait(8000)
        GitHubApi:checkUpdate(C.currentVersion, function(remote, newer)
            if newer then
                print('[Hyper] nova versao disponivel no GitHub: ' .. remote)
                SetNotificationTextEntry('STRING')
                AddTextComponentString('~b~[Hyper]~w~ nova versao no GitHub: ' .. remote)
                DrawNotification(false, false)
            end
        end)
    end)
end