; ==============================================================================
; JOGO DA VELHA EM ASSEMBLY
; Compatível com o Processador ICMC
; ==============================================================================

; ------- TABELA DE CORES (Atributos de Vídeo) -------
; 0 branco          | 2816 marrom      | 512 verde        | 768 oliva
; 1024 azul marinho | 1280 roxo        | 1536 teal        | 1792 prata
; 2048 cinza        | 2304 vermelho    | 28160 lima       | 2816 amarelo
; 3072 azul         | 3328 rosa        | 3584 aqua        | 3840 preto

jmp inicio_programa

; ==============================================================================
; FLUXO DE EXECUÇÃO PRINCIPAL
; ==============================================================================

inicio_programa:
    call desenha_cenario
    call ciclo_principal
    halt                             ; Para o Processador

ciclo_principal:
    jmp mostra_status_turno

aguarda_teclado:
    inchar r0                        ; Captura entrada do teclado
    loadn r1, #255
    cmp r0, r1                       ; Loop de espera ativa (Polling)
    jeq aguarda_teclado
        
    loadn r1, #57                    ; Valida se é maior que o caractere '9'
    cmp r0, r1
    jgr aguarda_teclado
    
    loadn r1, #49                    ; Valida se é menor que o caractere '1'
    cmp r0, r1
    jle aguarda_teclado

    call valida_coordenada           ; Se o input for de '1' a '9', avança

renderiza_jogada:
    load r1, jogadorAtual            
    outchar r1, r2                   ; Imprime o caractere (X ou O) na tela
    
    load r1, espacosOcupados         
    inc r1
    store espacosOcupados, r1        ; Incrementa o contador de rodadas
    
verifica_fim_jogo:
    loadn r4, #0
    call varre_linhas                ; Inicia checagem de condições de término

alterna_turno:   
    loadn r2, #'X'
    load r3, jogadorAtual
    cmp r2, r3
    jeq define_o                     ; Se era X, muda para O
    
    loadn r2, #'O'
    load r3, jogadorAtual
    cmp r2, r3
    jeq define_x                     ; Se era O, muda para X

mostra_status_turno:
    load r4, jogadorAtual            
    loadn r3, #160                   ; Posição do indicador do jogador ativo
    outchar r4, r3

    loadn r0, #162                   
    loadn r1, #strVezJogador         
    loadn r2, #1024                  ; Texto em Azul Marinho
    call escreve_texto
    jmp aguarda_teclado

define_x:
    loadn r2, #'X'
    store jogadorAtual, r2
    jmp ciclo_principal

define_o:
    loadn r2, #'O'
    store jogadorAtual, r2
    jmp ciclo_principal

; ==============================================================================
; SUBROTINAS DE LOGÍSTICA E MAPEAMENTO
; ==============================================================================

valida_coordenada:
    mov r1, r0
    loadn r3, #'0'
    sub r1, r1, r3                   ; Converte ASCII para decimal
    dec r1                           ; Transforma em índice (0 a 8)
    
    loadn r2, #tabuleiro
    add r2, r2, r1                   ; Calcula o endereço no vetor
    
    loadi r1, r2                     ; Carrega o estado atual da casa
    loadn r3, #0
    cmp r1, r3                       ; Se não estiver vazio (0), rejeita a jogada
    jne ciclo_principal
    
    load r1, jogadorAtual
    storei r2, r1                    ; Grava a jogada na memória do tabuleiro
    jmp calcula_posicao_video
    
calcula_posicao_video:
    loadn r3, #'4'
    cmp r0, r3
    jle linha_superior
    
    loadn r3, #'7'
    cmp r0, r3
    jle linha_central
    
    loadn r3, #':'                   
    cmp r0, r3
    jle linha_inferior

linha_superior:
    mov r2, r0
    loadn r3, #'0'
    sub r2, r2, r3                   
    dec r2                           ; Coordenadas físicas: 0, 1 ou 2
    jmp renderiza_jogada

linha_central:
    mov r2, r0
    loadn r3, #'3'
    sub r2, r2, r3                   
    loadn r3, #40
    add r2, r2, r3
    dec r2                           ; Coordenadas físicas: 40, 41 ou 42
    jmp renderiza_jogada

linha_inferior:
    mov r2, r0
    loadn r3, #'6'
    sub r2, r2, r3                   
    loadn r3, #80
    add r2, r2, r3
    dec r2                           ; Coordenadas físicas: 80, 81 ou 82
    jmp renderiza_jogada

; ==============================================================================
; ALGORITMOS DE VARREDURA DE MATRIZ (CONDIÇÕES DE VITÓRIA)
; ==============================================================================

varre_linhas:
    loadn r0, #tabuleiro
    add r0, r0, r4                   
    loadi r1, r0                     
    
    loadn r2, #0
    cmp r1, r2                       
    jeq proxima_linha
     
    ; verifica a segunda casa da linha (anda +1)
    inc r0 
    loadi r2, r0                     
    cmp r1, r2                       
    jne proxima_linha
    
    ; verifica a terceira casa da linha (anda +1)
    inc r0 
    loadi r3, r0                     
    cmp r2, r3                       
    jne proxima_linha
    
    jmp tela_vitoria                 

proxima_linha:
    loadn r5, #3                     
    add r4, r4, r5                   
    
    loadn r5, #8
    cmp r4, r5
    jle varre_linhas                 
    
    loadn r4, #0
    jmp varre_colunas
    
varre_colunas:
    loadn r0, #tabuleiro
    add r0, r0, r4
    loadi r1, r0                     
    
    loadn r2, #0
    cmp r1, r2                       
    jeq proxima_coluna
     
    loadn r5, #3
    add r0, r0, r5 
    loadi r2, r0                     
    cmp r1, r2
    jne proxima_coluna
    
    loadn r5, #3
    add r0, r0, r5 
    loadi r3, r0                     
    cmp r2, r3
    jne proxima_coluna
    
    jmp tela_vitoria

proxima_coluna:
    inc r4                           
    loadn r5, #3
    cmp r4, r5
    jle varre_colunas
    
    loadn r4, #0
    jmp varre_diagonais
    
varre_diagonais:
diagonal_princ:
    loadn r0, #tabuleiro
    add r0, r0, r4
    loadi r1, r0                     
    
    loadn r2, #0
    cmp r1, r2                       
    jeq continua_checagem
     
    loadn r5, #4
    add r0, r0, r5 
    loadi r2, r0                     
    cmp r1, r2
    jne continua_checagem
    
    loadn r5, #4
    add r0, r0, r5 
    loadi r3, r0                     
    cmp r2, r3
    jne continua_checagem
    
    jmp tela_vitoria

diagonal_sec:
    loadn r0, #tabuleiro
    add r0, r0, r4
    loadi r1, r0                     
    
    loadn r2, #0
    cmp r1, r2                       
    jeq continua_checagem
     
    loadn r5, #2
    add r0, r0, r5 
    loadi r2, r0                     
    cmp r1, r2
    jne continua_checagem
    
    loadn r5, #2
    add r0, r0, r5 
    loadi r3, r0                     
    cmp r2, r3
    jne continua_checagem
    
    jmp tela_vitoria             

continua_checagem:
    inc r4                           
    inc r4
    loadn r5, #4
    cmp r4, r5
    jle diagonal_sec
    
    jmp testa_empate

testa_empate:
    loadn r4, #9                     
    load r5, espacosOcupados
    cmp r4, r5
    jne alterna_turno                 
    
    jmp tela_empate

; ==============================================================================
; ESTADOS DE FINALIZAÇÃO (TELAS DE FIM DE JOGO)
; ==============================================================================

tela_empate:
    loadn r0, #160                   
    loadn r1, #strVelha              
    loadn r2, #2304                  ; printa alerta em Vermelho
    call escreve_texto
    
    loadn r0, #200                   
    loadn r1, #strResetStr           
    loadn r2, #0                     
    call escreve_texto
    
loop_espera_empate:
    inchar r0
    loadn r1, #' '
    cmp r0, r1
    jne loop_espera_empate
    
    jmp reinicia_sistema
    
tela_vitoria:
    load r4, jogadorAtual            
    loadn r3, #160
    outchar r4, r3
    
    loadn r0, #162                   
    loadn r1, #strVencedor           
    loadn r2, #512                   ; printa ucesso em Verde
    call escreve_texto
    
    loadn r0, #200                   
    loadn r1, #strResetStr           
    loadn r2, #0                     
    call escreve_texto
    
loop_espera_vitoria:
    inchar r0
    loadn r1, #' '
    cmp r0, r1
    jne loop_espera_vitoria
    
reinicia_sistema:
    ; Limpa as mensagens de texto da tela
    loadn r0, #160                   
    loadn r1, #apagaString           
    loadn r2, #0                     
    call escreve_texto
    
    loadn r0, #200                   
    loadn r1, #apagaString           
    loadn r2, #0                     
    call escreve_texto
    
    ; Reseta os dados em memória (Corrigido para uma instrução por linha)
    loadn r0, #tabuleiro
    loadn r1, #0                     
    loadn r2, #1                     
    
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    add r0, r0, r2
    storei r0, r1
    
    loadn r0, #'X'
    store jogadorAtual, r0
    
    loadn r0, #0
    store espacosOcupados, r0
    
    jmp inicio_programa

; ==============================================================================
; INTERFACES GRÁFICAS E RENDERIZAÇÃO
; ==============================================================================

desenha_cenario:
    loadn r0, #0                     
    loadn r1, #linhaVazia            
    loadn r2, #1536                  ; Renderiza o tabuleiro na cor Teal
    call escreve_texto
    
    loadn r0, #40                    
    loadn r1, #linhaVazia            
    loadn r2, #1536                  
    call escreve_texto   
    
    loadn r0, #80                    
    loadn r1, #linhaVazia            
    loadn r2, #1536                  
    call escreve_texto          
    rts
        
escreve_texto:      
    push r0 
    push r1 
    push r2 
    push r3 
    push r4 
    
    loadn r3, #'\0' 

loop_escreve:   
    loadi r4, r1        
    cmp r4, r3          
    jeq fim_escreve 
    add r4, r2, r4      
    outchar r4, r0      
    inc r0              
    inc r1              
    jmp loop_escreve    
    
fim_escreve:    
    pop r4  
    pop r3
    pop r2
    pop r1
    pop r0
    rts     

; ==============================================================================
; DECLARAÇÃO DE VARIÁVEIS E CONSTANTES (DADOS)
; ==============================================================================

linhaVazia:      string "..."             
strVezJogador:   string "- SUA VEZ!"
strVelha:        string "EMPATE! DEU VELHA!           "
strVencedor:     string "VENCEU A PARTIDA!            "
strResetStr:     string "Pressione [ESPACO] para reiniciar o jogo...   "
apagaString:     string "                                              "

jogadorAtual:    var #1
static jogadorAtual + #0, #'X'

espacosOcupados: var #1
static espacosOcupados + #0, #0

tabuleiro:       var #9
static tabuleiro + #0, #0
static tabuleiro + #1, #0
static tabuleiro + #2, #0
static tabuleiro + #3, #0
static tabuleiro + #4, #0
static tabuleiro + #5, #0
static tabuleiro + #6, #0
static tabuleiro + #7, #0
static tabuleiro + #8, #0
