
	TITLE  "SleepCES Device"
	PROCESSOR 16F19175
	#include <xc.inc>
	#include "SleepDef.INC"









;********************************************************************
;
;  Project:	SleepCES is a Fresh Electronic Designs personal project
;		
;  File:	Sleep1.S
;
;  Processor:	The Code is written for the MicroChip 16F19175 running
;		at 16 MHz. 
;
;  Authors:	Kent W. Mabey with a little help from Glen
;
;
;		Copyright (c) 2021  FED
;
;  Description: CES SLEEP ENHANCER
;*********************************************************************

;
config FEXTOSC = OFF    // External Oscillator mode selection bits (Oscillator not enabled)
config RSTOSC = HFINT32 // Power-up default value for COSC bits (HFINTOSC with OSCFRQ= 32 MHz and CDIV = 1:1)
config CLKOUTEN = OFF   // Clock Out Enable bit (CLKOUT function is disabled; i/o or oscillator function on OSC2)
config VBATEN = OFF     // VBAT Pin Enable bit (VBAT functionality is disabled)
config LCDPEN = OFF     // LCD Charge Pump Mode bit (LCD Charge Pump is disabled.)
config CSWEN = ON       // Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
config FCMEN = ON       // Fail-Safe Clock Monitor Enable bit (FSCM timer enabled)

// CONFIG2
config MCLRE = ON       // Master Clear Enable bit (MCLR pin is Master Clear function)
config PWRTE = OFF      // Power-up Timer selection bits (PWRT disable)
config LPBOREN = OFF    // Low-Power BOR enable bit (ULPBOR disabled)
config BOREN = ON       // Brown-out reset enable bits (Brown-out Reset Enabled, SBOREN bit is ignored)
config BORV = LO        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (VBOR) set to 1.9V on LF, and 2.45V on F Devices)
config ZCD = OFF        // Zero-cross detect disable (Zero-cross detect circuit is disabled at POR.)
config PPS1WAY = ON     // Peripheral Pin Select one-way control (The PPSLOCK bit can be cleared and set only once in software)
config STVREN = ON      // Stack Overflow/Underflow Reset Enable bit (Stack Overflow or Underflow will cause a reset)

// CONFIG3
config WDTCPS = WDTCPS_31// WDT Period Select bits (Divider ratio 1:65536; software control of WDTPS)
config WDTE = ON        // WDT operating mode (WDT enabled regardless of sleep; SWDTEN ignored)
config WDTCWS = WDTCWS_7// WDT Window Select bits (window always open (100%); software control; keyed access not required)
config WDTCCS = HFINTOSC// WDT input clock selector (WDT reference clock is the 31.25 kHz HFINTOSC)

// CONFIG4
config BBSIZE = 512     // Boot Block Size Selection bits (Boot Block Size (Words) 512)
config BBEN = OFF       // Boot Block Enable bit (Boot Block disabled)
config SAFEN = OFF      // SAF Enable bit (SAF disabled)
config WRTAPP = OFF     // Application Block Write Protection bit (Application Block NOT write-protected)
config WRTB = OFF       // Boot Block Write Protection bit (Boot Block NOT write-protected)
config WRTC = OFF       // Configuration Register Write Protection bit (Configuration Words NOT write-protected)
config WRTD = OFF       // Data EEPROM Write Protection bit (Data EEPROM NOT write-protected)
config WRTSAF = OFF     // Storage Area Flash Write Protection bit (SAF NOT write-protected)
config LVP = OFF        // Low Voltage Programming Enable bit (High Voltage on MCLR/Vpp must be used for programming)

// CONFIG5
config CP = OFF         // UserNVM Program memory code protection bit (UserNVM code protection disabled)

	
// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.
	
	
;	REGISTER EQUATES


PSECT	udata_bank0


BCOUNT:		DS	1		;
TEMP_DATA:	DS	1		;

CODE2:		DS	1		; 0= KEY WORK DONE
					; 1= ZERO BLANKING FLAG
					; 2= 
					; 3= 
					; 4= CHIME FLAG
					; 5= 
					; 6= DO CHIME DISPLAY UPDATE
					; 7= 


H_BYTE:		DS	1		; BINTOBCD INPUT
L_BYTE:		DS	1		;
R0:		DS	1		; MSD ANSWER BINTOBCD
R1:		DS	1		;
R2:		DS	1		; LSD

CONTRAST:	DS	1		; CONTRAST SETTING, SAVED IN EEPROM	
EE_TEMP:	DS	1		;
EE_TEMP1:	DS	1		;

EE_DATA:	DS	1		;
EE_ADDR:	DS	1		;

TEMP3:		DS	1		; 
TEMP4:		DS	1		;
TEMP5:		DS	1		;
FREQ:		DS	1		;
DURA:		DS	1		;
MSCT:		DS	1		;
TIMEOUT:	DS	1		; USED TO DECIDE WHEN TO shut off and GO TO SLEEP
ETIME_CNT:	DS	1		;
TIME_SEC:	DS	1		;


; 70-7F COMMON RAM
PSECT	udata_acs

LCDTEMP1:	DS	    1
LCDICON:	DS	    1		;0 = CAL, 
					;1 = LOBAT
TEMP:		DS	    1		;
CODE1:		DS	    1		; 0= 1= wakeup and work, 0= go back to sleep
					; 1= Display adjust mode set by powering up with up arrow pressed
					; 2= SLEEP
					; 3= TIME DISPLAY IN PROGRESS
					; 4= 0=UP  1=DOWN
					; 5= 
					; 6= TIMER UPDATE FLAG
					; 7= 
MASK:		DS	    1		; Switch mask for 4 pb switches					
SW_TASK:	DS	    1		; Switch task has been done for this press
RAMP_COUNT:	DS	    1		; Count to change to ramping at 
MINUTE:		DS	    1		;
INTENSITY:	DS	    1		; 5-45 in .1ma increments , 0-42 IN COUNT
INTENSITY_TARGET: DS	    1		; What A/D of signal should match
   
    
    
    
					
; PORT BIT EQUATES
TRISAK		EQU	0x0F		;  
UP_RA0		EQU	0X00		;I A,0 UP SWITCH
ON_OFF_RA1	EQU	0X01		;I A,1 ON / OFF SWITCH  
TIME_RA2	EQU	0X02		;I A,2 TIME SWITCH
DOWN_RA3	EQU	0X03		;I A,3 DOWN SWITCH
COM3_RA4	EQU	0x04		;O A,4 LCD COM3
;		EQU	0x05		;O A,5
HVEN_RA6	EQU	0x06		;O A,6 ENABLE FOR 30V
;		EQU	0x07		;O A,7

TRISBK		EQU	0x01		;  
CURR_RB0	EQU	0x00		;A B,0 AD OF DRIVE SIGNAL
LED_RB1		EQU	0x01		;O B,1 BACKLIGHT OF LCD
;		EQU	0x02		;O B,2 SEGMENT 10
;		EQU	0x03		;O B,3 SEGMENT 11
COM0		EQU	0x04		;O B,4 LCD COM0
COM1		EQU	0x05		;O B,5 LCD COM1
;		EQU	0x06		;O B,6 ICSP CLK
;		EQU	0x07		;O B,7 ICSP DATA

TRISCK		EQU	0x00		; 
SIG_LEVEL_RC0	EQU	0x00		;O C,0 PWM OUTPUT FOR SIGNAL DRIVE LEVEL
SIG_RC1		EQU	0x01		;O C,1 PWM OUTPUT DRIVE SIGNAL
COM2		EQU	0x02		;O C,2 LCD COM2
;		EQU	0x03		;O C,3 SEGMENT 19
;		EQU	0x04		;O C,4 SEGMENT 20
;		EQU	0x05		;O C,5 VLCD3
;		EQU	0x06		;O C,6 VLCD2
;		EQU	0x07		;O C,7 VLCD1

TRISDK		EQU	0x00		;
;		EQU	0x00		;O D,0 SEGMENT 24
;		EQU	0x01		;O D,1 SEGMENT 25
;		EQU	0x02		;O D,2 SEGMENT 26
AMP_PWR_RD3	EQU	0x03		;O D,3 PWR TO OP-AMP AND FOLLOWER
PIEZO_RD4	EQU	0x04		;O D,4 DIFF DRIVE TO PIEZO
PIEZO_RD5	EQU	0x05		;O D,5 DIFF DRIVE TO PIEZO
OUTEN_RD6	EQU	0x06		;O D,6 OUTPUT ENABLE
OUTEN__RD7	EQU	0x07		;O D,7 OUTPUT ENABLE INVERSION
		
TRISEK		EQU	0x07		;
CHARGE		EQU	0x00		;I E,0 CHARGE VOLTAGE PRESENT
_STAT1_RE1	EQU	0x01		;I E,1 CHARGING
_STAT2_RE2	EQU	0x02		;I E,2 FINISHED CHARGING
;		EQU	0x03		;MASTER CLEAR PIN
		
PSECT resetVec,class=CODE,delta=2
	;PSECT	SPACE_CODE
resetVec:
	PAGESEL main
	goto    main
		
		


;***************************************************************
PSECT	code ;,class=CODE,delta=2  ;space=SPACE_CODE,
main:
	goto	PWRUP		; STARTING POINT
	nop 
	nop 
	nop
INTERUPT_VEC:
	BANKSEL	PORTA
	btfsc	BANKMASK(PORTA), ON_OFF_RA1	; See if the on/off switch is pressed
	retfie
	bsf	BANKMASK(CODE1), 0	; Set a flag to be read on return for power-up
	retfie





TURN_OFF:
	call	SOUND_DOWN			;
	BANKSEL	PIR8				;
	bcf	BANKMASK(PIR8), PIR8_LCDIF_POSN
	nop					;
LCDT:
	BTFSS	BANKMASK(PIR8), PIR8_LCDIF_POSN	;
	bra	LCDT				;
	BANKSEL	T2TMR				;
	movlw	72				;
	movwf	BANKMASK(T2TMR)			;
;	call	DELAY1				;
	nop					;
	BANKSEL	LCDCON				;
	bcf	BANKMASK(LCDCON), LCDCON_LCDEN_POSN ;
	BANKSEL	BANKMASK(PORTA)
TURN_OFF1:
	BANKSEL	PIE0
	movlw	0x10				; IOCIE 
	movwf	BANKMASK(PIE0)			;
	movlw	0xC0				; GLOBAL INTERRUPT AND PERIPHERAL
	movwf	BANKMASK(INTCON)		;
	BANKSEL	PORTA				;
	sleep					;
	nop					; COMES AWAKE HERE ON SWITCH CHANGE
	btfss	BANKMASK(CODE1), 0		; WAS THERE AN ON/OFF SWITCH?
	bra	TURN_OFF				;
	goto	PWRUP				;


		

KEYSCAN:				; *** THIS SCANS KEYS AND TAKES ACTION ***
	BANKSEL	PORTA
	call	UP
	call	DOWN
	call	TIME
	call	ON_OFF
	return
UP:
	btfss	BANKMASK(PORTA), UP_RA0
	bra	UP_FIRST
	bcf	BANKMASK(MASK), UP_RA0
	bcf	BANKMASK(SW_TASK), UP_RA0
	movlw	5
	movwf	BANKMASK(RAMP_COUNT)
	retfie					; Switch up, all flags reset
UP_FIRST:	
	btfsc	BANKMASK(MASK), UP_RA0		; Test mask, if not set, set and return, if set act
	bra	UP_DO
	bsf	BANKMASK(MASK), UP_RA0		;
	return
UP_DO:
	btfsc	BANKMASK(SW_TASK), UP_RA0	;
	goto	RAMP_
	bsf	BANKMASK(SW_TASK), UP_RA0	;
	btfsc	BANKMASK(CODE1), 1		;Contrast or Time by 5 minutes
	bra	CONTRAST_UP			;
	btfss	BANKMASK(MASK), TIME_RA2	; If time is being held
	bra	INTENSITY_UP
	movlw	30				; Maximum time allowed
	subwf	BANKMASK(MINUTE), w
	btfsc	STATUS, STATUS_Z_POSN
	return
	movlw	5
	addwf	BANKMASK(MINUTE)
	return
	
CONTRAST_UP:
	BANKSEL	LCDREF
	movlw	7
	subwf	BANKMASK(LCDREF), w
	btfsc	STATUS, STATUS_Z_POSN
	return
	incf	BANKMASK(LCDREF)
	call	SAVE_LCDREF	    ;
	BANKSEL PORTA
	return
INTENSITY_UP:
	movlw	45
	subwf	BANKMASK(INTENSITY), w
	btfsc	STATUS, STATUS_Z_POSN
	return
	incf	BANKMASK(INTENSITY)
	return

RAMP_:
	decfsz	BANKMASK(RAMP_COUNT)
	retfie
	bcf	BANKMASK(SW_TASK), UP_RA0
	bcf	BANKMASK(SW_TASK), DOWN_RA3
	movlw	3
	movwf	BANKMASK(RAMP_COUNT)
	btfss	BANKMASK(MASK), UP_RA0
	bra	DOWN_DO
	bra	UP_DO
	
DOWN:
	btfss	BANKMASK(PORTA), DOWN_RA3
	bra	DOWN_FIRST
	bcf	BANKMASK(MASK), DOWN_RA3
	bcf	BANKMASK(SW_TASK), DOWN_RA3
	retfie					; Switch up, all flags reset
DOWN_FIRST:	
	btfsc	BANKMASK(MASK), DOWN_RA3		; Test mask, if not set, set and return, if set act
	bra	DOWN_DO
	bsf	BANKMASK(MASK), DOWN_RA3		;
	return
DOWN_DO:
	btfsc	BANKMASK(SW_TASK), DOWN_RA3	;
	goto	RAMP_
	bsf	BANKMASK(SW_TASK), DOWN_RA3	;
	btfsc	BANKMASK(CODE1), 1		;Contrast or Time by 5 minutes
	bra	CONTRAST_DOWN			;
	btfss	BANKMASK(MASK), TIME_RA2	; If time is being held
	bra	INTENSITY_DOWN
	movf	BANKMASK(MINUTE), f
	btfsc	STATUS, STATUS_Z_POSN
	return
	decf	BANKMASK(MINUTE)
	return
	
CONTRAST_DOWN:
	BANKSEL	LCDREF
	movf	BANKMASK(LCDREF), f
	btfsc	STATUS, STATUS_Z_POSN
	return
	decf	BANKMASK(LCDREF)
	call	SAVE_LCDREF	    ;
	BANKSEL PORTA
	return
INTENSITY_DOWN:   
    	movlw	5
	subwf	BANKMASK(INTENSITY), w
	btfsc	STATUS, STATUS_Z_POSN
	return
	decf	BANKMASK(INTENSITY)
	return
    
    
    
    
TIME:
	btfss	BANKMASK(PORTA), TIME_RA2
    	bra	TIME_FIRST
	bcf	BANKMASK(MASK), TIME_RA2
	bcf	BANKMASK(SW_TASK), TIME_RA2
	retfie					; Switch up, all flags reset
TIME_FIRST:	
	btfsc	BANKMASK(MASK), TIME_RA2	; Test mask, if not set, set and return, if set act
	bra	DOWN_DO
	bsf	BANKMASK(MASK), TIME_RA2	;
	return
TIME_DO:
	btfsc	BANKMASK(SW_TASK), TIME_RA2	;
	retfie
	bsf	BANKMASK(SW_TASK), TIME_RA2	;
	
	; Make time what is displayed toggle a flag the determines what is shown in display
	
	
    
ON_OFF:
	btfss	BANKMASK(PORTA), ON_OFF_RA1
		bra	ON_OFF_FIRST
	bcf	BANKMASK(MASK), ON_OFF_RA1
	bcf	BANKMASK(SW_TASK), ON_OFF_RA1
	retfie					; Switch up, all flags reset
ON_OFF_FIRST:	
	btfsc	BANKMASK(MASK), ON_OFF_RA1		; Test mask, if not set, set and return, if set act
	bra	ON_OFF_DO
	bsf	BANKMASK(MASK), ON_OFF_RA1		;
	return
ON_OFF_DO:
	btfsc	BANKMASK(SW_TASK), ON_OFF_RA1	;
	retfie
	bsf	BANKMASK(SW_TASK), ON_OFF_RA1	;
	
	return
	
	
SAVE_LCDREF:
	BANKSEL	LCDREF		    ; MOVE DATA 
    	movf	BANKMASK(LCDREF), w ;	
	BANKSEL	NVMDATL
	movwf	BANKMASK(NVMDATL)    ;
	BANKSEL	NVMADRL		    ; SET ADDRESS
	movlw	70h		    ;
	movwf	BANKMASK(NVMADRH)   ;
	movlw	00h		    ;
	movwf	BANKMASK(NVMADRL)   ;
	
	bcf	GIE	    ; SO SEQUENCE CANNOT BE INTERRUPTED
	BANKSEL	NVMCON1		    ;
	bsf	BANKMASK(NVMCON1), NVMCON1_NVMREGS_POSN    ;
	bsf	BANKMASK(NVMCON1), NVMCON1_WREN_POSN 
	movlw	55h			;
	movwf	BANKMASK(NVMCON2)	;
	movlw	0xAA			;
	movwf	BANKMASK(NVMCON2)	;
	bsf	BANKMASK(NVMCON1), NVMCON1_WR_POSN	;

	bsf	GIE		;
	
	
READ_LCDREF:	
	BANKSEL	NVMADRL		    ; SET ADDRESS
	movlw	70h		    ;
	movwf	BANKMASK(NVMADRH)   ;
	movlw	00h		    ;
	movwf	BANKMASK(NVMADRL)   ;
	bsf	BANKMASK(NVMCON1),NVMCON1_NVMREGS_POSN 
	bsf	BANKMASK(NVMCON1), NVMCON1_RD_POSN
	movf	BANKMASK(NVMDATL), W
	BANKSEL	LCDREF
	movwf	BANKMASK(LCDREF)
	return
	

;*************************************************************
;  THIS IS THE START VECTOR FOR THE PROGRAM. ENTERS FROM 1FF
;  AT RESET.
;*************************************************************

PWRUP:
	BANKSEL	TRISA
	movlw	TRISAK			; SET TRISTATE 
	movwf	BANKMASK(TRISA)		;
	movlw	TRISBK			;
	movwf	BANKMASK(TRISB)		;
	movlw	TRISCK			;
	movwf	BANKMASK(TRISC)		;
	movlw	TRISDK			;
	movwf	BANKMASK(TRISD)		;
	movlw	TRISEK			;
	movwf	BANKMASK(TRISE)		;
	BANKSEL	RC1PPS
	movlw	0x09			;
	movwf	BANKMASK(RC1PPS)	; RC1 TO CCP1
	movlw	0x0A			;
	movwf	BANKMASK(RC0PPS)	; RC0 TO CCP2
	BANKSEL	RD6PPS
	movlw	0x08			;
	movwf	BANKMASK(RD6PPS)	; RD6 TO CWGC
	movlw	0x07			;
	movwf	BANKMASK(RD7PPS)	; RD7 TO CWGD
	BANKSEL	T0CKIPPS
	movwf	0x05			;
	movwf	BANKMASK(T0CKIPPS)	; RA5 INPUT TO TIMER 0
	BANKSEL	PORTA
	movlw	0x1A			; UV OFF, EE ON
	movwf	BANKMASK(PORTA)		;


START1_:
	BANKSEL	T1CON
	movlw	0x01			;
	movwf	BANKMASK(T1CON)		; TIMER 1 ON, FROM FOSC/4 NO PRESCALE
	BANKSEL	PIE1
	movlw	0x01			; TIMER1 ON
	movwf	BANKMASK(PIE1)		;
	BANKSEL	MINUTE

	clrf	BANKMASK(MINUTE)		;
	BANKSEL	TMR1H
	movlw	207			;
	movwf	BANKMASK(TMR1H)			;

	movlw	60			; INITIAL TIMEOUT LOAD
	movwf	BANKMASK(TIMEOUT)		;
	call	LCDINIT			; SET UP THE LCD
	clrf	BANKMASK(MASK)
	clrf	BANKMASK(CODE1)		;
	clrf	BANKMASK(CODE2)		;
	call	READ_LCDREF		; get LCDREF from EEPROM
	bcf	BANKMASK(LCDICON),0	; MAKE ICONS OFF
	bcf	BANKMASK(LCDICON),1	;


	clrf	BANKMASK(PIR8)		;

	movlw	0x50			; RB0, PEIE
	movwf	BANKMASK(INTCON)		;
	nop				;
	bsf	GIE			;INTCON,INTCON_GIE_POSN	; TURN ON INTERRUPTS

START2:
	call	KEYSCAN				;
	btfss	BANKMASK(PORTD),PIEZO_RD4	;
	call	DELAY				;
	bcf	BANKMASK(PORTD),PIEZO_RD4	; STOP A TICK
	btfss	BANKMASK(CODE2),2		; LOOK FOR 1/2 SEC FLAG
	goto	MON1				;
	bcf	BANKMASK(CODE2),2		; CLEAR THE TIME FLAG


MON1:
	call	SOUND_UP	;	
	nop			;
	goto	START2		;

	
	
TARGET:
	movf	BANKMASK(INTENSITY), w	; number from 0-40, 0=.5ma, 40=4.5ma
	call	TARGET1
	movwf	BANKMASK(INTENSITY_TARGET)
	return
	
TARGET1:
	addwf	PCL	
	retlw	19	; deirved, .5ma * 301 ohms *255 / 2V ref
	retlw	23	; expected A/D 8 bit response to .6ma
	retlw	27
	retlw	31
	retlw	35
	retlw	38
	retlw	42
	retlw	46
	retlw	50
	retlw	54
	retlw	58
	retlw	61
	retlw	65
	retlw	69
	retlw	73
	retlw	77
	retlw	81
	retlw	84
	retlw	88
	retlw	92
	retlw	96
	retlw	100
	retlw	104
	retlw	107
	retlw	111
	retlw	115
	retlw	119
	retlw	123
	retlw	127
	retlw	130
	retlw	134
	retlw	138
	retlw	142
	retlw	146
	retlw	150
	retlw	154
	retlw	158
	retlw	162
	retlw	165
	retlw	169
	retlw	173

	


TIME_DIS:
	bcf	BANKMASK(CODE1),6		; UPDATE THE TIME DISPLAY
	movf	BANKMASK(MINUTE),W	;
	call	BINTOB			; BINARY TO BCD
	movlw	0x0F			;
	andwf	BANKMASK(R2),W		;
	call	LOAD_D1			;
	movlw	0x0F			;
	andwf	BANKMASK(R1),W		;
	call	LOAD_D2			;
	BANKSEL	LCDDATA2
	bsf	D3COL			;
	BANKSEL PORTA
	return				;		
	
DELAY:
	nop
	nop
	nop
	nop
	return

;
;********************************************************************
;                  Binary To BCD Conversion Routine
;      This routine converts a 16 Bit binary Number to a 5 Digit
; BCD Number. This routine is useful since PIC16C55 & PIC16C57
; have  two 8 bit ports and one 4 bit port ( total of 5 BCD digits)
;
;       The 16 bit binary number is input in locations H_byte and
; L_byte with the high byte in H_byte.
;       The 5 digit BCD number is returned in R0, R1 and R2 with R0
; containing the MSD in its right most nibble.
;
;   Performance :
;               Program Memory  :       35
;               Clock Cycles    :       885
;
;*******************************************************************;


BINTOB:
	clrf	BANKMASK(H_BYTE)		; ENTRY FOR 8 BITS
B2_BCD:
	movwf	BANKMASK(L_BYTE)		; ENTRY FOR 16 BITS
	bcf     BANKMASK(STATUS),STATUS_C_POSN         ; clear the carry bit
	movlw   16
	movwf   BANKMASK(BCOUNT)
	clrf    BANKMASK(R0)
	clrf    BANKMASK(R1)
	clrf    BANKMASK(R2)
loop16:  rlf     BANKMASK(L_BYTE)
	rlf     BANKMASK(H_BYTE)
	rlf     BANKMASK(R2)
	rlf     BANKMASK(R1)
	rlf     BANKMASK(R0)

	decfsz  BANKMASK(BCOUNT)
	goto    adjDEC
	retlw   0

adjDEC:  movlw   R2
	movwf   BANKMASK(FSR0L)
	call    adjBCD

	movlw   R1
	movwf   BANKMASK(FSR0L)
	call    adjBCD

	movlw   R0
	movwf   BANKMASK(FSR0L)
	call    adjBCD

	goto    loop16

adjBCD:  movlw   3
	addwf   INDF0,W
	movwf   BANKMASK(TEMP)
	btfsc   BANKMASK(TEMP),3          ; test if result > 7
	movwf   INDF0
	movlw   0x30
	addwf   INDF0
	movwf   BANKMASK(TEMP)
	btfsc   BANKMASK(TEMP),7          ; test if result > 7
	movwf   INDF0            ; save as MSD
	retlw   0


;***************************************************************************
; This routine contains the basics for controlling the LCD
;	movlw	6	(value to be displayed)
;	call	LoadD3	(LCD digit to display it on)
;			(this example 3)
;
; Written by Stan D'Souza  4/12/98.  For presentations using the
; PICDEM3 board with asm firmware

;***************************************************************************
; Initializes the LCD module to drive the LCD
;***************************************************************************
; Inputs: none
; Ouputs: none

LCDINIT:
	BANKSEL	LCDCON			;
	movlw	0xC8			;b'11000100' operates in sleep, 1/4 mux, 1/3 bias, internal RC osc, 
	movwf	BANKMASK(LCDCON)	; init lcd control register, internal voltage generator not used
					; 1/4 mux,
	movlw	0x83			; TYPE B DRIVE, PRESCALER 
	movwf	BANKMASK(LCDPS)		;
	movlw	0x0C			; DEFINE WHICH SEGMENTS ARE ACTIVE
	movwf	BANKMASK(LCDSE1)	; SEGMENTS 10 AND 11
	movlw	0x18			; 
	movwf	BANKMASK(LCDSE2)	; SEGMENTS 19 AND 20
	movlw	0x07			;
	movwf	BANKMASK(LCDSE3)	; SEGMENTS 24, 25 AND 26
	call	ClrLCD			;
	
	return	

;***************************************************************************
; Clears all LCD pixels (blanks the display)
;***************************************************************************
; Inputs: none
; Ouputs: none

ClrLCD:
	BANKSEL	LCDCON			;
	clrf	BANKMASK(LCDDATA1)	; clear all LCD ram locations
	clrf	BANKMASK(LCDDATA2)
	clrf	BANKMASK(LCDDATA3)
	clrf	BANKMASK(LCDDATA7)
	clrf	BANKMASK(LCDDATA8)
	clrf	BANKMASK(LCDDATA9)
	clrf	BANKMASK(LCDDATA13)
	clrf	BANKMASK(LCDDATA14)
	clrf	BANKMASK(LCDDATA15)
	clrf	BANKMASK(LCDDATA19)
	clrf	BANKMASK(LCDDATA20)
	clrf	BANKMASK(LCDDATA21)
	BANKSEL	PORTA	
	return

SSEG:
	movwf	BANKMASK(TEMP)		;
	movlw	HIGH BANKMASK(SSEG)	;
	movwf	BANKMASK(PCLATH)		;
	movf	BANKMASK(TEMP),W		;
	andlw	0x0F		;MASK OFF UPPER NIBBLE
TBL1:	addwf	BANKMASK(PCL)		;ABCDEFGDp = 01234567 BIT POSITIONS
	retlw	03FH		;0
	retlw	006H		;1				5
	retlw	05BH		;2
	retlw	04FH		;3
	retlw	066H		;4
	retlw	06DH		;5
	retlw	07DH		;6
	retlw	007H		;7
	retlw	07FH		;8
	retlw	06FH		;9
	retlw	03FH		;A 0	00111111
	retlw	05CH		;B o	01011100
	retlw	054H		;C n	01010100
	retlw	071H		;D F	01110001
	retlw	00		;E	
	retlw	00		;F	



;***************************************************************************
; Each "LoadDx" accepts data in the W register,
; calls SSEG table, and displays the segment data returned on the LCD
; display.
;***************************************************************************
; Inputs: W register
; Ouputs: none
; Uses:   LCDTEMP1

LOAD_D1:				; Write to LCD digit 1 (left side)
	call	SSEG		; get seven segment data in w
	movwf	BANKMASK(LCDTEMP1)	; save in temp
	BANKSEL	LCDCON
	bcf	D1A
	bcf	D1B
	bcf	D1C
	bcf	D1D
	bcf	D1E
	bcf	D1F
	bcf	D1G
	bcf	D1DP
	btfsc	BANKMASK(LCDTEMP1),0	; if not set, skip segment
	bsf	D1A
	btfsc	BANKMASK(LCDTEMP1),1
	bsf	D1B
	btfsc	BANKMASK(LCDTEMP1),2
	bsf	D1C
	btfsc	BANKMASK(LCDTEMP1),3
	bsf	D1D
	btfsc	BANKMASK(LCDTEMP1),4
	bsf	D1E
	btfsc	BANKMASK(LCDTEMP1),5
	bsf	D1F
	btfsc	BANKMASK(LCDTEMP1),6
	bsf	D1G
	BANKSEL	PORTA
	return

LOAD_D2:				; Write to LCD digit 2
	call	SSEG		; get seven segment data in w
	movwf	BANKMASK(LCDTEMP1)	; save in temp
	BANKSEL	LCDCON
	bcf	D2A
	bcf	D2B
	bcf	D2C
	bcf	D2D
	bcf	D2E
	bcf	D2F
	bcf	D2G
	BCF	D2DP		;
	btfsc	BANKMASK(LCDTEMP1),0	; if not set, skip segment
	bsf	D2A
	btfsc	BANKMASK(LCDTEMP1),1
	bsf	D2B
	btfsc	BANKMASK(LCDTEMP1),2
	bsf	D2C
	btfsc	BANKMASK(LCDTEMP1),3
	bsf	D2D
	btfsc	BANKMASK(LCDTEMP1),4
	bsf	D2E
	btfsc	BANKMASK(LCDTEMP1),5
	bsf	D2F
	btfsc	BANKMASK(LCDTEMP1),6
	bsf	D2G
	BANKSEL	PORTA
	return


LOAD_D3:				; Write to LCD digit 3
	call	SSEG		; get seven segment data in w
	movwf	BANKMASK(LCDTEMP1)	; save in temp
	BANKSEL	LCDCON
	bcf	D3A
	bcf	D3B
	bcf	D3C
	bcf	D3D
	bcf	D3E
	bcf	D3F
	bcf	D3G
	BCF	D3COL		;
	btfsc	BANKMASK(LCDTEMP1),0	; if not set, skip segment
	bsf	D3A
	btfsc	BANKMASK(LCDTEMP1),1
	bsf	D3B
	btfsc	BANKMASK(LCDTEMP1),2
	bsf	D3C
	btfsc	BANKMASK(LCDTEMP1),3
	bsf	D3D
	btfsc	BANKMASK(LCDTEMP1),4
	bsf	D3E
	btfsc	BANKMASK(LCDTEMP1),5
	bsf	D3F
	btfsc	BANKMASK(LCDTEMP1),6
	bsf	D3G
	BANKSEL	PORTA
	return




LAMPTEST:
	BANKSEL	LCDCON
	movlw	0xFF		;
	movwf	BANKMASK(LCDDATA1)	;
	movwf	BANKMASK(LCDDATA2)	;
	movwf	BANKMASK(LCDDATA3)	;
	movwf	BANKMASK(LCDDATA7)	;
	movwf	BANKMASK(LCDDATA8)	;
	movwf	BANKMASK(LCDDATA9)	;
	movwf	BANKMASK(LCDDATA13)	;
	movwf	BANKMASK(LCDDATA14)	;
	movwf	BANKMASK(LCDDATA15)	;
	movwf	BANKMASK(LCDDATA19)	;
	movwf	BANKMASK(LCDDATA20)	;
	movwf	BANKMASK(LCDDATA21)	;
	BANKSEL	PORTA
	movlw	4		;
	movwf	BANKMASK(TEMP)		;
LTEST:
	BANKSEL	TMR1H		;
	btfss	BANKMASK(TMR1H),7		;
	goto	LTEST		;
	bcf	BANKMASK(TMR1H),7		;
	decfsz	BANKMASK(TEMP)		;
	goto	LTEST		;
	BANKSEL	PORTA	;
	return			;

; Sound routines *********************************************************************

 
SOUND_UP:
    	BANKSEL	PORTA		;
	bsf	BANKMASK(PORTD),PIEZO_RD4
	nop
	bcf	BANKMASK(PORTD),PIEZO_RD5
	BANKSEL	FREQ
	call	GET_GL		;
	call	GET_B		;
	call	GET_D		;
	call	GET_GH		;
	return			;	

SOUND_DOWN:
	BANKSEL	PORTA		;
	bsf	BANKMASK(PORTD),PIEZO_RD4
	nop
	bcf	BANKMASK(PORTD),PIEZO_RD5
	BANKSEL	FREQ
	call	GET_GH		;
	call	GET_D		;
	call	GET_B		;
	call	GET_GL		;
	return			;
GET_GL:
	movlw	252		; G
	movwf	BANKMASK(FREQ)		;
	movlw	160		;80
	movwf	BANKMASK(DURA)		;
	call	TMON		;
	return
GET_B:
	movlw	192		;
	movwf	BANKMASK(FREQ)		;
	movlw	165		;
	movwf	BANKMASK(DURA)		;
	call	TMON		;
	return			;
GET_D:
	movlw	168		;
	movwf	BANKMASK(FREQ)		;
	movlw	170		;
	movwf	BANKMASK(DURA)		;
	call	TMON		;
	return			;
GET_GH:
	movlw	126		    ;
	movwf	BANKMASK(FREQ)	    ;
	movlw	180		    ;
	movwf	BANKMASK(DURA)	    ;
	call	TMON		    ;
	return
TMON:
	movf	BANKMASK(FREQ),W	;
	movwf	BANKMASK(TEMP5)		;	
	BTFSS	STATUS, STATUS_Z_POSN	;
	movlw	0x30			; prepare to toggle pins
	xorwf	BANKMASK(PORTD)
TMO2:
	call	S_DELAY			; DO SOUND DELAY
	movlw	0x30			; prepare to toggle pins
	xorwf	BANKMASK(PORTD)
	movf	BANKMASK(FREQ),W	;				
	movwf	BANKMASK(TEMP5)		;
TMO3:
	call	S_DELAY			;
	decfsz	BANKMASK(DURA)		;
	goto	TMON			;
	return				;

S_DELAY:

	NOP			;
	goto	$+1		;
	goto	$+1		;
	goto	$+1		;
	goto	$+1		;
	goto	$+1		;
	goto	$+1		;
	goto	$+1		;
	decfsz	BANKMASK(TEMP5)	;
	goto	S_DELAY		;
	return			;	
	
	
        END	resetVec




	
	