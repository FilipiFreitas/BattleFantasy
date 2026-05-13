# Sistema de Save e Persistência (Rule 16)

Este documento descreve como o BattleFantasy gerencia o progresso dos heróis e evita trapaças simples.

## 1. Templates vs. Instâncias
*   **Templates (Blueprint)**: Localizados em `res://data/heroes/`. São arquivos `.tres` estáticos que servem como "molde" inicial (Nível 1). Nunca devem ser alterados durante o gameplay.
*   **Instâncias (Player Heroes)**: Quando o jogador obtém um herói, o jogo carrega o Template e chama o método `.duplicate()`. Esta cópia única é a que ganha XP e sobe de nível.

## 2. Dinâmica de Nível e Atributos
*   Os atributos **não são salvos diretamente**.
*   O que salvamos é o **Level** atual do herói.
*   Ao carregar o herói, a classe `Character.gd` usa a fórmula de **Crescimento Dinâmico**:
    `Atributo Final = Base (Lv 1) + (Crescimento * (Level - 1))`

## 3. Segurança Anti-Cheat
Para evitar que jogadores editem os arquivos de save no Bloco de Notas:
*   **Criptografia**: Utilizar `FileAccess.open_encrypted_with_pass()` para tornar o arquivo ilegível fora do jogo.
*   **Checksum (Hashing)**: Salvar uma assinatura digital do conteúdo. Se o arquivo for editado manualmente, a assinatura não baterá e o jogo detectará a alteração.

## 4. Localização dos Saves
Os saves do jogador devem ser armazenados na pasta padrão do usuário:
`user://saves/player_collection.json` ou `.res`.
