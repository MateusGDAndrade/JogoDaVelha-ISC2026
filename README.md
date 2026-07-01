# Jogo da Velha em Assembly (Processador ICMC)

# Mateus Gentil Dantas de Andrade - 11317911


Este repositório contém uma implementação do clássico **Jogo da Velha** escrita inteiramente em **Linguagem Assembly** para o **Processador ICMC** 


O projeto foi estruturado para fins acadêmicos na disciplina de **Introdução a Sistemas Computacionais (ISC)**

---

## Conceitos de Hardware Aplicados

O desenvolvimento deste jogo em Assembly exige o gerenciamento manual de recursos computacionais demonstrados no código:

### 1. Mapeamento de Vetores Lineares na Memória
Em vez de uma matriz bidimensional `[3][3]`, o tabuleiro é armazenado como um vetor estritamente linear de 9 posições na memória de dados (`tabuleiro: var #9`). O programa converte a entrada do usuário através de cálculos de deslocamento de ponteiros (Endereçamento Indireto):
$$	ext{Endereço Alvo} = 	ext{Endereço Base} + 	ext{Deslocamento (Índice)}$$

### 2. Entrada por Varredura Ativa (*Polling*)
A captura do teclado utiliza a técnica de *Polling*. O processador fica preso em um ciclo fechado (`aguarda_teclado`) executando a instrução `inchar`. Ele consulta o periférico continuamente e só avança quando uma tecla válida (de '1' a '9') é pressionada.

### 3. Renderização Direta no Buffer de Vídeo
O cenário e as jogadas são desenhados utilizando a instrução `outchar`, que escreve caracteres diretamente nas coordenadas da memória de vídeo. As quebras de linha visuais no monitor são simuladas através de saltos aritméticos de endereço (Linha 1: posições 0-2, Linha 2: posições 40-42, Linha 3: posições 80-82).

### 4. Controle Algorítmico via Flags da ULA
A verificação de vitória (linhas, colunas e diagonais) e empate é feita por meio de varreduras matemáticas no vetor. O processador realiza subtrações ocultas com a instrução `cmp`, ativando as **Flags de Estado** (como a *Zero Flag*) na Unidade Lógica e Aritmética (ULA) para ditar os desvios condicionais (`jeq`, `jne`, `jgr`).

### 5. Preservação de Contexto na Pilha (*Stack*)
Para evitar a corrupção de dados entre o loop de jogo e as subrotinas de renderização de texto, o programa utiliza a **Pilha da Arquitetura** (LIFO). As instruções `push` e `pop` isolam e protegem o contexto dos registradores (`r0` a `r4`) a cada chamada de função.

---

## Especificações Visuais e Customização

O jogo utiliza o sistema de atributos de cor do Processador ICMC para criar uma interface gráfica

* **Tabuleiro:** Renderizado no padrão `...` (pontos) com a cor **Teal** 
* **Interface de Alertas:** Mensagens de estado em **Azul Marinho**, condições de vitória em **Verde** e telas de empate/erro em **Vermelho**.

---

## Como Executar

1. Baixe o simulador do **Processador-ICMC**.
2. Carregue o arquivo fonte `jogodavelha_modificado.ASM` no montador do simulador.
3. Compile o código para gerar o arquivo binário executável da arquitetura.
4. Execute o simulador em modo contínuo ou acompanhe o ciclo passo a passo (*Step*) para observar a flutuação dos registradores em tempo real.

## Controles do Jogo

* **Teclas de 1 a 9:** Selecionam a respectiva casa do tabuleiro para realizar a jogada do turno ativo.
* **Barra de Espaço:** Reinicia o jogo, limpa o tabuleiro em memória e zera os buffers de texto na tela após o resultado (vitória ou empate).

---

##  Estrutura de Rótulos do Código

* `inicio_programa`: Ponto de entrada que chama a inicialização do cenário e o loop de jogo.
* `ciclo_principal` / `aguarda_teclado`: Gerenciamento do fluxo de turnos e captura de E/S.
* `valida_coordenada` / `calcula_posicao_video`: Validação matemática de posições e conversão de coordenadas físicas.
* `varre_linhas` / `varre_colunas` / `varre_diagonais`: Algoritmos de varredura de matriz baseados em saltos da ULA.
* `tela_vitoria` / `tela_empate` / `reinicia_sistema`: Tratamento de interrupção lógica de fim de jogo e reset de registradores.
