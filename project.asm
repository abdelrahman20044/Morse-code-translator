.MODEL SMALL
.STACK 100H
.DATA
    ; Menu and prompts
    HEADER   DB "  =====================================================", 13, 10
             DB "<(                   MORSE CODE ENCODER                  )>", 13, 10
             DB "  =====================================================", 13, 10, "$"
        MENU DB 13,10,10,"******************************" 
             DB 13, 10,  "* 1. Encode text (A-Z)OR(a-z)*", 
             DB 13,10,   "* 2. Encode numbers (0-9)    *", 
             DB 13,10,   "* 3. SHOW TABLES MORSE       *", 
             DB 13,10,   "* 4. Exit                    *", 
             DB 13,10,   "******************************" ,13,10
             DB "Choose option (1-4): $"
             PROMPT_T DB 13, 10, "Enter text to encode (A-Z OR a-z): $"
    PROMPT_N DB 13, 10, "Enter numbers to encode (0-9): $"
    RESULT   DB 13, 10, "Morse code: $"
    ERROR    DB 13, 10, "Invalid input! Press any key...$"
    NEWLINE  DB 13, 10, "$"
    PRESS_ANY_KEY DB 13,10,13,10,"PRESS ANY KEY TO CONTINUE!$"
    ; Input buffer
    BUFFER   DB 51 DUP(?)
    
    ; Morse code tables
     TABLE_MORSE DB 13,"========================================="
        DB 13,10,"MORSE CODE TABLE" 
        DB 13,10,"========================================="
        DB 13,10,"A = .-"
        DB "    B = -..."
        DB "  C = -.-."
        DB "  D = -.."
        DB "   E = ."
        DB 13,10,"F = ..-."
        DB "  G = --."
        DB "   H = ...."
        DB "  I = .."
        DB "    J = .---"
        DB 13,10,"K = -.-"
        DB "   L = .-.."
        DB "  M = --"
        DB "    N = -."
        DB "    0 = ---"
        DB 13,10,"P = .--."
        DB "  Q = --.-"
        DB "  R = .-."
        DB "   S = ..."
        DB "   T = -"
        DB 13,10,"U = ..-"
        DB "   V = ...-"
        DB "  W = .--"
        DB "   X = -..-"
        DB "  Y = -.--"
        DB 13,10,"Z = --.."
        DB "  0 = ----- "
        DB "  1 = .----"
        DB "  2 = ..---"
        DB "  3 = ...--"
        DB 13,10,"4=....-"
        DB "  5 = ....."
        DB "  6 = -...."
        DB "  7 = --..."
        DB "  8 = ---.."
        DB 13,10," 9 = ----.$"
                  
        
        
        
    LETTER_TABLE DB "A", ".-   "   
                 DB "B", "-... "      
                 DB "C", "-.-. "      
                 DB "D", "-..  "      
                 DB "E", ".    "      
                 DB "F", "..-. "      
                 DB "G", "--.. "    
                 DB "H", ".... "      
                 DB "I", "..   "      
                 DB "J", ".--- "     
                 DB "K", "-.-  "     
                 DB "L", ".-.. "      
                 DB "M", "--   "   
                 DB "N", "-.   "     
                 DB "O", "---  "      
                 DB "P", ".--. "      
                 DB "Q", "--.- "     
                 DB "R", ".-.  "      
                 DB "S", "...  "     
                 DB "T", "-    "      
                 DB "U", "..-  "      
                 DB "V", "...- "     
                 DB "W", ".--  "     
                 DB "X", "-..- "      
                 DB "Y", "-.-- "      
                 DB "Z", "--.. "  
    
    NUMBER_TABLE DB "0", "----- "
                 DB "1", ".---- "
                 DB "2", "..--- "
                 DB "3", "...-- "
                 DB "4", "....- "
                 DB "5", "..... "
                 DB "6", "-.... "
                 DB "7", "--... "
                 DB "8", "---.. "
                 DB "9", "----. "
                  
                 
 
.CODE
MAIN PROC
    .startup
    
MENU_LOOP:
    ; Clear screen
    MOV AX, 0003h
    INT 10h
    
    ; Display header and menu
    LEA DX, HEADER    ;mov dx,offect header
    MOV AH, 9
    INT 21H
    
    LEA DX, MENU
    MOV AH, 9
    INT 21H
    
    ; Get choice
    MOV AH, 1
    INT 21H
    
    CMP AL, '1'
    JE ENCODE_TEXT_MENU
    CMP AL, '2'
    JE ENCODE_NUMBER_MENU
    CMP AL, '3'
    JE tables
    
    CMP AL, '4'
    JE EXIT_PROGRAM
    
    ; Invalid choice
    LEA DX, ERROR
    MOV AH, 9
    INT 21H
    MOV AH, 1
    INT 21H
    JMP MENU_LOOP
key: 
    MOV AH, 9H
    lea DX, PRESS_ANY_KEY
    INT 21H  
    
    MOV AH, 1H
    INT 21H
    
    JMP menu_loop
   
    table_list:
          
            MOV AH, 9H
            lea DX,  TABLE_MORSE
            INT 21H
            JMP key
ENCODE_TEXT_MENU:
    CALL ENCODE_TEXT
    JMP MENU_LOOP

ENCODE_NUMBER_MENU:
    CALL ENCODE_NUMBER
    JMP MENU_LOOP

    tables:
    CALL table_list
    JMP MENU_LOOP

EXIT_PROGRAM:
    MOV AH, 4CH
    INT 21H
MAIN ENDP 

ENCODE_TEXT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    ; Display prompt
    LEA DX, PROMPT_T
    MOV AH, 9
    INT 21H
    ; Get input
    LEA SI, BUFFER
    XOR CX, CX
    
GET_TEXT:
    MOV AH, 1
    INT 21H
    
    CMP AL, 13
    JE END_TEXT_INPUT
    
    ; Convert to uppercase
    CMP AL, 'a';97
    JB STORE_CHAR
    CMP AL, 'z';122
    JA STORE_CHAR
    SUB AL, 32
    
STORE_CHAR:
    MOV [SI], AL
    INC SI
    INC CX
    JMP GET_TEXT
    
END_TEXT_INPUT:
    MOV BYTE PTR [SI], '$'
    
    ; Display result header
    LEA DX, RESULT
    MOV AH, 9
    INT 21H
    
    ; Process each character
    LEA SI, BUFFER
PROCESS_TEXT:
    MOV AL, [SI]
    CMP AL, '$'
    JE DONE_TEXT
    
    ; Find in LETTER_TABLE
    PUSH SI
    LEA SI, LETTER_TABLE
    MOV BL, AL
    SUB BL, 'A'    
    MOV AL, 6
    MUL BL
    ADD SI, AX
    
    ; Print Morse code
    ADD SI, 1
PRINT_TEXT_MORSE:
    MOV AL, [SI]
    CMP AL, ' '
    JE NEXT_TEXT_CHAR
    MOV DL, AL
    MOV AH, 2
    INT 21H
    INC SI
    JMP PRINT_TEXT_MORSE
    
NEXT_TEXT_CHAR:
            
    ; Print the tab character
    MOV AH, 02h    ; Function 2: Write character to stdout
    MOV DL, 09h    ; Load tab character into DL
    INT 21h        ; Call DOS interrupt
    
    
    POP SI
    INC SI
    JMP PROCESS_TEXT
    
DONE_TEXT:
    LEA DX, NEWLINE
    MOV AH, 9
    INT 21H
    
    MOV AH, 1
    INT 21H
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ENCODE_TEXT ENDP

ENCODE_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Display prompt
    LEA DX, PROMPT_N
    MOV AH, 9
    INT 21H
    
    ; Get input
    LEA SI, BUFFER
    XOR CX, CX
    
GET_NUMBER:
    MOV AH, 1
    INT 21H
    
    CMP AL, 13
    JE END_NUMBER_INPUT
    
    CMP AL, '0'
    JB GET_NUMBER
    CMP AL, '9'
    JA GET_NUMBER
    
    MOV [SI], AL
    INC SI
    INC CX
    JMP GET_NUMBER
    
END_NUMBER_INPUT:
    MOV BYTE PTR [SI], '$'
    
    ; Display result header
    LEA DX, RESULT
    MOV AH, 9
    INT 21H
    
    ; Process each number
    LEA SI, BUFFER
PROCESS_NUMBER:
    MOV AL, [SI]
    CMP AL, '$'
    JE DONE_NUMBER
    
    ; Find in NUMBER_TABLE
    PUSH SI
    LEA SI, NUMBER_TABLE
    MOV BL, AL
    SUB BL, '0'
    MOV AL, 7
    MUL BL
    ADD SI, AX
    
    ; Print Morse code
    ADD SI, 1
PRINT_NUMBER_MORSE:
    MOV AL, [SI]
    CMP AL, ' '
    JE NEXT_NUMBER
    MOV DL, AL
    MOV AH, 2
    INT 21H
    INC SI
    JMP PRINT_NUMBER_MORSE
    
NEXT_NUMBER:
    
        ; Print the tab character
    MOV AH, 02h    ; Function 2: Write character to stdout
    MOV DL, 09h    ; Load tab character into DL
    INT 21h        ; Call DOS interrupt
    
    
    POP SI
    INC SI
    JMP PROCESS_NUMBER
    
DONE_NUMBER:
    LEA DX, NEWLINE
    MOV AH, 9
    INT 21H
    
    MOV AH, 1
    INT 21H
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ENCODE_NUMBER ENDP
 

END MAIN
