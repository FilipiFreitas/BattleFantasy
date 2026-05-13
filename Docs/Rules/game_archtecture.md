# Game Architecture Rules — Godot Project

## Filosofia Geral

O objetivo dessa arquitetura é:

* Escalar sem virar spaghetti
* Facilitar expansão de conteúdo
* Reduzir acoplamento
* Maximizar reutilização
* Favorecer composição
* Tornar sistemas previsíveis e fáceis de manter
* Permitir iteração rápida

---

# Rule 1 — Dados definem comportamento

Evite criar uma classe para cada variação.

Ruim:

```text
FireMage.gd
IceMage.gd
ThunderMage.gd
```

Prefira:

```text
Character
 + Stats
 + Skills
 + Tags
 + Effects
```

As skills e comportamentos devem ser configurados por dados.

Exemplo:

```json
{
  "name": "Fireball",
  "damage": 50,
  "element": "fire",
  "radius": 3,
  "effects": ["burn"]
}
```

Objetivo:

* Criar conteúdo sem criar código novo
* Tornar sistemas data-driven
* Facilitar balanceamento

---

# Rule 2 — Composição > Herança

Evite árvores profundas de herança.

Ruim:

```text
Enemy
 ├── FlyingEnemy
      ├── FireFlyingEnemy
```

Prefira:

```text
Enemy
 + CanFly
 + FireResistance
 + DashAttack
 + RangedAI
```

No Godot isso funciona naturalmente usando:

* Nodes
* Resources
* Signals
* Components

Objetivo:

* Flexibilidade
* Reutilização
* Menos dependência estrutural

---

# Rule 3 — Skill não conhece diretamente o alvo

Evite:

```gdscript
if enemy:
   enemy.hp -= 50
```

Prefira:

```gdscript
target.apply_effect(effect)
```

Ou:

```gdscript
effect.execute(target)
```

Objetivo:

* Separar skill de implementação do alvo
* Facilitar resistências, imunidades e modificadores
* Tornar efeitos reutilizáveis

---

# Rule 4 — Tudo importante vira sistema

Não deixar mecânicas críticas espalhadas.

Criar sistemas específicos para:

* DamageSystem
* EffectSystem
* CooldownSystem
* StatSystem
* TargetingSystem
* LootSystem
* BuffSystem

Objetivo:

* Centralizar regras
* Facilitar debug
* Evitar lógica duplicada

---

# Rule 5 — Use Tags ao invés de IFs específicos

Evite:

```gdscript
if enemy.is_undead:
```

Prefira:

```gdscript
if target.has_tag("undead"):
```

Ou:

```gdscript
effect.required_tags = ["organic"]
```

Objetivo:

* Escalabilidade
* Flexibilidade
* Menos código rígido

---

# Rule 6 — Effects são comandos isolados

A skill não deve fazer tudo.

Estrutura:

```text
Skill
 ├── DamageEffect
 ├── KnockbackEffect
 ├── BurnEffect
 └── CameraShakeEffect
```

Cada effect deve ser:

* Pequeno
* Independente
* Reutilizável
* Testável

Objetivo:

* Construção modular de gameplay
* Reuso massivo de lógica

---

# Rule 7 — Visual separado da lógica

Evite misturar:

* dano
* VFX
* SFX
* animações
* câmera

Ruim:

```gdscript
spawn_fireball()
deal_damage()
play_sound()
camera_shake()
```

Prefira:

```text
SkillLogic
 + VFX
 + SFX
 + Animation
```

A lógica deve emitir eventos:

```gdscript
signal skill_activated
signal hit_confirmed
signal target_killed
```

Objetivo:

* Menos acoplamento
* Facilidade de manutenção
* Troca simples de feedback visual

---

# Rule 8 — Resources são assets de gameplay

Use Resources para:

* Skills
* Status
* Itens
* Cartas
* Enemies
* Loot tables
* Upgrades
* Configurações

Vantagens:

* Editor-friendly
* Reutilização
* Serialização simples
* Arquitetura data-driven

---

# Rule 9 — Nodes pequenos e especializados

Evite:

```text
Player.gd (4000 linhas)
```

Prefira:

```text
Player
 ├── MovementComponent
 ├── CombatComponent
 ├── AnimationComponent
 ├── HealthComponent
 └── InventoryComponent
```

Objetivo:

* Separação de responsabilidades
* Melhor manutenção
* Facilitar testes

---

# Rule 10 — Event-driven architecture

Use signals como comunicação principal.

Evite:

```gdscript
ui.update_hp()
quest.check()
audio.play()
```

Prefira:

```gdscript
signal hp_changed
```

E sistemas escutam esse evento.

Objetivo:

* Reduzir dependências
* Facilitar expansão
* Melhor desacoplamento

---

# Rule 11 — Gameplay primeiro, visual depois

Prioridade inicial:

1. Mecânica
2. Feedback
3. Balanceamento
4. Visual final

Primeiro:

* hitbox
* timing
* movimentação
* sensação do combate

Depois:

* partículas
* shaders
* polish

Objetivo:

* Iteração rápida
* Descobrir diversão cedo
* Evitar retrabalho visual

---

# Rule 12 — Pense em pipelines

Evite:

```text
Skill faz tudo
```

Prefira:

```text
Input
 → Validation
 → Targeting
 → Effects
 → Result
 → Events
```

Objetivo:

* Fluxo previsível
* Melhor debug
* Facilidade de expansão

---

# Rule 13 — Estado explícito

Evite:

```gdscript
if attacking and stunned and casting:
```

Prefira:

* FSM
* State Pattern
* Gameplay Tags
* Action States

Objetivo:

* Evitar estados inválidos
* Melhor previsibilidade
* Facilitar debug

---

# Rule 14 — Ferramentas internas aceleram produção

Criar cedo:

* Skill editor
* Debug overlay
* Hitbox visualizer
* Damage preview
* Wave editor
* Loot editor
* Spawn visualizer

Objetivo:

* Iteração mais rápida
* Menos erros
* Melhor produtividade

---

# Rule 15 — Sistemas devem funcionar como LEGO

Evite criar classes específicas demais.

Ruim:

```text
PoisonHomingSplitProjectile.gd
```

Prefira:

```text
Projectile
 + HomingModifier
 + PoisonEffect
 + SplitOnHit
```

Objetivo:

* Combinação infinita de comportamentos
* Escalabilidade massiva
* Reuso extremo

---

# Estrutura Recomendada

```text
Game
 ├── Systems
 │    ├── DamageSystem
 │    ├── EffectSystem
 │    ├── CombatSystem
 │    ├── LootSystem
 │    └── TargetingSystem
 │
 ├── Entities
 │    ├── Player
 │    ├── Enemy
 │    └── NPC
 │
 ├── Components
 │    ├── HealthComponent
 │    ├── MovementComponent
 │    ├── InventoryComponent
 │    └── CombatComponent
 │
 ├── Resources
 │    ├── Skills
 │    ├── Items
 │    ├── Effects
 │    └── Configs
 │
 ├── UI
 │
 ├── VFX
 │
 └── Audio
```

---

# Mentalidade Final

O objetivo não é criar um sistema complicado.

O objetivo é:

* Criar sistemas pequenos
* Independentes
* Combináveis
* Reutilizáveis
* Data-driven

Quanto mais o projeto cresce:

* mais essa arquitetura compensa
* mais rápido fica criar conteúdo
* menos o projeto degrada
* menor a chance de virar caos estrutural

A arquitetura deve permitir:

* adicionar conteúdo rapidamente
* modificar comportamento sem quebrar sistemas
* testar features isoladamente
* escalar o jogo sem reescrever a base
