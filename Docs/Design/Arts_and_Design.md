# BattleFantasy — Arts & Design Guide

> Documento de referência para produção de assets visuais.
> Define o que precisa ser criado como arte externa (PNG) e o que é construído pelo motor do jogo (Godot).

---

## 1. Carta do Herói — Anatomia Visual

A carta é composta por **7 camadas** empilhadas de baixo para cima:

```
┌─────────────────────────────┐
│  ░░░ GLOW EXTERNO ░░░░░░░   │ ← Camada 7 (Shader no Godot)
│  ┌───────────────────────┐  │
│  │ [⚡]            [A]  │  │ ← Camada 6: Elemento + Rank
│  │                       │  │
│  │                       │  │
│  │    ARTE DO HERÓI      │  │ ← Camada 1: PNG externo
│  │                       │  │
│  │                       │  │
│  │  ★ ★ ★ ★ ★         │  │ ← Camada 5: Estrelas (Godot)
│  │  Kael - Lv 45         │  │ ← Camada 4: Nome + Level (Godot)
│  │  ████████░░░░  HP Bar │  │ ← Camada 3: Barra de HP (Godot)
│  │  HP: 980    ATK: 310  │  │ ← Camada 2: Stats (Godot)
│  └───────────────────────┘  │ ← Moldura/Frame: PNG externo
└─────────────────────────────┘
```

---

## 2. Assets Externos (PNG) — O Que Você Precisa Criar

### 2.1 Arte dos Heróis

| Item | Resolução | Formato | Fundo | Destino |
|------|-----------|---------|-------|---------|
| Kael (Thunder) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/kael.png` |
| Ignis (Fire) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/ignis.png` |
| Sapphira (Water) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/sapphira.png` |
| Frostia (Ice) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/frostia.png` |
| Azurath (Dragon) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/azurath.png` |
| Shadow (Dark) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/shadow_a.png` |
| Golem (Stone) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/stone_b.png` |
| Minder (Psychic) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/psycho_c.png` |
| Sylvan (Grass) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/grass_d.png` |
| Dark Lord (Dark) | 512×768 | PNG | Pode ter fundo temático | `res://assets/cards/fighters/dark_lord.png` |

**Dica para gerar com IA:** Use prompts como:
> "Anime-style RPG character portrait, full body, [descrição do personagem], dynamic pose, detailed outfit, vibrant colors, vertical composition, 512x768"

**Importante:** O nome do arquivo deve ser igual ao `id` do Fighter no código.

---

### 2.2 Molduras de Carta (1 por Raridade)

| Raridade | Resolução | Formato | Estilo Visual | Destino |
|----------|-----------|---------|---------------|---------|
| Normal | 512×768 | PNG + Alpha | Borda simples, cinza/prata | `res://assets/cards/frames/frame_normal.png` |
| Rare | 512×768 | PNG + Alpha | Borda azul/ciano com detalhes | `res://assets/cards/frames/frame_rare.png` |
| Legendary | 512×768 | PNG + Alpha | Borda dourada com ornamentos | `res://assets/cards/frames/frame_legendary.png` |
| Mythic | 512×768 | PNG + Alpha | Borda roxa com brilho, ornamentos ricos | `res://assets/cards/frames/frame_mythic.png` |

**Como criar:** A moldura é uma imagem com o **centro transparente** (para a arte do herói aparecer por baixo) e bordas ornamentais. Imagine um porta-retrato digital.

**Dica para gerar com IA:**
> "Game card frame border, ornamental fantasy design, [gold/blue/purple] color scheme, transparent center, rounded corners, 512x768, PNG with alpha transparency"

---

### 2.3 Ícones de Elemento (1 por Tipo)

| Elemento | Cor Dominante | Símbolo | Destino |
|----------|---------------|---------|---------|
| Fire | Vermelho/Laranja | Chama | `res://assets/icons/elements/fire.png` |
| Water | Azul | Gota d'água | `res://assets/icons/elements/water.png` |
| Thunder | Roxo/Amarelo | Raio | `res://assets/icons/elements/thunder.png` |
| Ice | Ciano/Branco | Floco de neve | `res://assets/icons/elements/ice.png` |
| Dragon | Dourado/Vermelho | Silhueta de dragão | `res://assets/icons/elements/dragon.png` |
| Dark | Roxo escuro | Lua/Crânio | `res://assets/icons/elements/dark.png` |
| Light | Dourado/Branco | Sol/Estrela | `res://assets/icons/elements/light.png` |
| Grass | Verde | Folha | `res://assets/icons/elements/grass.png` |
| Psychic | Rosa/Lilás | Olho/Onda mental | `res://assets/icons/elements/psychic.png` |
| Stone | Marrom/Cinza | Rocha/Montanha | `res://assets/icons/elements/stone.png` |
| Fighter | Vermelho/Cinza | Punho/Espada | `res://assets/icons/elements/fighter.png` |

**Resolução:** 128×128px, PNG com fundo transparente.

**Estilo:** Todos os ícones devem seguir o **mesmo estilo visual** (flat, gradiente, ou cel-shading). Consistência é fundamental.

**Dica para gerar com IA:**
> "Game UI icon, [element name] element, flat design style, circular badge, [dominant color] color scheme, transparent background, 128x128"

---

### 2.4 Background de Arena

| Arena | Resolução | Formato | Destino |
|-------|-----------|---------|---------|
| Arena Mística (padrão) | 1080×1920 | PNG ou JPG | `res://assets/arenas/mystic_arena.png` |
| Arena de Fogo (futura) | 1080×1920 | PNG ou JPG | `res://assets/arenas/fire_arena.png` |
| Arena de Gelo (futura) | 1080×1920 | PNG ou JPG | `res://assets/arenas/ice_arena.png` |

**Orientação:** Vertical (retrato), pois o jogo é mobile.

**Dica para gerar com IA:**
> "Fantasy battle arena background, dark mystical atmosphere, vertical mobile game format, 1080x1920, [theme description]"

---

## 3. O Que o Godot Faz (Sem PNG Necessário)

### 3.1 Badge de Rank

Círculo colorido com letra centralizada. Feito 100% por código.

| Rank | Cor do Fundo | Cor da Borda |
|------|-------------|--------------|
| D | Cinza `#666666` | Cinza escuro |
| C | Verde `#339933` | Verde escuro |
| B | Azul `#3366CC` | Azul escuro |
| A | Laranja `#CC6611` | Laranja escuro |
| S | Roxo `#CC33CC` | Roxo escuro |
| SS | Dourado `#E6B311` | Dourado escuro |
| SSS | Dourado brilhante `#FFD633` | Borda dupla dourada |

---

### 3.2 Estrelas

Caractere Unicode `★` com cor dourada (`#FFD700`), replicado N vezes num `HBoxContainer`.

| Estrelas | Visual |
|----------|--------|
| 1★ | ★ ☆ ☆ ☆ ☆ ☆ |
| 3★ | ★ ★ ★ ☆ ☆ ☆ |
| 5★ | ★ ★ ★ ★ ★ ☆ |
| 6★ | ★ ★ ★ ★ ★ ★ (com glow dourado) |

**Migração futura:** Substituir por PNG de estrela (64×64) quando disponível.

---

### 3.3 Barra de HP (Animada)

Construída no Godot com `ProgressBar` + `StyleBoxFlat`. Duas barras empilhadas:

| Camada | Função | Comportamento |
|--------|--------|---------------|
| Barra de fundo | HP perdido (vermelha) | Diminui **devagar** com tween (0.8s) |
| Barra da frente | HP atual (colorida) | Atualiza **instantaneamente** |

**Cores da barra conforme % de HP:**

| HP % | Cor |
|------|-----|
| > 50% | Verde `#33CC66` |
| 25% – 50% | Amarelo `#E6B311` |
| < 25% | Vermelho `#E63333` |

---

### 3.4 Glow Externo (Brilho da Carta)

Efeito de brilho ao redor da moldura. Feito via código com `modulate` ou Shader.

| Raridade | Cor do Glow | Intensidade |
|----------|------------|-------------|
| Normal | Nenhum | 0% |
| Rare | Ciano `#66CCFF` | Sutil, pulsa devagar |
| Legendary | Dourado `#FFD633` | Médio, pulsa |
| Mythic | Roxo `#CC66FF` | Intenso, pulsa + partículas |

---

### 3.5 Nome, Level e Stats

Texto dinâmico renderizado pelo Godot com a fonte do projeto.

| Campo | Formato | Exemplo |
|-------|---------|---------|
| Nome | `display_name` | KAEL |
| Level | `Lv {level}` | Lv 45 |
| HP | `HP: {hp}` | HP: 980 |
| ATK | `ATK: {atk_f}` | ATK: 310 |

---

## 4. Estrutura de Pastas Final

```
res://assets/
├── arenas/
│   ├── mystic_arena.png          ← 1080×1920
│   └── ...
├── cards/
│   ├── frames/
│   │   ├── frame_normal.png      ← 512×768, alpha
│   │   ├── frame_rare.png
│   │   ├── frame_legendary.png
│   │   └── frame_mythic.png
│   └── fighters/
│       ├── kael.png              ← 512×768
│       ├── ignis.png
│       ├── sapphira.png
│       ├── frostia.png
│       ├── azurath.png
│       ├── shadow_a.png
│       ├── stone_b.png
│       ├── psycho_c.png
│       ├── grass_d.png
│       └── dark_lord.png
└── icons/
    └── elements/
        ├── fire.png              ← 128×128, alpha
        ├── water.png
        ├── thunder.png
        ├── ice.png
        ├── dragon.png
        ├── dark.png
        ├── light.png
        ├── grass.png
        ├── psychic.png
        ├── stone.png
        └── fighter.png
```

---

## 5. Checklist de Produção

### Prioridade Alta (Necessário para o jogo funcionar visualmente)
- [ ] Arte do Kael — `kael.png` — 512×768 **(já existe)**
- [ ] Arte do Ignis — `ignis.png` — 512×768
- [ ] Arte do Sapphira — `sapphira.png` — 512×768
- [ ] Arte do Azurath — `azurath.png` — 512×768
- [ ] Arte do Frostia — `frostia.png` — 512×768
- [ ] Moldura Rare — `frame_rare.png` — 512×768 alpha
- [ ] Moldura Mythic — `frame_mythic.png` — 512×768 alpha
- [ ] Background de Arena — `mystic_arena.png` — 1080×1920

### Prioridade Média (Melhora a identidade visual)
- [ ] Ícone Fire — `fire.png` — 128×128 alpha
- [ ] Ícone Water — `water.png` — 128×128 alpha
- [ ] Ícone Thunder — `thunder.png` — 128×128 alpha
- [ ] Ícone Ice — `ice.png` — 128×128 alpha
- [ ] Ícone Dragon — `dragon.png` — 128×128 alpha
- [ ] Ícone Dark — `dark.png` — 128×128 alpha
- [ ] Ícone Light — `light.png` — 128×128 alpha
- [ ] Moldura Normal — `frame_normal.png` — 512×768 alpha
- [ ] Moldura Legendary — `frame_legendary.png` — 512×768 alpha

### Prioridade Baixa (Polimento futuro)
- [ ] Ícone Grass — `grass.png` — 128×128 alpha
- [ ] Ícone Psychic — `psychic.png` — 128×128 alpha
- [ ] Ícone Stone — `stone.png` — 128×128 alpha
- [ ] Ícone Fighter — `fighter.png` — 128×128 alpha
- [ ] Estrela PNG — `star.png` — 64×64 alpha
- [ ] Artes dos inimigos (shadow_a, stone_b, psycho_c, grass_d, dark_lord)
- [ ] Arenas temáticas adicionais

---

## 6. Evolução Visual (Roadmap)

### Fase Atual: Tier 1 — Moldura por Raridade
- 1 arte por herói
- Moldura muda conforme raridade (Normal → Rare → Legendary → Mythic)
- Glow muda de cor e intensidade

### Futuro: Tier 2 — Artes por Evolução
- 2-3 artes por herói (base, evoluído, desperto)
- Nomenclatura: `kael.png`, `kael_evolved.png`, `kael_awakened.png`
- O código seleciona a arte baseado no campo `evolution_stage` do Fighter

### Futuro: Tier 3 — Skins
- N artes por herói (temáticas, sazonais)
- Nomenclatura: `kael_summer.png`, `kael_halloween.png`
- Sistema de seleção no menu de personagem
