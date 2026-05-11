# Fluxo de Batalha (Battle Flow)

A batalha no **BattleFantasy** é gerenciada centralmente pelo `BattleEngine.gd`, que atua como o orquestrador (State Machine) unindo todos os sub-sistemas do combate.

## Arquitetura Geral

O `BattleEngine` gerencia quatro componentes principais:
1. **TurnQueue**: Fila de prioridade de turnos (quem ataca primeiro).
2. **PTManager**: Gerenciador dos Pontos de Turno (mana/energia).
3. **DamageCalculator**: Motor de cálculo de dano, mitigação, tipos elementais e bônus de formação.
4. **EnemyAI**: O cérebro automatizado que controla os lutadores inimigos.

### Estados da Batalha (`BattleState`)
- `IDLE`: Aguardando o início.
- `PLAYER_TURN`: Vez de um personagem do jogador agir. As interfaces (`BattleHUD`) são liberadas.
- `ENEMY_TURN`: Vez de um inimigo. A UI é bloqueada e a `EnemyAI` entra em ação.
- `RESOLVING`: Estado transitório onde a animação e o cálculo de um ataque/cura estão sendo processados.
- `VICTORY`, `DEFEAT`, `DRAW`: Estados finais após a checagem de morte de um ou ambos os times.

---

## 1. Fila de Turnos (`TurnQueue.gd`)

A `TurnQueue` é recriada do zero no início de cada **Rodada** (Round). 
- Uma Rodada termina quando todos os lutadores vivos tiverem agido 1 vez.
- **Ordenação:** Os lutadores (jogadores e inimigos misturados) são ordenados pelo atributo de **Agilidade Efetiva (`AGI`)**, de forma decrescente.
- **Desempate:** Em caso de mesma AGI, o lutador com índice de posição menor age primeiro (Ex: o líder na posição 0 age antes da retaguarda na posição 4).
- Efeitos de status que alteram a AGI (como `FREEZE`) são avaliados em tempo real quando a fila é construída, garantindo que o debuff impacte imediatamente a rodada subsequente.

---

## 2. Gerenciamento de Recursos (`PTManager.gd`)

Os Pontos de Turno (PT) funcionam como a "Mana" usada para conjurar cartas ou habilidades especiais.

- **Rampa de Turnos:** Começa em 1 PT no Turno 1 e aumenta +1 a cada turno que passa (até o máximo global de 10).
- **Zerar e Restaurar:** Todo o PT não utilizado é perdido no final do turno do jogador. No início do próximo turno do jogador, a reserva retorna ao seu novo limite máximo (baseado no contador de rodada + bônus permanentes).
- **Importante:** O inimigo *não consome* o PT global para usar habilidades no design atual. A reserva de PT é estritamente estratégica para o Jogador usar em Suportes (Cards) e nas Habilidades dos seus próprios lutadores.

---

## 3. Resolução de Combate (`DamageCalculator.gd`)

Quando um ataque é despachado, a fórmula matemática é resolvida em 3 camadas:

1. **Dano Base Fixo**
   - Dependendo do tipo do ataque (`PHYSICAL` ou `SPECIAL`), é selecionado o status ofensivo do Atacante (`ATK_F` ou `ATK_S`) e o status defensivo do Defensor (`DEF_F` ou `DEF_S`).
   - `Dano Base = MAX(1, (Atributo Ofensivo * Poder da Skill) - Atributo Defensivo)`
2. **Multiplicador de Formação**
   - Baseado na string de formação atual (Ex: `1-3-1`, `2-1-2`), os lutadores ganham bônus passivos multiplicativos baseados na sua `position` (índice 0 a 4). 
   - A Vanguarda costuma ter penalidade de dano (0.85x a 0.75x) o que funciona como se eles tivessem muita Defesa.
3. **Vantagem de Tipo e Boosts**
   - Os tipos (`FIRE`, `WATER`, `GRASS`, `LIGHT`, `DARK` etc.) dão 1.5x (`ADVANTAGE`) ou 0.7x (`WEAKNESS`) no dano.
   - Vantagens ativam *Status Effects* garantidos. Ex: `FIRE` contra `GRASS` aplica garantidamente o debuff `BURN`.

---

## 4. Estudo das Falhas Catalogadas (Bugs)

Durante nossa primeira revisão arquitetural, encontramos os seguintes "Buracos Negros" que causavam *soft-lock* (o jogo ficava travado esperando):

- **Falta de Função de Encerramento (Skip):** Se um inimigo ou jogador ficasse sem opções viáveis (ex: todos os alvos morreram antes da vez de agir devido a dano contínuo de status), a rotina não prosseguia para a próxima vez. Solução necessária: Função explícita `skip_turn()` / `end_turn()`.
- **Status Ticking Assíncrono:** Os debuffs (veneno, queimadura) fazem dano no `_end_turn()`. Mas a IA inimiga verificava mortes e retornava cedo (*early return*) caso não houvesse alvo, *sem finalizar o turno corrente*, congelando a `BattleEngine`.
