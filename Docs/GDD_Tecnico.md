# ⚙️ BattleFantasy — Documento Técnico (TDD)

> **Versão:** 1.0 | **Data:** 2026-05-11
> **Status:** Fundação aprovada — pronto para iniciar desenvolvimento
> **Engine:** Godot 4 | **Backend:** Supabase | **Plataformas:** Mobile (primário), PC, Web

---

## 1. Visão Geral do Projeto

**BattleFantasy** é um Card-RPG por turnos com foco em estratégia de posicionamento e deck-building tático. O jogador monta um time de 4 lutadores e um deck de 20 cartas de suporte (Boost, Heal, Equipamento), combatendo em batalhas onde a ordem de ataque é determinada por Agilidade e a profundidade tática vem dos Pontos de Turno (PT) e do uso estratégico das cartas de suporte. Uma 5ª entidade "Patrono/Deus" poderá agir automaticamente no futuro de forma experimental.

### Metas de Produto

| Meta | Detalhe |
|:---|:---|
| **Plataforma primária** | Android e iOS (Mobile) |
| **Plataformas secundárias** | Windows, macOS, Linux, Web (HTML5) |
| **Modos de jogo** | PvE (campanha + missões) e PvP (online) |
| **Monetização** | Free-to-play com Loot Box e Pity System |
| **Estilo visual** | Anime / JRPG Mobile (ref: Fate Grand Order, 7DS Grand Cross) |

---

## 2. Stack Tecnológica

### Engine: Godot 4

| Componente | Detalhe |
|:---|:---|
| **Engine** | Godot 4 (LTS estável mais recente) |
| **Linguagem** | GDScript (nativo) / C# (módulos críticos) |
| **Renderer** | Mobile Compatibility (otimizado) |
| **Exports** | Android `.apk`, iOS `.ipa`, Windows, macOS, Linux, HTML5 |

**Por que Godot 4:** Engine 2D com suporte nativo a shaders, partículas e animações. Export direto para todas as plataformas. Gratuito e open-source, sem royalties.

### Backend: Supabase

| Serviço | Uso |
|:---|:---|
| **Auth** | Login via e-mail, Google, Apple ID |
| **PostgreSQL** | Dados de jogadores, cartas, decks, progresso PvE |
| **Realtime** | Sincronização de batalhas PvP |
| **Edge Functions** | Lógica do Pity System, validação de batalhas |

**Integração Godot ↔ Supabase:** HTTP via `HTTPRequest` node + plugin `supabase-gdscript`. Realtime via WebSocket nativo do Godot.

---

## 3. Estrutura de Pastas do Projeto

```
BattleFantasy/
├── Doc/
│   ├── GDD_Tecnico.md          ← Este documento
│   └── GDD_Jogo.md             ← Regras e mecânicas do jogo
├── concept_art/                ← Referências visuais aprovadas
├── project.godot
├── assets/
│   ├── cards/fighters/         ← Arte dos lutadores
│   ├── cards/boosts/           ← Arte das cartas de boost
│   ├── cards/heals/
│   ├── cards/equipment/
│   ├── ui/                     ← HUD, menus, botões
│   ├── backgrounds/            ← Cenários de batalha
│   ├── vfx/                    ← Efeitos de habilidades
│   ├── sfx/
│   └── music/
└── src/
    ├── core/
    │   ├── BattleEngine.gd     ← Orquestrador principal
    │   ├── TurnQueue.gd        ← Fila ordenada por AGI
    │   ├── PTManager.gd        ← Pontos de Turno (rampa)
    │   ├── DamageCalculator.gd ← Fórmulas de dano
    │   └── CooldownManager.gd
    ├── entities/
    │   ├── Fighter.gd          ← Classe base do lutador
    │   ├── Card.gd             ← Classe base das cartas
    │   ├── Formation.gd        ← Formações e bônus posicionais
    │   └── Deck.gd             ← Gerenciamento do deck
    ├── data/
    │   ├── fighters/           ← JSON de cada lutador
    │   ├── cards/              ← JSON de cada carta
    │   └── types_matrix.json   ← Matriz de tipos
    ├── scenes/
    │   ├── Battle/
    │   │   ├── BattleScreen.tscn
    │   │   ├── Formation.tscn
    │   │   ├── CardHand.tscn
    │   │   └── TurnIndicator.tscn
    │   └── Meta/
    │       ├── MainMenu.tscn
    │       ├── DeckBuilder.tscn
    │       ├── Collection.tscn
    │       ├── GachaScreen.tscn
    │       ├── PvEMap.tscn
    │       └── PvPLobby.tscn
    └── network/
        ├── SupabaseClient.gd
        ├── AuthManager.gd
        ├── DeckSync.gd
        └── PvPBridge.gd
```

---

## 4. Modelos de Dados

### Fighter (GDScript)

```gdscript
class_name Fighter

var id: String              # "fire_warrior_ignis"
var display_name: String
var type: String            # "FIRE" | "DRAGON" | "FIGHTER" | ...
var rarity: String          # "NORMAL" | "RARE" | "LEGENDARY" | "MYTHIC"

# Atributos base
var hp: int
var hp_max: int
var atk_f: int              # Ataque Físico
var def_f: int              # Defesa Física
var atk_s: int              # Ataque Especial
var def_s: int              # Defesa Especial
var agi: int                # Define ordem de turno

# Estado de batalha
var position: int           # 0-4 (índice na formação)
var cooldowns: Dictionary   # { "skill_id": turns_remaining }
var status_effects: Array   # [{ "type", "turns", "value" }]
var equipment: Array        # Cartas de equipamento aplicadas

# Habilidades built-in (não do deck)
var skills: Array           # [{ "id","name","pt_cost","cd","type","power" }]
var passive: Dictionary     # Lendária+: { "id", "effect" }
var leadership: Dictionary  # Mítica: { "id", "effect" }
```

### Card (GDScript)

```gdscript
class_name Card

var id: String
var display_name: String
var card_type: String       # "BOOST" | "HEAL" | "EQUIPMENT"
var pt_cost: int            # 1–3 PT
var rarity: String

# BOOST
var boost_type: String      # Tipo alvo (ou "ANY")
var boost_stat: String      # "ATK_F" | "ATK_S" | ...
var boost_value: float      # Multiplicador (ex: 1.8)
var boost_duration: int     # 0 = apenas próxima skill

# HEAL
var heal_value: int
var heal_target: String     # "SINGLE" | "ALL" | "LOWEST_HP"

# EQUIPMENT
var equip_stat: String
var equip_value: int        # Buff permanente até fim da batalha
```

### Schema Supabase (PostgreSQL)

```sql
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE,
  level INT DEFAULT 1,
  xp INT DEFAULT 0,
  currency_gold INT DEFAULT 0,
  currency_gems INT DEFAULT 0,
  pity_counter INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE player_fighters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id),
  fighter_id TEXT NOT NULL,
  level INT DEFAULT 1,
  obtained_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE player_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id),
  card_id TEXT NOT NULL,
  quantity INT DEFAULT 1,
  obtained_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE decks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id),
  name TEXT,
  formation TEXT,           -- "1-3-1" | "2-1-2" | "1-2-2"
  fighters JSONB,           -- Array de 4 fighter_ids com posições
  cards JSONB,              -- Array de até 20 card_ids
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE pve_progress (
  player_id UUID REFERENCES players(id),
  chapter INT,
  stage INT,
  stars INT,                -- 0-3 estrelas
  PRIMARY KEY (player_id, chapter, stage)
);

CREATE TABLE pvp_matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_a UUID REFERENCES players(id),
  player_b UUID REFERENCES players(id),
  winner UUID REFERENCES players(id),
  match_data JSONB,
  played_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 5. Motor de Batalha

### Loop de Turno

```
INÍCIO DO TURNO:
  PT_ATUAL = min(numero_do_turno, 10)   ← Rampa: começa em 1, sobe +1/turno
  Se mão < 5 cartas E deck não vazio → comprar 1 carta

FASE DE AÇÃO (ACTIVE_FIGHTER em destaque):
  1. Mostrar skills disponíveis com custo PT e cooldown restante
  2. FASE BOOST (opcional):
     └─ Jogador joga cartas da mão (Boost/Heal/Equip)
        Cada carta desconta seu pt_cost do PT_ATUAL
  3. FASE SKILL:
     ├─ Ataque básico (0 PT, sem CD) — sempre disponível
     └─ Skill escolhida (gasta PT, ativa CD)
        └─ Se boost ativo → dano amplificado

RESOLUÇÃO DE DANO:
  Ver seção 5.1

FIM DO TURNO:
  PT não usado é perdido
  Cooldowns de todas as skills decrementam -1
  Status effects decrementam duração
  Verifica condição de vitória
  Avança TurnQueue → próximo lutador
```

### 5.1 Fórmula de Dano

```
DANO_BASE = ATK_ATACANTE - DEF_DEFENSOR   (mínimo: 1)

MULT_TIPO:
  Vantagem    → × 1.5  (+ efeito especial de status)
  Neutro      → × 1.0
  Desvantagem → × 0.7

MULT_POSIÇÃO:  (aplicado por formação escolhida)
  Varia conforme formação (ver GDD_Jogo.md)

MULT_BOOST:
  Sem boost   → × 1.0
  Com boost   → × boost_value (ex: 1.8)

DANO_FINAL = DANO_BASE × MULT_TIPO × MULT_POSIÇÃO × MULT_BOOST
```

---

## 6. Pity System (Anti-Jogo de Azar)

```gdscript
func calculate_pull(pity_counter: int) -> String:
    var rates = { "MYTHIC": 0.015, "LEGENDARY": 0.10,
                  "RARE": 0.40,    "NORMAL": 0.485 }

    # Soft Pity: taxas sobem a partir do giro 60
    if pity_counter >= 60:
        var boost = (pity_counter - 59) * 0.06
        rates["MYTHIC"] += boost
        rates["NORMAL"] -= boost

    # Hard Pity: giro 80 garante Mítica do banner
    if pity_counter >= 80:
        return "MYTHIC"

    return _roll(rates)

# Regras:
# pity_counter persiste entre sessões (salvo no Supabase)
# pity_counter reseta ao ganhar uma Mítica
# Taxas exibidas na tela de banner (transparência obrigatória)
```

---

## 7. Roadmap

| Fase | Conteúdo | Status |
|:---|:---|:---|
| **1 — Fundação** | Setup Godot, Fighter/Card data, BattleEngine, TurnQueue, PT Manager, 3 formações | ⬜ A iniciar |
| **2 — Arte & UI** | Sprites lutadores, CardHand animada, layout de batalha, VFX de tipos | ⬜ |
| **3 — Meta-Game** | Deck Builder, Coleção, Supabase Auth + sync | ⬜ |
| **4 — Modos** | PvE campanha, Loot Box + Pity, PvP Realtime | ⬜ |
| **5 — Polimento** | Balanceamento, ranking, notificações, loja | ⬜ |

---

## 8. Arquitetura da Batalha (Core Loop)

O sistema de batalha foi arquitetado para separar completamente a Lógica (Core) da Apresentação (UI). Isso permite testar batalhas via código e facilitará a futura implementação do modo PvP.

### Arquivos Principais
*   **`BattleEngine.gd`**: O maestro do combate. Gerencia a máquina de estados (`BattleState`), aplica danos usando o `DamageCalculator`, interage com o `PTManager`, valida quem está vivo/morto e dita o ritmo chamando o próximo da fila.
*   **`TurnQueue.gd`**: Controla a ordem de ataque baseada na Agilidade (AGI). Se um personagem morre durante a rodada, a Engine avisa e ele é pulado nativamente. Ao final da rodada, as AGIs são recalculadas (levando em conta novos buffs/debuffs) e uma nova fila é montada.
*   **`Fighter.gd`**: Resource que guarda os atributos de cada lutador, suas skills e cuida da matemática de receber dano, descontar cooldowns e expirar status de turno em turno.
*   **`BattleHUD.gd`**: A casca visual. Escuta agressivamente os *sinais* (Signals) emitidos pelo `BattleEngine` (ex: `turn_started`, `damage_dealt`, `fighter_died`) e apenas reflete isso na tela. Ele é responsável por desenhar a barra de Ações Inferior (Skills/Attack), as animações de HP e exibir mensagens.

### Inteligência Artificial Inimiga (`EnemyAI.gd`)
Para o modo PvE, usamos um nó acoplado ao `BattleEngine` que automatiza o time adversário de forma limpa:
1.  **Escuta e Pausa:** Conectado ao `turn_started`, a IA percebe que é a vez de um monstro, dá uma "pausa dramática" (Timer) para respiro do jogador e processa a ação.
2.  **Seleção de Alvo (Heurística):** A IA varre o `player_fighters` (os heróis) e seleciona o alvo baseado em lógica. Atualmente, foca no aliado com o *menor percentual de HP* restante.
3.  **Seleção de Ação:** A IA confere o PT (Pontos de Turno). Tem 50% de chance de tentar usar uma magia especial (se o cooldown permitir). Se falhar ou não tiver PT, usa o ataque básico.
4.  **Integração Nativa:** Após pensar, ela chama `engine.use_skill(...)`, injetando a ação no mesmo fluxo que o jogador usaria.

### Transição para PvP Realtime
Como o `BattleHUD` apenas escuta sinais do `BattleEngine`, a transição para PvP será muito mais suave:
*   A `EnemyAI` é desligada.
*   Um novo script (`PvPBridge.gd`) será acoplado ao `BattleEngine`.
*   Quando for o turno do inimigo humano, o `BattleEngine` apenas "aguarda". O `PvPBridge` vai receber um JSON via Websocket do servidor (Supabase Realtime) dizendo *"O Jogador 2 usou a Skill X no Alvo Y"*. O `PvPBridge` então chama `engine.use_skill(...)` localmente, e o `BattleHUD` anima o golpe normalmente na sua tela!
