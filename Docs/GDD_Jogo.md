# ⚔️ BattleFantasy — Game Design Document (GDD)

> **Versão:** 1.0 | **Data:** 2026-05-11
> **Status:** Regras base definidas — pronto para prototipagem
> **Estilo Visual:** Anime / JRPG Mobile (Fate Grand Order, Seven Deadly Sins Grand Cross)

---

## 1. Conceito do Jogo

**BattleFantasy** é um Card-RPG por turnos onde dois jogadores enfrentam um ao outro (PvP) ou desafiam estágios de campanha (PvE) com times de **4 lutadores** e decks de **20 cartas de suporte** (selecionadas de uma coleção de 100 cartas).

### Pilares de Design

| Pilar | Descrição |
|:---|:---|
| **Posicionamento** | A formação escolhida define bônus e penalidades táticas |
| **Deck como tática** | As cartas na mão (Boost/Heal/Equip) amplificam os lutadores — não são unidades |
| **Economia de PT** | Pontos de Turno crescem em rampa, forçando decisões de timing |
| **Profundidade de tipos** | 12 tipos com vantagens/desvantagens e efeitos de status únicos |

---

## 2. Estrutura de um Lutador (Fighter Card)

Todo lutador possui os seguintes atributos base:

| Atributo | Sigla | Função |
|:---|:---|:---|
| Health Points | **HP** | Pontos de vida. Ao chegar a 0 o lutador é eliminado. |
| Ataque Físico | **ATK F** | Dano base para habilidades de contato físico |
| Defesa Física | **DEF F** | Redução de dano de ataques físicos recebidos |
| Ataque Especial | **ATK S** | Dano base para habilidades elementais/mágicas |
| Defesa Especial | **DEF S** | Redução de dano de ataques especiais recebidos |
| Agilidade | **AGI** | Define a ordem de ataque na fila de turnos (maior AGI age primeiro) |

---

## 3. Sistema de Raridades

As raridades definem o teto de status do lutador e a complexidade de suas habilidades:

| Raridade | Borda da Carta | Habilidades | Diferencial |
|:---|:---|:---|:---|
| **Normal** | Prata simples | 1 elemental + Ataque básico | Entrada acessível |
| **Rara** | Azul com ornamentos | 2 elementais | Stats superiores |
| **Lendária** | Dourada com runas | 3 elementais + **Passiva Única** | Identidade estratégica forte |
| **Mítica** | Holográfica rainbow | 3+ elementais + **Habilidade de Liderança** | Carta âncora do time; ataques com efeito global |

### Habilidade de Liderança (exclusiva de Míticas)
Ativada automaticamente quando o lutador Mítico está posicionado na **Vanguarda (posição líder)**. Concede bônus passivo para todo o time enquanto ele estiver vivo.

### Habilidade Passiva (Lendária+)
Efeito permanente durante toda a batalha, independente de posição.

---

## 4. Sistema de Tipos

> Os tipos representam a **natureza/arquétipo** do personagem — não são puramente elementais.
> Um personagem do Tipo Dragão pode usar fogo, mas **é** um Dragão. Funciona como a tipagem do Pokémon.

| Tipo | Ícone | Forte Contra | Efeito de Vantagem |
|:---|:---|:---|:---|
| **Fogo** | 🔥 | Grama, Gelo | **Queimadura** — dano contínuo por 2 turnos |
| **Água** | 💧 | Fogo, Terra | **Extinguir** — reduz ATK S do alvo por 2 turnos |
| **Terra** | 🪨 | Raio, Pedra | **Imunidade** — bloqueia próximo efeito de controle (stun/lento) |
| **Raio** | ⚡ | Água, Lutador | **Sobrecarga** — 30% de chance de +1 CD no alvo |
| **Gelo** | ❄️ | Dragão, Grama | **Congelar** — reduz AGI do alvo em 50% por 1 turno |
| **Psíquico** | 🔮 | Lutador, Luz | **Confusão** — 25% de chance de o alvo atacar um aliado aleatório |
| **Luz** | ☀️ | Escuridão, Raio | **Purificação** — remove todos os buffs do inimigo ao atacar |
| **Escuridão** | 🌑 | Psíquico, Luz | **Dreno** — 20% do dano causado é convertido em HP do atacante |
| **Dragão** | 🐉 | Gelo, *(a definir)* | *(a definir)* |
| **Lutador** | 👊 | *(a definir)* | *(a definir)* |
| **Pedra** | 🗿 | *(a definir)* | *(a definir)* |
| **12º Tipo** | ❓ | *(a definir)* | *(a definir)* |

**Regras de tipo:**
- Multiplicador de vantagem: **×1.5 dano + efeito especial**
- Multiplicador neutro: **×1.0 dano**
- Multiplicador de desvantagem: **×0.7 dano**
- Um lutador pode ter apenas 1 tipo
- Cartas de Boost com tipo específico dão bônus adicional ao amplificar lutadores do mesmo tipo

### 4.1 Cálculo de Dano
O dano é calculado com base no **Ataque (Físico ou Especial)** do atacante menos a **Defesa** correspondente do defensor.

**Fórmula Base:** `(Atk × Poder da Skill) - Defesa`

**Regras de Resolução:**
1.  **Dano Mínimo Garantido:** O dano base nunca será inferior a **5% do Ataque** do lutador.
2.  **Mecânica de "Erro Crítico":** Se a Defesa for superior ao ataque (levando o dano para o mínimo), há uma chance de o golpe ser inefetivo, resultando em apenas **1 de dano**.
	*   A chance de erro escala conforme a superioridade da Defesa, até o máximo de **35%**.
3.  **Multiplicadores Finais:** Após o cálculo base, aplicam-se os multiplicadores de **Vantagem de Tipo**, **Bônus de Formação** e **Cartas de Boost**.

---

## 5. Formações

O jogador escolhe a formação **antes de cada batalha**. A formação é revelada ao oponente no início da partida (criando meta-jogo de contra-formação).

### Diagrama das Formações (Padrão 1-2-1)

```
	  [ F4 ]          (Retaguarda / Suporte)
   [ F2 ][ F3 ]       (Meio / Ofensiva)
	  [ F1 ]          (Vanguarda / Líder)
```

### Bônus por Formação (1-2-1)

| Posição | Bônus |
|:---|:---|
| **Vanguarda (F1 — Líder)** | Ativa Liderança. -20% dano recebido. |
| **Meio Esq (F2)** | +10% ATK F |
| **Meio Dir (F3)** | +10% ATK S |
| **Retaguarda (F4)** | +15% AGI |

---

## 6. Sistema de Turnos

### Ordem de Ação (TurnQueue)
- No início de cada **rodada**, todos os 8 lutadores ativos (4 por time) são ordenados por **AGI** (decrescente)
- O lutador com maior AGI age primeiro
- Em caso de empate, desempate por: posição de formação > time do jogador 1
- A fila é **recalculada** a cada nova rodada (efeitos de Gelo/debuffs de AGI impactam a ordem)

### Fila Visual
```
FILA DE TURNOS (exemplo):
[ Ignis 130 ] [ Azurath 195 ] [ Opp_A 145 ] [ Kai 110 ] [ Opp_B 155 ] ...
	 ↑ ATIVO
```

---

## 7. Pontos de Turno (PT) — O Sistema de Mana

### Sistema de Rampa (inspirado em Hearthstone)

| Turno | PT Disponível |
|:---|:---|
| 1 | 1 PT |
| 2 | 2 PT |
| 3 | 3 PT |
| ... | ... |
| 10+ | 10 PT (máximo) |

**Regras:**
- PT **não acumula** entre turnos — o que não for usado é perdido
- Mecânicas especiais (habilidades passivas, cartas específicas) podem dar **+1 PT/turno** permanente
- O ataque básico **sempre custa 0 PT** e não tem cooldown

---

## 8. Cartas do Deck (Mão do Jogador)

### Visão Geral

```
DECK EQUIPADO: 20 cartas  →  COLEÇÃO: 100 cartas  →  MÃO: máx. 5 cartas
```

**Mecânica da mão:**
- Começa a batalha com **3 cartas** na mão (mão inicial reduzida pelo deck menor)
- A cada novo turno compra **1 carta** do deck (se mão < 5)
- Se a mão já tiver 5 cartas, **não compra** naquele turno
- Se o deck acabar, **não há penalidade** — simplesmente não compra mais

### 8.1 Cartas de Boost

Amplificam a próxima skill do lutador ativo do turno.

| Exemplo | Tipo Alvo | Efeito | Custo PT |
|:---|:---|:---|:---|
| Chama Ardente | FIRE | +80% dano na próxima skill de Fogo | 2 PT |
| Amplificação Dragão | DRAGON | +60% ATK S na próxima skill | 2 PT |
| Impulso Universal | ANY | +30% dano na próxima skill (qualquer tipo) | 1 PT |
| Fúria das Trevas | DARK | +100% dano + aplica Dreno | 3 PT |

**Regras de Boost:**
- Boost com tipo específico: bônus de +20% adicional se o lutador for do mesmo tipo
- Múltiplos boosts podem ser jogados no mesmo turno (se PT permitir)
- Boost expira ao final do turno se não for usado

### 8.2 Cartas de Heal (Cura)

| Exemplo | Alvo | Efeito | Custo PT |
|:---|:---|:---|:---|
| Cura Sagrada | SINGLE | Restaura 400 HP em 1 lutador | 2 PT |
| Bênção de Luz | ALL | Restaura 150 HP para todos os aliados | 3 PT |
| Emergência | LOWEST_HP | Restaura 600 HP no lutador com menos HP | 2 PT |
| Cura Drenante | SINGLE | Restaura 300 HP aliado + drena 150 HP do inimigo mais fraco | 3 PT |

### 8.3 Cartas de Equipamento

Buff permanente até o fim da batalha.

| Exemplo | Atributo | Efeito | Custo PT |
|:---|:---|:---|:---|
| Espada de Dragão | ATK F | +40 ATK F permanente | 2 PT |
| Escudo Rúnico | DEF F | +35 DEF F permanente | 2 PT |
| Cristal Psíquico | ATK S | +30 ATK S permanente | 2 PT |
| Amuleto da Velocidade | AGI | +20 AGI permanente | 1 PT |
| Armadura do Herói | DEF F + DEF S | +20 DEF F e +20 DEF S | 3 PT |

---

## 9. Habilidades dos Lutadores (Built-in Skills)

As habilidades são intrínsecas ao lutador — **não vêm do deck**.

### Estrutura de uma Skill
```
{
  "id": "ignis_flame_wave",
  "name": "Flame Wave",
  "pt_cost": 2,
  "cd": 3,           ← Cooldown em turnos (0 = sem cooldown)
  "type": "FIRE",
  "power": 1.4,      ← Multiplicador de ATK S
  "aoe": "SINGLE",   ← Padrão de área
  "status": { "type": "BURN", "turns": 2, "value": 50 }
}
```

### Padrões de AoE

| Padrão | Alvos | Disponibilidade |
|:---|:---|:---|
| **Individual** | 1 alvo escolhido | Todos |
| **Em Linha** | Vanguarda + Retaguarda | Rara+ |
| **Em Cruz** | Alvo + adjacentes na formação | Lendária+ |
| **Total** | Todos os 5 lutadores inimigos | Exclusivo Míticas (CD alto: 4-5) |

### Cooldown
- Habilidades básicas: **CD 0** (sempre disponíveis se tiver PT)
- Habilidades medianas: **CD 2-3**
- Habilidades poderosas: **CD 4-5**
- O efeito de **Sobrecarga (Raio)** adiciona **+1 CD** temporariamente

---

## 10. Efeitos de Status

| Status | Origem | Efeito | Duração |
|:---|:---|:---|:---|
| **Queimadura** | Tipo Fogo | Dano fixo por turno (50-150 HP) | 2 turnos |
| **Congelar** | Tipo Gelo | AGI reduzida em 50% | 1 turno |
| **Sobrecarga** | Tipo Raio | +1 CD em uma skill aleatória | Instantâneo |
| **Confusão** | Tipo Psíquico | 25% chance de atacar aliado | 2 turnos |
| **Imunidade** | Tipo Terra | Bloqueia próximo efeito de controle | Até ser ativado |
| **Dreno Ativo** | Tipo Escuridão | Atacante recupera 20% do dano causado | Por ataque |
| **Extinto** | Tipo Água | ATK S reduzido (valor a definir) | 2 turnos |
| **Purificado** | Tipo Luz | Remove todos os buffs do alvo | Instantâneo |

---

## 11. Cartas de Campo (Support Especial)

Cartas de campo **alteram o cenário global** por N turnos. Afetam **ambos os times**.

| Exemplo | Efeito | Duração |
|:---|:---|:---|
| Campo de Névoa | Todos os ataques físicos têm 20% de chance de errar | 3 turnos |
| Tempestade Elétrica | Todas as habilidades do tipo Raio custam -1 PT | 4 turnos |
| Chuva Sagrada | Todos os lutadores recuperam 80 HP por turno | 3 turnos |
| Eclipse | Habilidades de Escuridão têm vantagem contra TODOS os tipos | 2 turnos |

---

## 12. Modos de Jogo

### 12.1 PvE — Campanha

- Mapa de **Capítulos e Estágios** (ex: 10 capítulos × 10 estágios)
- Dificuldade progressiva
- Recompensas por estágio: ouro, XP, cartas específicas
- Sistema de **Estrelas** (0-3) por missão:
  - ⭐ Completar sem lutadores mortos
  - ⭐⭐ Completar em até X turnos
  - ⭐⭐⭐ Completar ambas as condições
- Estágios de chefe com mecânicas únicas (buff especial do inimigo, etc.)

### 12.2 PvP — Online

- **Matchmaking** por ranking (Elo-like)
- Batalha em tempo real via Supabase Realtime
- Turno com **limite de tempo** (ex: 45s por decisão)
- Recompensas: gemas, fragmentos de cartas, subida de ranking
- Temporadas semanais/mensais com recompensas exclusivas

---

## 13. Sistema de Progressão e Deck

### Deck de Cartas

| Regra | Detalhe |
|:---|:---|
| **Tamanho do deck equipado** | 20 cartas fixo |
| **Total da Coleção** | 100 cartas |
| **Cópias permitidas** | Máximo 3 cópias da mesma carta |
| **Composição livre** | Mix de Boost, Heal e Equipamento à escolha |
| **Expansão do deck** | Possível via itens especiais (ex: "Slot Extra") |
| **Deck obrigatório** | Não pode entrar em batalha com menos de 30 cartas |

### Time de Lutadores

| Regra | Detalhe |
|:---|:---|
| **Lutadores por time** | 4 (fixo) |
| **Formação** | Escolhida antes de cada batalha |
| **Mesmo lutador** | Apenas 1 cópia por time |

---

## 14. Sistema de Loot Box e Pity

### Banner

Cada banner apresenta uma carta ou lutador **destaque** com taxas aumentadas.

| Raridade | Taxa Base |
|:---|:---|
| **Mítica** | 1.5% |
| **Lendária** | 10.0% |
| **Rara** | 40.0% |
| **Normal** | 48.5% |

### Pity System (Anti-Jogo de Azar)

| Mecanismo | Detalhe |
|:---|:---|
| **Soft Pity** | A partir do giro 60: taxa Mítica sobe +6% a cada giro adicional |
| **Hard Pity** | Giro 80: carta Mítica do banner garantida |
| **Persistência** | Contador de pity **não reseta** ao fechar o jogo |
| **Reset** | Contador reseta apenas ao **obter uma Mítica** |
| **Transparência** | Taxas de todas as cartas exibidas na tela do banner |

### Fontes de Giros (Moedas)
- **Gemas** (moeda premium, obtida por PvP ranking, eventos, loja)
- **Fragmentos de Banner** (obtidos em PvE, acumulados para 1 giro)
- **Giro diário gratuito** (1 por dia, máximo Normal/Rara)

---

## 15. Referências de Design

| Referência | O que inspirou |
|:---|:---|
| **Hearthstone** | Sistema de Mana Ramp (PT começa em 1, +1/turno) |
| **Fate Grand Order** | Qualidade de arte das cartas e lutadores |
| **Seven Deadly Sins Grand Cross** | UI de batalha mobile, animações |
| **Pokémon** | Sistema de tipos como arquétipo (não puramente elemental) |
| **Legends of Runeterra** | Separação entre campeões (lutadores) e spells (boost cards) |
| **Slay the Spire** | Deck building como mecânica tática central |
