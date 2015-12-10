;Practica 6, Victor Tortolero, Oswaldo Capriles
		DEFSEG	INICIO1,ABSOLUTE
		SEG	INICIO1
		JMP	INICIO
		
		ORG 	1BH
SIT1:	PUSH 	ACC
		CALL 	boing
		MOV 	R7, #01H
		POP 	ACC
		RETI

		ORG 	100H
;Etiquetas de reloj
CERO	EQU 	30H
NUEVE	EQU 	39H
HOR1	EQU		20H
HOR2	EQU		21H
MIN		EQU		24H
SEG		EQU		27H
VAR 	EQU 	50H
;Etiquetas de carita
FACE 	EQU 	02H
BLAN 	EQU 	20H
FLAG	EQU 	F0

;Subprograma de la Carita
boing:	CJNE 	R1, #3FH, swag
		CPL		FLAG
swag:	CJNE 	R1, #38H, trans
		CPL		FLAG
trans:	JB 		FLAG, izq
der:	INC 	R3
		JMP 	step
izq:	DEC 	R3
step:	MOV		@R1, #BLAN
		MOV 	R1, 03H
		MOV 	@R1, #FACE
		RET
;Fin de Subprograma de la Carita

;Proceso del reloj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RELOJ:	MOV		R7, #00H
		MOV 	A, P0
		MOV 	R0, #SEG
		CJNE 	A, #'a', ELSE1
		CALL 	IRELOJ
		RET
ELSE1:	CJNE 	A, #'A', ELSE2
		CALL 	IRELOJ
		RET
ELSE2:	CJNE 	A, #'d', ELSE3
		CALL 	DRELOJ
		RET
ELSE3:	CJNE 	A, #'D', ELSE4
		CALL 	DRELOJ
ELSE4: 	RET

IRELOJ:	CJNE 	@R0, #'9', ELSE5	;Revisando segundos
		MOV 	@R0, #'0'
		DEC 	R0
		CJNE 	@R0, #'5', ELSE5
		MOV 	@R0, #'0'
		MOV 	R0, #MIN			;Revisando minutos
		CJNE 	@R0, #'9', ELSE5
		MOV 	@R0, #'0'
		DEC 	R0
		CJNE 	@R0, #'5', ELSE5
		MOV 	@R0, #'0'
		MOV 	R0, #HOR1			;Revisando horas
		CJNE 	@R0, #'2', ELSE6
		INC 	R0
		CJNE 	@R0, #'3', ELSE5
		MOV 	@R0, #'0'
		DEC 	R0
		MOV 	@R0, #'0'
		RET
ELSE5:	INC 	@R0
		RET
ELSE6:	INC 	R0					;Continuacion de la revision de horas
		CJNE 	@R0, #'9', ELSE5
		MOV 	@R0, #'0'
		DEC 	R0
		INC 	@R0
		RET

DRELOJ:	CJNE 	@R0, #'0', ELSE7	;Revisando segundos
		MOV 	@R0, #'9'
		DEC 	R0
		CJNE 	@R0, #'0', ELSE7
		MOV 	@R0, #'5'
		MOV 	R0, #MIN			;Revisando minutos
		CJNE 	@R0, #'0', ELSE7
		MOV 	@R0, #'9'
		DEC 	R0
		CJNE 	@R0, #'0', ELSE7
		MOV 	@R0, #'5'
		MOV 	R0, #HOR1			;Revisando horas
		CJNE 	@R0, #'0', ELSE8
		INC 	R0
		CJNE 	@R0, #'0', ELSE7
		MOV 	@R0, #'3'
		DEC 	R0
		MOV 	@R0, #'2'
		RET
ELSE7:	DEC  	@R0
		RET
ELSE8:	INC 	R0					;Continuacion de la revision de horas
		CJNE 	@R0, #'0', ELSE7
		MOV 	@R0, #'9'
		DEC 	R0
		DEC 	@R0
		RET
;Fin del Proceso del reloj %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;Inicializando el Reloj en 00:00:00
INIT:	MOV 	20H, #'0'
		MOV 	21H, #'0'
		MOV 	22H, #':'
		MOV 	23H, #'0'
		MOV 	24H, #'0'
		MOV 	25H, #':'
		MOV 	26H, #'0'
		MOV 	27H, #'0'
		MOV 	R1, #38H
init2:	MOV		@R1, #BLAN
		INC 	R1
		CJNE 	R1, #3FH, init2
		MOV 	@R1, #FACE
		MOV 	R3, 01H
		RET

INICIO:	MOV		PSW, #00H			;Esto es opcional 
		CALL 	INIT
		MOV 	TMOD, #00100000B 	;Poniendo Timer 0 y Timer 1 en modo 2
		MOV 	R7, #00H
		SETB 	EA					;Activando Interrupciones
		SETB 	ET1					;Activando interrupcion del Timer 1
		SETB 	TR1					;Activando el Timer 1
		SETB 	PT1					;Dandole prioridad al Timer 1
		
LOOP: 	CJNE 	R7, #01H, LOOP
		CALL 	RELOJ
		JMP 	LOOP

EXIT:  	END