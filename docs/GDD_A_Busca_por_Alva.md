# GDD Base: A Busca por Alva
## 1. Visão Geral e Conceito Central
 * **Título:** A Busca por Alva
 * **Gênero:** RPG 2D *Top-down* Clássico (estilo Pokémon/Zelda de GBA).
 * **Temática:** A jornada da luz às trevas, sacrifício e o poder da conexão silenciosa.
 * **Resumo:** O Herói viaja do seu reino pacífico em direção ao corrompido Território Negro para resgatar a elfa mágica Alva, raptada pelo Rei Demônio. A narrativa não depende de diálogos complexos, mas sim de mecânicas visuais e de ambiente.
## 2. Direção de Arte e Identidade Visual
 * **Perspectiva:** Câmera isométrica / *Top-down* baseada em *tiles* (blocos).
 * **Dualidade de Cenários:** Forte contraste visual inspirado no jogo *Kingdom*. O Reino inicial é vibrante, saturado e vivo. O Território Negro é opressivo, com hachuras de névoa, árvores mortas e visual monocromático (escala de cinza).
 * **Sem Mini-mapa:** O jogo incentiva a exploração visual puramente observando o cenário.
## 3. Personagens
 * **O Herói:** Inspirado no Himmel (*Sousou no Frieren*). Usa roupas de terra e um manto preto. É o personagem jogável.
 * **Alva:** Inspirada na Frieren. Elfa de vestido branco e orelhas pontudas, que contrasta com a escuridão. Ela não é jogável na exploração, mas interage com o mapa deixando "Pistas Mágicas" (sigilos ou runas circulares com forte brilho/aura lilás) para guiar o herói.
 * **Rei Demônio (O Vilão):** Uma entidade sombria, disforme e opressora, quase como uma massa rabiscada de escuridão pura.
## 4. Tecnologias e Arquitetura Definidas
 * **Estilo de Movimentação:** Exploração em mapa 2D predefinido baseado em grade/tiles.
 * **Sistema de Combate:** Combate em turnos clássico.
 * **Engine Recomendada/Foco:** Godot Engine (utilizando TileMaps para o cenário) ou arquitetura customizada baseada em Python/Pygame, priorizando o controle do ritmo entre exploração e batalha.
## 5. Mecânicas Principais
 * **Sistema de Vida:** O herói possui 3 corações simples.
 * **Barra de Coragem (Mecânica Central):** Uma barra na HUD que reage ao ambiente. Na "Área Cinza" (Território Negro), a coragem do jogador diminui gradativamente (por tempo ou por bloco andado). Se esvaziar, afeta o gameplay.
 * **Pistas Mágicas e Puzzles:** Alva deixa rastros brilhantes (lilás) no mapa. O jogador deve encontrar essas pistas para resolver quebra-cabeças.
   * *Exemplo de Puzzle:* Dois altares guardando um portão. O jogador deve usar a pista de Alva para ativar o Altar Correto (S2). Se ativar o Altar Falso (S1), sofre uma penalidade (perde 1 coração de vida).
 * **Purificação (Vitória):** Ao resolver o desafio final da área e obter o "Fragmento de Cor", a corrupção é dissipada, e o cenário monocromático volta a ser colorido e cheio de vida. No clímax narrativo, a Barra de Coragem enche ao máximo e ressoa com a magia de Alva para energizar a espada do herói.
## 6. HUD e Interface (Minimalista)
 * **Gameplay:** A tela deve ser o mais limpa possível. Canto superior esquerdo: Barra de Coragem + 3 Corações. Canto superior direito: Slot de inventário rápido (arma equipada).
 * **Menu Principal:** Tela dividida na diagonal (Metade floresta colorida / Metade território morto em cinza). Opções: Novo Jogo, Continuar, Opções, Sair.
 * **Tela de Vitória:** Castelo purificado ao fundo, exibindo estatísticas da partida (Tempo, Pistas Decifradas, Coragem Final) e opção de continuar explorando o mapa agora pacífico.
## 7. Estrutura do Mapa de Protótipo (Vertical Slice)
A primeira fase a ser desenvolvida segue um fluxo estritamente vertical (do Sul para o Norte):
 1. **(Sul) Entrada:** Início do Herói na área verde.
 2. **Checkpoint (CP):** Área segura com fogueira/bandeira (a coragem não diminui aqui).
 3. **Pista de Alva (A):** Coleta da dica visual.
 4. **Transição:** Início da Área Cinza (HUD/Cenário monocromáticos; Coragem começa a cair).
 5. **Inimigo (E):** Bloqueia o caminho. Momento de transição para a tela de *combate em turnos*.
 6. **Quebra-cabeça:** Altares Falso (S1) e Verdadeiro (S2).
 7. **Portão Selado (G):** Abre ao ativar S2.
 8. **(Norte) Recompensa:** Fragmento de Cor (purifica o nível).
## 8. Fluxo de Telas (Máquina de Estados)
 * Splash Screen → Menu Principal.
 * Menu Principal → Gameplay.
 * Gameplay → Pausa (ESC) → Menu de Pausa (retorna ao jogo ou ao menu principal).
 * Gameplay → Morte (Vida = 0) → Game Over (Tentar de novo a partir do CP ou desistir).
 * Gameplay → Purificação do fragmento → Tela de Vitória (continuar explorando o mundo curado ou voltar ao menu).
**Dica para o próximo Chat:** Quando você iniciar a nova conversa, cole este resumo e diga: *"Este é o GDD do meu jogo. Vamos começar o desenvolvimento configurando o projeto na Engine X (a que você escolher, como o Godot) para implementar a movimentação em grid e o mapa predefinido."*