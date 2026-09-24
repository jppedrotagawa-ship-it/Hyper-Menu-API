-- ===========================================================================
--  Hyper Menu (Lua) - configuração
-- ===========================================================================

HyperMenuConfig = {}

-- tecla que abre/fecha o menu (o executor injeta e envia F9; o scroll tambem abre)
HyperMenuConfig.menuKey = 'F9'

-- abre o menu com o scroll do mouse (rolar pra cima ou pra baixo)
HyperMenuConfig.openWithScroll = true

-- GitHub (API) - repositorio do Hyper Menu
HyperMenuConfig.github = {
    owner  = 'jppedrotagawa-ship-it',
    repo   = 'Hyper-Menu-API',       -- recurso FiveM (fxmanifest v3.0.2)
    branch = 'main',                  -- branch com os arquivos
    token  = nil,                     -- opcional: teu token (aumenta o limite da API)
    checkUpdate = true,               -- true = verifica release nova ao iniciar
    currentVersion = '3.0.2'          -- usada na comparacao de versao
}

-- visor
HyperMenuConfig.accent = { r = 56, g = 189, b = 248 }
HyperMenuConfig.showHeader = true
HyperMenuConfig.maxVisible = 12      -- linhas visiveis antes de rolar

-- aimbot
HyperMenuConfig.aimRange = 120.0
HyperMenuConfig.aimFov = 60          -- graus de ajuste da camera
HyperMenuConfig.aimKey = 'G'