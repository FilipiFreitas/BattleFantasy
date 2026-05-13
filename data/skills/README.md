# Guia de Criação de Habilidades (Sistema LEGO)

Esta pasta contém as definições de habilidades do jogo. Elas utilizam uma arquitetura modular baseada em **Resources** do Godot.

## Como funciona?

Seguindo a **Rule 15**, as habilidades não são scripts fixos, mas sim composições de blocos menores:

1.  **SkillResource**: O container principal que define o nome, ícone e descrição.
2.  **Targeter**: Define QUEM será atingido (Alvo Único, Área, Aliados, Inimigos).
3.  **Effects**: Uma lista de QUEM faz o quê (Dano, Cura, Status, etc.).

---

## Anatomia de um arquivo .tres (Exemplo: PoisonArrow)

```gdresource
# 1. DEPENDÊNCIAS: Carrega os scripts (formas do LEGO)
[ext_resource type="Script" path="res://src/core/skills/effects/DamageEffect.gd" id="1_dmg"]
[ext_resource type="Script" path="res://src/core/skills/targeters/SingleEnemyTargeter.gd" id="2_target"]

# 2. SUB-RESOURCES: Configura as peças (valores específicos)
[sub_resource type="Resource" id="Resource_1"]
script = ExtResource("1_dmg")
damage_value = 10  <-- Mude o dano aqui no Inspector

# 3. RESOURCE PRINCIPAL: Une as peças em uma skill funcional
[resource]
script = ExtResource("4_skill")
skill_name = "Flecha Venenosa"
targeter = SubResource("Resource_targeter")
effects = [SubResource("Resource_1"), ...]
```

## Como criar uma nova habilidade no Editor:

1.  Clique com o botão direito na pasta `data/skills/` -> **New Resource**.
2.  Escolha o tipo **SkillResource**.
3.  No Inspector:
    -   Dê um nome e descrição.
    -   Em `Targeter`, escolha um dos scripts da pasta `src/core/skills/targeters/`.
    -   Em `Effects`, clique em **Add Element** e arraste um dos scripts da pasta `src/core/skills/effects/`.
    -   Configure os valores (Dano, Cura, etc.) que aparecerão no Inspector.

---
**Documentação gerada conforme as Regras de Arquitetura do Projeto.**
