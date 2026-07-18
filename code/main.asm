.INCLUDE "m64def.inc"

.ORG 0x0000
    JMP main       
.ORG 0x0002
    JMP INT0_ISR
.ORG 0x0004
    JMP INT1_ISR
.ORG 0x0006
    JMP INT2_ISR
.ORG 0x0008
    JMP INT3_ISR
.ORG 0x000A
    JMP INT4_ISR
.ORG 0x000C
    JMP INT5_ISR
.ORG 0x000E
    JMP INT6_ISR

.ORG 0x0020
    JMP Timer0_ISR

.ORG 0x0050
main:
    LDI R16, low(RAMEND)
    OUT SPL, R16
    LDI R16, high(RAMEND)
    OUT SPH, R16

    LDI R16, 0x0FF
    OUT DDRA, R16
    OUT DDRB, R16
    OUT DDRC, R16
    
    LDI R16, 0x00
    OUT DDRD, R16
    OUT DDRE, R16
    
    LDI R16, 0x0FF
    OUT PORTD, R16
    OUT PORTE, R16


	LDI R16,6
	OUT TCNT0,R16

    LDI R16, 0x7F      
    OUT EIMSK, R16

    LDI R16, 0x0AA      
    STS EICRA, R16
    LDI R16, 0x0AA      
    OUT EICRB, R16

    LDI R16, 0x01
    OUT TIMSK, R16

    LDI R17, 10 /////  neshangar tabaghe feli ke toosh hastim
    CLR R18 ////// Halat harkati visade ya are harkat mikone(Bala ya paiin)
    CLR R19 ///// baraye darkhast (age 0 bood yani darkhast nadarim)
    CLR R20 ///// age 0 bood = na tamdid ya etefaghi baraye dar nyoftade:) \ age 1 = tamdid baz boodan dar \ age 2= baste shodan fori \ age 3 = yeki dare hey klido feshar mide
    
    
    LDI R27, 3 
	LDI R28, 0
	CLR R29
//////////////////checked///////////
    CALL NAMAYESH_TABAGHE
    CALL STOP_LED
    CALL CLOSED_LED
    
    SEI                
	////////////checked/////
LOOP:
    CPI R20, 0 /////////bebine dakhasti darim ya na
    BRNE SERVICE_ON /////age dashtim bere be  SEVICE_0N

    CALL SERVICE_NEEDED
	CPI R29,1
	BREQ SERVICE_ON
    
    JMP CHECK_MOVE

SERVICE_ON:
    CALL SERVICE_ROUTINE
    JMP LOOP
///////////checked//////////
CHECK_MOVE:
    CPI R18, 0         
    BREQ IDLE
    CPI R18, 1         
    BREQ BALA
    CPI R18, 2         
    BREQ PAIIN
    JMP LOOP
	////////////////checked///////////
IDLE:
    CPI R19, 0         
    BREQ LOOP          
    
    CALL CHECK_BALA
    CPI R29, 2
	BREQ SET_UP        
    
    CALL CHECK_PAIIN
    CPI R29, 3
	BREQ SET_DOWN       
    JMP LOOP

SET_UP:
    LDI R18, 1  /////1 Chon namayande bala raftan
    CALL UP_LED
    JMP LOOP

SET_DOWN:
    LDI R18, 2 ////paiin/////
    CALL DOWN_LED
    JMP LOOP

BALA:
    CALL CHECK_BALA
	CPI R29, 0
    BREQ NO_MOVE   
    
    CALL UP_LED       
    CALL MOVE_UP_STEP_BY_STEP
    JMP LOOP

PAIIN:
    CALL CHECK_PAIIN
    CPI R29, 0
    BREQ NO_MOVE   
    
    
    CALL DOWN_LED      
    CALL MOVE_DOWN_STEP_BY_STEP
    JMP LOOP

NO_MOVE:
    LDI R18, 0
    CALL STOP_LED
    JMP LOOP

MOVE_UP_STEP_BY_STEP:
    CALL DELAY_750ms
    INC R17
    CALL NAMAYESH_TABAGHE
    RET

MOVE_DOWN_STEP_BY_STEP:
    CALL DELAY_750ms
    DEC R17
    CALL NAMAYESH_TABAGHE
    RET

SERVICE_ROUTINE:
    CALL CLEAR_REQ
    CALL STOP_LED
    
    CALL OPENING_LED
    CALL DELAY_1500ms
    
    CALL OPEN_LED
    
    ANDI R20, 0x0FE     
    
    LDI R24, 50        
WAIT_OPEN_LOOP:
    CALL DELAY_100ms  
    
    PUSH R16
    MOV R16, R20
    ANDI R16, 0x02
    CPI R16, 0x02
    POP R16
    BREQ CLOSE_NOW
    
    PUSH R16
    MOV R16, R20
    ANDI R16, 0x01
    CPI R16, 0x01
    POP R16
    BRNE NO_MORE_ACTION
    
    LDI R24, 30        
    ANDI R20, 0x0FE     
    
NO_MORE_ACTION:
    DEC R24
    BRNE WAIT_OPEN_LOOP
    
CLOSE_NOW:
    LDI R20, 0         
    
    CALL CLOSING_LED
    CALL DELAY_1500ms
    
    CALL CLOSED_LED
    RET

SERVICE_NEEDED:
    CLR R29 ///////clear kone R29:)              
    CPI R17, 10
    BREQ REQ_10 /////baressi kone va bebine hamoon tabaghe hastim ya na
    CPI R17, 15
    BREQ REQ_15
    CPI R17, 20
    BREQ REQ_20
    CPI R17, 25
    BREQ REQ_25
    CPI R17, 30
    BREQ REQ_30
    RET

REQ_10:
    PUSH R16
    MOV R16, R19
    ANDI R16, 0x01
    CPI R16, 0x01
    POP R16
    BREQ SET_REG_R29
    RET
REQ_15:
    PUSH R16
    MOV R16, R19
    ANDI R16, 0x02
    CPI R16, 0x02
    POP R16
    BREQ SET_REG_R29
    RET
REQ_20:
    PUSH R16
    MOV R16, R19
    ANDI R16, 0x04
    CPI R16, 0x04
    POP R16
    BREQ SET_REG_R29
    RET
REQ_25:
    PUSH R16
    MOV  R16, R19
    ANDI R16, 0x08
    CPI  R16, 0x08
    POP  R16
    BREQ SET_REG_R29
    RET
REQ_30:
    PUSH R16
    MOV  R16, R19
    ANDI R16, 0x10
    CPI  R16, 0x10
    POP  R16
    BREQ SET_REG_R29
    RET

SET_REG_R29:
    LDI  R29,1
    RET
/////////// Checked///////
CLEAR_REQ: //////////CLEAR kardan bite darkhast
    CPI R17, 10
    BREQ CURRENT_10
    CPI R17, 15
    BREQ CURRENT_15
    CPI R17, 20
    BREQ CURRENT_20
    CPI R17, 25
    BREQ CURRENT_25
    CPI R17, 30
    BREQ CURRENT_30
    RET
CURRENT_10: ANDI R19, 0b11111110  
     RET
CURRENT_15: ANDI R19, 0b11111101
     RET
CURRENT_20: ANDI R19, 0b11111011
     RET
CURRENT_25: ANDI R19, 0b11110111 
     RET
CURRENT_30: ANDI R19, 0b11101111
     RET
	 //////////checked////////
CHECK_BALA:
    CLR R29
    PUSH R23
    MOV R23, R19       
    CPI R17, 30
    BREQ NO_MORE_REQ_UP
    CPI R17, 15
    BRCS CHECK_ALL_UP    
    CPI R17, 20
    BRCS CHECK_20_UP     
    CPI R17, 25
    BRCS CHECK_25_UP     
    CPI R17, 30
    BRCS CHECK_30_UP     
    JMP NO_MORE_REQ_UP
CHECK_ALL_UP:
    ANDI R23, 0b00011110    
    JMP FINE_CHECK_UP
CHECK_20_UP:
    ANDI R23, 0b00011100     
    JMP FINE_CHECK_UP
CHECK_25_UP:
    ANDI R23, 0b00011000     
    JMP FINE_CHECK_UP
CHECK_30_UP:
    ANDI R23, 0b00010000     
    JMP FINE_CHECK_UP
FINE_CHECK_UP:
    CPI R23, 0
    BREQ NO_MORE_REQ_UP
    LDI R29, 2               
NO_MORE_REQ_UP:
    POP R23
    RET
	//////checkeed////
CHECK_PAIIN:
    CLR R29
    PUSH R23
    MOV R23, R19
    CPI R17, 10
    BREQ NO_REQ_DOWN
    CPI R17, 26        
    BRCC CHECK_ALL_DOWN    
    CPI R17, 21
    BRCC CHECK_20_DOWN     
    CPI R17, 16
    BRCC CHECK_15_DOWN     
    CPI R17, 11
    BRCC CHECK_10_DOWN     
    JMP NO_REQ_DOWN
CHECK_ALL_DOWN:
    ANDI R23, 0b00001111     
    JMP FINE_CHECK_DOWN
CHECK_20_DOWN:
    ANDI R23, 0b00000111     
    JMP FINE_CHECK_DOWN
CHECK_15_DOWN:
    ANDI R23, 0b00000011    
    JMP FINE_CHECK_DOWN
CHECK_10_DOWN:
    ANDI R23, 0b00000001     
    JMP FINE_CHECK_DOWN
FINE_CHECK_DOWN:
    CPI R23, 0
    BREQ NO_REQ_DOWN
    LDI  R29, 3
NO_REQ_DOWN:
    POP R23
    RET


INT0_ISR: IN  R30, PIND
          CPI R30, 0b11111110
		  BRNE B
          ORI R19, 0x01   ///// tabaghe 10
B:        RETI
INT1_ISR: IN  R30,PIND
          CPI R30,0b11111101
		  BRNE B
          ORI R19, 0x02   ///// tabaghe 15
          RETI
INT2_ISR: IN  R30, PIND
          CPI R30,0b11111011
		  BRNE B
          ORI R19, 0x04   ///// tabaghe 20
          RETI
INT3_ISR: IN  R30, PIND
          CPI R30,0b11110111
		  BRNE B
          ORI R19, 0x08   ///// tabaghe 25
          RETI
INT4_ISR: IN  R30, PINE
          CPI R30,0b11101111
		  BRNE B
		  ORI R19, 0x10   ///// tabaghe 30
          RETI
INT5_ISR: ORI R20, 0x01   ///// daro baz kon
          RETI
INT6_ISR: ORI R20, 0x02   ///// daro baste kon
          RETI

Timer0_ISR:
    PUSH R16
    IN   R16, SREG
    PUSH R16

    LDI R16, 6
    OUT TCNT0, R16

    DEC R27
    BRNE T0_ISR_DONE

    LDI R27, 3

    
    CPI R28, 0
    BREQ T0_ISR_DONE
    DEC R28

T0_ISR_DONE:
    POP R16
    OUT SREG, R16
    POP R16
    RETI

UP_LED:
    IN R16, PORTC

	ANDI R16,0x0BE
	ORI  R16,0x0BE
    OUT PORTC, R16
    RET
DOWN_LED:
    IN   R16, PORTC
    ANDI R16, 0b10111011
    ORI  R16, 0b10111011
    OUT  PORTC, R16
    RET
STOP_LED:
    IN   R16, PORTC
    ANDI R16, 0b10111101
    ORI  R16, 0b10111101
    OUT  PORTC, R16
    RET
OPENING_LED:
    IN   R16, PORTC
    ANDI R16, 0b11110101
    ORI  R16, 0b11110101
    OUT  PORTC, R16
    RET
OPEN_LED:
    IN   R16, PORTC
    ANDI R16, 0b11101101
    ORI  R16, 0b11101101
    OUT  PORTC, R16
    RET
CLOSING_LED:
    IN   R16, PORTC
    ANDI R16, 0b11011101
    ORI  R16, 0b11011101
    OUT  PORTC, R16
    RET
CLOSED_LED:
    IN   R16, PORTC
    ANDI R16, 0b10111101
    ORI  R16, 0b10111101
    OUT  PORTC, R16
    RET

NAMAYESH_TABAGHE:
    PUSH R16
    PUSH R21
    MOV R16, R17
    LDI R21, 0         
PRIMARY_DIV_LOOP:
    CPI R16, 10
    BRCS PRIMARY_DIV_DONE      
    SUBI R16, 10
    INC R21
    JMP PRIMARY_DIV_LOOP
PRIMARY_DIV_DONE:
    PUSH R16           
    MOV R16, R21       
    CALL SEGMENT_CODE  
    OUT PORTB, R22
    POP R16            
    CALL SEGMENT_CODE
    OUT PORTA, R22
    POP R21
    POP R16
    RET

SEGMENT_CODE:
    CPI R16, 0
    BREQ F_0
    CPI R16, 1
    BREQ F_1
    CPI R16, 2
    BREQ F_2
    CPI R16, 3
    BREQ F_3
    CPI R16, 4
    BREQ F_4
    CPI R16, 5
    BREQ F_5
    CPI R16, 6
    BREQ F_6
    CPI R16, 7
    BREQ F_7
    CPI R16, 8
    BREQ F_8
    CPI R16, 9
    BREQ F_9
    RET 
F_0: LDI R22, 0x3F
      RET
F_1: LDI R22, 0x06
      RET
F_2: LDI R22, 0x5B
      RET
F_3: LDI R22, 0x4F
      RET
F_4: LDI R22, 0x66
      RET
F_5: LDI R22, 0x6D
      RET
F_6: LDI R22, 0x7D
      RET
F_7: LDI R22, 0x07
      RET
F_8: LDI R22, 0x7F
      RET
F_9: LDI R22, 0x6F
      RET

DELAY_750ms:
    LDI R23, 0b00011111
    LDI R28, 75
    CALL BEGIN_TIMER_WAIT
    RET

DELAY_1500ms:
    LDI R23, 0x1F
    LDI R28, 150
    CALL BEGIN_TIMER_WAIT
    RET

DELAY_100ms:
    LDI R23, 0x7F
    LDI R28, 10
    CALL BEGIN_TIMER_WAIT
    RET

BEGIN_TIMER_WAIT:
    OUT EIMSK, R23

    LDI R27, 3
    
    LDI R16, 6
    OUT TCNT0, R16
    
    LDI R16, 0x02
    OUT TCCR0, R16
    
OUR_WAIT_LOOP:
    CPI R28, 0
    BRNE OUR_WAIT_LOOP
    

    LDI R16, 0x00
    OUT TCCR0, R16
    
    LDI R16, 0x7F
    OUT EIMSK, R16
    
    RET