#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=0000h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=0000h#	; same as loading segment
#ES=0000h#	; same as loading segment

; set stack
#SS=0000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
   JMP START
   DB 1021 DUP(0)

START:   CLI 

; intialize ds, es,ss to start of RAM
          mov       ax,0200h
          mov       ds,ax
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFFEH
          mov       si,0000 
          

;POLLING INPUT SWITCH
        MOV AL,90H      ;SET MODE PA-INPUT
        OUT 56H,AL 
READY:  IN AL,50H       ;READ PORT A
        CMP AL,00H      ;CHECK IF PORT A HAS INPUT
        JZ READY

;TESTING
        MOV DX,0        ;INTIAL ADDRESS FOR 6164
        MOV SI,1FFFH    ;MAX ADDRESS FOR 6164
        MOV BH,00H      ;USED FOR WRITING ZEROS
        MOV BL,01H      ;USED FOR WRITING ONES
        MOV DX,00H      ;INDICATES PRESENT ADDRESS

REP_A:  MOV AH,08H  ;BYTE LOOP
REP_B:  MOV CH,BH   ; WRITE/READ ZERO
        CALL WRITE 
        CALL READ
        AND CH,BL   ;TO COMPARE THE WRITTEN AND READ VALUES
        CMP BH,CH 
        JNZ FAILED

        MOV CH,BL   ; WRITE/READ ONE
        CALL WRITE 
        CALL READ
        AND CH,BL
        CMP CH,BL 
        JNZ FAILED
        
        ROL BL,1
        DEC AH 
        JNZ REP_B   ;END OF BYTE LOOP

        INC DX      ;NEXT ADDRESS
        CMP DX,SI   ; CHECK IF LAST ADDRESS HAS BEEN REACHED 
        JNZ REP_A  

;OUTPUT
PASSED: CALL DISP_P  ;DISPLAY PASS
FAILED: CALL DISP_F  ;DISPLAY FAIL

;----------------------------------------------------------------
DELAY PROC NEAR
    ; INTRODUCES DELAY 
    PUSH CX 
    MOV CL,88H
X1: NOP
    LOOP X1
    POP CX 
    RET 
DELAY ENDP
;----------------------------------------------------------------

READ PROC NEAR
    ; READS A BYTE FROM SRAM 6164
    ; INPUT ARG: DX -> ADDRESS ON SRAM
    ; OUTPUT: CH -> DATA READ FROM SRAM
    
    MOV AL,90H
    OUT 86H,AL  ;SET READING MODE
    
    ;PLACE THE ADDRESS
    MOV AL,DL
    OUT 82H,AL  ;SET ADDRESS A0-A7
    MOV AL,DH
    OUT 84H,AL  ;SET ADDRESS A8-A12
    
    ;READ ENABLE OF SRAM
    MOV AL,2FH
    OUT 54H,AL
    
    ;READ DATA
    IN AL,80H
    MOV CH,AL
    
    CALL DELAY

    ;RESET READ ENABLE SIGNAL OF SRAM
    MOV AL,3FH
    OUT 54H,AL
        
    RET
READ ENDP

;------------------------------------------------------------------

WRITE PROC NEAR
    ; WRITE BYTE INTO SRAM 6164
    ;INPUT ARG: CH -> BYTE TO BE WRITTEN,   DX -> ADDRESS ON SRAM

    MOV AL,80H
    OUT 86H,AL    ;SET WRITE MODE
    
    ;SET ADDRESS BUS
    MOV AL,DL
    OUT 82H,AL    ;SET ADDRESS A0-A7
    MOV AL,DH
    OUT 84H,AL    ;SET ADDRESS A8-A12 
    
    ;PUT DATA ON PORT_A
    MOV AL,CH
    OUT 80H,AL

    ;WRITE ENABLE OF SRAM
    MOV AL,1FH
    OUT 54H,AL  
    
    CALL DELAY 
    
    ;RESET WRITE ENABLE SIGNAL SRAM
    MOV AL,3FH
    OUT 54H,AL 

    RET 
WRITE ENDP

;---------------------------------------------------------------

DISP_P PROC NEAR
    ;DISPLAY PASS ON 4 7-SEGMENT DISPLAYS
    ;P: 0CH    A: 08H     S: 12H     

    MOV AL,90H  ;SET MODE
    OUT 56H,AL 
    MOV AL,00H
    OUT 52H,AL  ;MAKE ALL OUTPUTS ZERO

    ;DISPLAYING OUTPUT BY ENABLING LATCH ONE AT A TIME
P1: 
    ;ENABLE DISP1
    MOV AL,11111110B
    OUT 54H,AL    
    MOV AL,0CH  ;DISPLAY P
    OUT 52H,AL 
    
    ;ENABLE DISP2
    MOV AL,11111101B
    OUT 54H,AL  
    MOV AL,08H  ;DISPLAY A
    OUT 52H,AL 
    
    ;ENABLE DISP3
    MOV AL,11111011B
    OUT 54H,AL
    MOV AL,12H  ;DISPLAY S
    OUT 52H,AL
    
    ;ENABLE DISP4
    MOV AL,11110111B
    OUT 54H,AL
    MOV AL,12H  ;DISPLAY S
    OUT 52H,AL

    JMP P1
    RET
DISP_P ENDP

;------------------------------------------------------------------------

DISP_F PROC NEAR
 ;DISPLAY PASS ON 4 7-SEGMENT DISPLAYS
    ;F: 0EH    A: 08H     I: 79H     L:47H     
    MOV AL,90H  ;SET MODE
    OUT 56H,AL 
    MOV AL,00H
    OUT 52H,AL  ;MAKE ALL OUTPUTS ZERO

    ;DISPLAYING OUTPUT BY ENABLING LATCH ONE AT A TIME
P2: 
    ;ENABLE DISP1
    MOV AL,11111110B
    OUT 54H,AL    
    MOV AL,0EH  ;DISPLAY F
    OUT 52H,AL 
    
    ;ENABLE DISP2
    MOV AL,11111101B
    OUT 54H,AL  
    MOV AL,08H ;DISPLAY A
    OUT 52H,AL 
    
    ;ENABLE DISP3
    MOV AL,11111011B
    OUT 54H,AL
    MOV AL,79H  ;DISPLAY I
    OUT 52H,AL
    
    ;ENABLE DISP4
    MOV AL,11110111B
    OUT 54H,AL
    MOV AL,47H   ;DISPLAY L
    OUT 52H,AL

    JMP P2
    RET
DISP_F ENDP

;------------------------------------------------------------------