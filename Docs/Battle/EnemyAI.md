# Inteligência Artificial Inimiga (Enemy AI)

O cérebro dos oponentes está isolado em um script próprio chamado `EnemyAI.gd`. Este script escuta sinais passivos emitidos pela `BattleEngine` para interagir com a interface.

## Ciclo de Decisão (Decision Loop)

Quando a `BattleEngine` emite o sinal `turn_started` e identifica que o lutador ativo não pertence ao time do jogador:

1. **Verificação de Validade:** A IA confere se a batalha já não acabou ou se o inimigo não morreu repentinamente.
2. **Delay Dramático:** A rotina entra em um bloqueio intencional de **1.2 segundos** (`await get_tree().create_timer(1.2).timeout`). Isso serve para que a UI foque no inimigo, informando o jogador sobre quem irá atacar, construindo tensão e cadência para o combate.
3. **Decisão de Alvo:** O inimigo procura o alvo preferencial.
4. **Decisão de Habilidade:** O inimigo analisa seu próprio kit de habilidades (`Fighter.skills`) e decide qual usar.
5. **Execução:** O comando é enviado ao motor principal usando `engine.use_skill(...)`. Ao final do uso, a skill internamente chamará o `_end_turn()`, passando a vez.

---

## Comportamentos Específicos

### 1. Sistema de Mira (Targeting)
A IA implementada é considerada "Simples". A função `_choose_target` escaneia todos os alvos vivos e foca rigorosamente **aquele com a menor porcentagem de HP**.
- Porcentagem de HP = `HP Atual / HP Máximo`.
- Isso faz com que inimigos comportem-se de maneira focada (tentando "finalizar" aliados vulneráveis).
- Caso o alvo primário seja inválido (morra por efeito de campo durante a animação), a engine deve acionar o fallback para passar o turno.

### 2. Uso de Habilidades Especiais
Sempre que for a sua vez, o inimigo avalia as habilidades que possui prontas para uso (que não estejam em *Cooldown* - `CD`).
- O ataque básico (`_basic`) sempre é a opção de fallback e não possui *Cooldown*.
- Se o inimigo possui habilidades especiais válidas, há **50% de chance** dele usar uma das skills de forma aleatória, e **50% de chance** de usar apenas o ataque básico. Isso evita que os inimigos descarreguem todos os seus golpes fortes consecutivamente e de forma previsível.

---

## O Problema do PT (Ponto de Turno)

**Causa Raiz de um Bug Antigo:** O `EnemyAI` filtrava suas habilidades (`fighter.is_skill_available`) cruzando os dados da skill com a quantidade de PT atual (`engine.pt_manager.get_current()`). 
Entretanto, o Motor do Jogo (`BattleEngine`) foi programado para zerar o PT assim que a vez do jogador termina. O resultado colateral é que o inimigo lia seu PT como sempre sendo `0`, avaliando todas as suas magias custosas como inatingíveis. Consequentemente, o inimigo se resumia a **apenas utilizar ataques básicos**, inutilizando os ataques especiais do jogo.

**A Solução Técnica Adotada:** 
Foi decidido que os inimigos não competem e não utilizam as regras de Pontos de Turno do jogador, baseando o seu balanceamento apenas nos tempos de Recarga (Cooldowns). Para burlar a validação indevida, a IA passa um "PT Infinito" (`99`) ao consultar se tem recursos para castar a magia, driblando a limitação enquanto mantém a mecânica de recarga funcional.
