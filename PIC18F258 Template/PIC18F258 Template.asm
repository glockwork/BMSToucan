
_main:

;PIC18F258 Template.c,13 :: 		void main() {
;PIC18F258 Template.c,14 :: 		setup();
	CALL        _setup+0, 0
;PIC18F258 Template.c,15 :: 		interrupt_setup();
	CALL        _interrupt_setup+0, 0
;PIC18F258 Template.c,16 :: 		PORTC.B6 = 1;
	BSF         PORTC+0, 6 
;PIC18F258 Template.c,17 :: 		while(1)
L_main0:
;PIC18F258 Template.c,19 :: 		if(flag_timer_overflow == 0xFF)
	MOVF        _flag_timer_overflow+0, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main2
;PIC18F258 Template.c,21 :: 		PORTC.B6 = (PORTC.B6 == 1) ? 0 : 1;
	BTFSS       PORTC+0, 6 
	GOTO        L_main3
	CLRF        R0 
	GOTO        L_main4
L_main3:
	MOVLW       1
	MOVWF       R0 
L_main4:
	BTFSC       R0, 0 
	GOTO        L__main8
	BCF         PORTC+0, 6 
	GOTO        L__main9
L__main8:
	BSF         PORTC+0, 6 
L__main9:
;PIC18F258 Template.c,22 :: 		flag_timer_overflow = 0;
	CLRF        _flag_timer_overflow+0 
;PIC18F258 Template.c,23 :: 		}
L_main2:
;PIC18F258 Template.c,24 :: 		};
	GOTO        L_main0
;PIC18F258 Template.c,25 :: 		}
L_end_main:
	GOTO        $+0
; end of _main

_setup:

;PIC18F258 Template.c,28 :: 		void setup()
;PIC18F258 Template.c,31 :: 		TRISA = 0;
	CLRF        TRISA+0 
;PIC18F258 Template.c,32 :: 		TRISB = 0;
	CLRF        TRISB+0 
;PIC18F258 Template.c,33 :: 		TRISC = 0;
	CLRF        TRISC+0 
;PIC18F258 Template.c,36 :: 		T0CON.TMR0ON = 1; // turn on timer 0
	BSF         T0CON+0, 7 
;PIC18F258 Template.c,37 :: 		T0CON.T08BIT = 1; // set up as an 8 bit timer
	BSF         T0CON+0, 6 
;PIC18F258 Template.c,38 :: 		T0CON.T0CS = 0; // use instruction clock cycle as the timing signal, not TOCKI
	BCF         T0CON+0, 5 
;PIC18F258 Template.c,39 :: 		T0CON.PSA = 0; // use the prescaler
	BCF         T0CON+0, 3 
;PIC18F258 Template.c,40 :: 		T0CON |= 0b00000111; // set the prescaler to 1:256 this gives us an
	MOVLW       7
	IORWF       T0CON+0, 1 
;PIC18F258 Template.c,45 :: 		interrupt_setup();
	CALL        _interrupt_setup+0, 0
;PIC18F258 Template.c,48 :: 		flag_timer_overflow = 0;
	CLRF        _flag_timer_overflow+0 
;PIC18F258 Template.c,49 :: 		timer_count = 0;
	CLRF        _timer_count+0 
	CLRF        _timer_count+1 
;PIC18F258 Template.c,50 :: 		}
L_end_setup:
	RETURN      0
; end of _setup

_interrupt_setup:

;PIC18F258 Template.c,53 :: 		void interrupt_setup()
;PIC18F258 Template.c,56 :: 		INTCON.GIE = 1;    // enable global interrupts
	BSF         INTCON+0, 7 
;PIC18F258 Template.c,57 :: 		INTCON.TMR0IE = 1; // enable timer 0 interrupts
	BSF         INTCON+0, 5 
;PIC18F258 Template.c,58 :: 		INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
	BSF         INTCON2+0, 2 
;PIC18F258 Template.c,59 :: 		}
L_end_interrupt_setup:
	RETURN      0
; end of _interrupt_setup

_ISR:

;PIC18F258 Template.c,62 :: 		void ISR() iv 0x0008
;PIC18F258 Template.c,64 :: 		if (INTCON.T0IF == 1)
	BTFSS       INTCON+0, 2 
	GOTO        L_ISR5
;PIC18F258 Template.c,66 :: 		timer_count++;
	INFSNZ      _timer_count+0, 1 
	INCF        _timer_count+1, 1 
;PIC18F258 Template.c,67 :: 		if (timer_count > MAX_OVERFLOWS)
	MOVF        _timer_count+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__ISR14
	MOVF        _timer_count+0, 0 
	SUBLW       76
L__ISR14:
	BTFSC       STATUS+0, 0 
	GOTO        L_ISR6
;PIC18F258 Template.c,69 :: 		flag_timer_overflow = 0xFF;
	MOVLW       255
	MOVWF       _flag_timer_overflow+0 
;PIC18F258 Template.c,70 :: 		timer_count = 0;
	CLRF        _timer_count+0 
	CLRF        _timer_count+1 
;PIC18F258 Template.c,71 :: 		}
L_ISR6:
;PIC18F258 Template.c,72 :: 		INTCON.T0IF = 0;
	BCF         INTCON+0, 2 
;PIC18F258 Template.c,73 :: 		}
L_ISR5:
;PIC18F258 Template.c,74 :: 		}
L_end_ISR:
L__ISR13:
	RETFIE      1
; end of _ISR
