# Hyper Menu (Lua) - versao "Shark" classica

Menu desenhado no jogo (sem NUI), com modulo de API do GitHub para updates/share de configs.

## Estrutura

```
menu-lua/
├── fxmanifest.lua
├── config.lua
└── client/
    ├── github_api.lua   <- modulo GitHub (API/raw/releases)
    └── hyper_menu.lua   <- menu completo
```

## Como usar

1. Copie a pasta `menu-lua` para `resources/[local]/hyper-menu-lua` no teu servidor.
2. `ensure hyper-menu-lua` (ou `start hyper-menu-lua`).
3. **Role o scroll do mouse para abrir** (o executor injeta e o menu abre). O F9 (`HyperMenuConfig.menuKey`) também abre/fecha como alternativa. Feche com F9 ou BACKSPACE.

## Configuracao (config.lua)

| Chave | Descricao |
|---|---|
| `menuKey` | tecla que abre/fecha o menu (F9) |
| `github.owner` | teu usuario do GitHub |
| `github.repo` | nome do repositorio |
| `github.branch` | branch dos arquivos (main) |
| `github.token` | token opcional (aumenta limite da API de 60/h para 5000/h) |
| `github.checkUpdate` | checa release nova no start |
| `accent` | cor RGB do menu |
| `aimRange` / `aimFov` | alcance e angulo do aimbot |

## API do GitHub (client/github_api.lua)

Se o `owner` for o placeholder `SEU_USUARIO`, a API responde erro avisando pra configurar.

```lua
-- tag da ultima release (ex.: "v1.2.3"); cb(nil) se falhar
GitHubApi:getLatestRelease(function(tag) print(tag) end)

-- conteudo bruto de qualquer arquivo do repo
GitHubApi:getFile('config.json', function(content) ... end)

-- verifica se a versao atual e menor que a do repo
GitHubApi:checkUpdate('1.0.0', function(remoteTag, isNewer) ... end)

-- GET generico: cb(ok, body)
GitHubApi:get('https://raw.githubusercontent.com/...', function(ok, body) end)
```

Depois de criar teu repo e so fazer a release (tag `v1.0.0`+). O `checkUpdate` já está ligado atrás do botão *Diversos* (via notificação no start).

## Opcoes do menu

**Locais** - Godmode, Invisivel, Sem Ragdoll, Stamina Infinita, Super Velocidade, Curar, Colete, Limpar Visual

**Arma** - Municao Infinita / Explosiva / Incendiaria, Pistola, SMG, Fuzil de Assalto, Sniper, RPG, Todas as Armas, Remover Armas

**Veiculo** - Reparar, Ligar Motor, Pneus Blindados, Tuning Maximo, Lavar, Velocidade Maxima, Apagar Veiculo, Spawnar Veiculo

**Teleporte** - Teleporte ao Waypoint, Hotspots, Para o Jogador mais Proximo

**Visual** - Tempo (ciclo), Horario (ciclo), Congelar Tempo

**Jogadores** - Todos: Matar / Explodir / Para Mim; por jogador: Teleportar ate, Trazer, Matar, Explodir, Congelar, Descongelar, Dar Carro

**Diversos** - Aimbot, Auto-Reparar

## Navegacao

- Scroll do mouse (ou F9): abre o menu
- Scroll do mouse: rola os itens (cima/baixo)
- Setas esquerda/direita: troca de categoria
- Setas cima/baixo: rola os itens
- ENTER: ativa o item
- BACKSPACE: volta (no submenu) ou fecha o menu
- F9: fecha o menu

## Criar o repositorio (pra usar a API)

```bash
git init
git add .
git commit -m "Hyper Menu Lua"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/hyper-menu.git
git push -u origin main
```

Depois crie uma release pela pagina do repo (Tags -> release, tag `v1.0.0`).