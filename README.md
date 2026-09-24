# Hyper-Menu-API

API do GitHub + menu clássico em Lua (sem NUI), estilo Shark Menu V5.

Recurso FiveM: menu desenhado no jogo que abre com o scroll do mouse
(ou F9). A API consulta releases/arquivos deste repositório.

## Arquivos

```
Hyper-Menu-API/
├── fxmanifest.lua
├── config.lua            <- owner/repo/branch, tecla, aimbot, accent
└── client/
    ├── github_api.lua    <- modulo GitHub (latest release / raw file / update check)
    └── hyper_menu.lua    <- menu completo
```

## Como usar

1. Copie a pasta para `resources/[local]/hyper-menu-api` no servidor.
2. `ensure hyper-menu-api`.
3. Role o scroll do mouse (ou F9) para abrir o menu.

## Opcoes do menu

- **Locais**: Godmode, Invisivel, Sem Ragdoll, Stamina Infinita, Super Velocidade, Curar, Colete, Limpar Visual
- **Arma**: Municao Infinita / Explosiva / Incendiaria, Pistola, SMG, Fuzil, Sniper, RPG, Todas as Armas, Remover
- **Veiculo**: Reparar, Ligar Motor, Pneus Blindados, Tuning Maximo, Lavar, Velocidade Maxima, Apagar, Spawnar
- **Teleporte**: Waypoint, Hotspots, Jogador mais proximo
- **Visual**: Tempo, Horario, Congelar Tempo
- **Jogadores**: acoes em grupo + submenu por jogador (trazer, matar, explodir, congelar, dar carro)
- **Diversos**: Aimbot, Auto-Reparar

## API do GitHub (client/github_api.lua)

Configura em `config.lua`:

```lua
HyperMenuConfig.github = {
    owner  = 'jppedrotagawa-ship-it',
    repo   = 'Hyper-Menu-API',
    branch = 'main',
    token  = nil,          -- opcional: teu token (aumenta limite de 60/h para 5000/h)
    checkUpdate = true,
    currentVersion = '3.0.0'
}
```

```lua
GitHubApi:getLatestRelease(function(tag) end)      -- tag da ultima release, ex. "v3.0.0"
GitHubApi:getFile('config.lua', function(c) end)   -- conteudo bruto de um arquivo
GitHubApi:checkUpdate('3.0.0', function(tag, novo) end)
GitHubApi:get(url, function(ok, body) end)         -- GET generico
```

Com o `checkUpdate = true`, o menu notifica no start se existir release
mais nova que a atual. Para isso, crie uma release com tag `v3.0.0`+.

## Releases

Cada atualizacao = nova release no GitHub. O menu avisa quando estiver
desatualizado.

## Navegacao

- Scroll do mouse: abre o menu e rola os itens
- Setas esquerda/direita: troca categoria
- Setas cima/baixo: rola os itens
- ENTER: ativa item
- BACKSPACE: volta ou fecha
- F9: abre/fecha