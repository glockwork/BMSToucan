
_main:

;BMSToucan.c,56 :: 		void main() {
;BMSToucan.c,58 :: 		setup();
	CALL        _setup+0, 0
;BMSToucan.c,61 :: 		for(;;)
L_main0:
;BMSToucan.c,64 :: 		reset_candata();
	CALL        _reset_candata+0, 0
;BMSToucan.c,67 :: 		if (flag_ovp) {
	MOVF        _flag_ovp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main3
;BMSToucan.c,70 :: 		}
L_main3:
;BMSToucan.c,71 :: 		if (flag_lvp) {
	MOVF        _flag_lvp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main4
;BMSToucan.c,74 :: 		}
L_main4:
;BMSToucan.c,75 :: 		if (flag_check_bms) {
	MOVF        _flag_check_bms+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main5
;BMSToucan.c,78 :: 		}
L_main5:
;BMSToucan.c,79 :: 		}
	GOTO        L_main0
;BMSToucan.c,80 :: 		}
L_end_main:
	GOTO        $+0
; end of _main

_ISR:

;BMSToucan.c,88 :: 		void ISR() iv 0x0008
;BMSToucan.c,93 :: 		if (INTCON3.INT1IF == 1)
	BTFSS       INTCON3+0, 0 
	GOTO        L_ISR6
;BMSToucan.c,95 :: 		flag_ovp = 1;
	MOVLW       1
	MOVWF       _flag_ovp+0 
;BMSToucan.c,96 :: 		INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON3+0, 0 
;BMSToucan.c,97 :: 		}
	GOTO        L_ISR7
L_ISR6:
;BMSToucan.c,98 :: 		else if (INTCON.INT0IF == 1)
	BTFSS       INTCON+0, 1 
	GOTO        L_ISR8
;BMSToucan.c,101 :: 		flag_lvp = 1;
	MOVLW       1
	MOVWF       _flag_lvp+0 
;BMSToucan.c,102 :: 		INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON+0, 1 
;BMSToucan.c,103 :: 		}
	GOTO        L_ISR9
L_ISR8:
;BMSToucan.c,104 :: 		else if (INTCON.T0IF == 1)
	BTFSS       INTCON+0, 2 
	GOTO        L_ISR10
;BMSToucan.c,107 :: 		tx_counter++;
	MOVLW       1
	ADDWF       _tx_counter+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      _tx_counter+1, 0 
	MOVWF       R1 
	MOVF        R0, 0 
	MOVWF       _tx_counter+0 
	MOVF        R1, 0 
	MOVWF       _tx_counter+1 
;BMSToucan.c,108 :: 		if(tx_counter > COUNTER_OVERFLOW)
	MOVF        _tx_counter+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__ISR18
	MOVF        _tx_counter+0, 0 
	SUBLW       100
L__ISR18:
	BTFSC       STATUS+0, 0 
	GOTO        L_ISR11
;BMSToucan.c,110 :: 		flag_check_bms = 1;
	MOVLW       1
	MOVWF       _flag_check_bms+0 
;BMSToucan.c,111 :: 		tx_counter = 0;
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,112 :: 		}
L_ISR11:
;BMSToucan.c,113 :: 		INTCON.T0IF = 0; // reset the TMR0 interrupt flag
	BCF         INTCON+0, 2 
;BMSToucan.c,114 :: 		}
L_ISR10:
L_ISR9:
L_ISR7:
;BMSToucan.c,115 :: 		}
L_end_ISR:
L__ISR17:
	RETFIE      1
; end of _ISR

_CANbus_setup:

;BMSToucan.c,127 :: 		void CANbus_setup()
;BMSToucan.c,150 :: 		CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
	MOVLW       1
	MOVWF       FARG_CANInitialize_SJW+0 
	MOVLW       1
	MOVWF       FARG_CANInitialize_BRP+0 
	MOVLW       6
	MOVWF       FARG_CANInitialize_PHSEG1+0 
	MOVLW       7
	MOVWF       FARG_CANInitialize_PHSEG2+0 
	MOVLW       6
	MOVWF       FARG_CANInitialize_PROPSEG+0 
	MOVLW       185
	MOVWF       FARG_CANInitialize_CAN_CONFIG_FLAGS+0 
	CALL        _CANInitialize+0, 0
;BMSToucan.c,154 :: 		CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);
	MOVLW       128
	MOVWF       FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,156 :: 		mask = -1;
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+0 
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+1 
	MOVWF       CANbus_setup_mask_L0+2 
	MOVWF       CANbus_setup_mask_L0+3 
;BMSToucan.c,159 :: 		CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
	CLRF        FARG_CANSetMask_CAN_MASK+0 
	MOVLW       255
	MOVWF       FARG_CANSetMask_val+0 
	MOVLW       255
	MOVWF       FARG_CANSetMask_val+1 
	MOVLW       255
	MOVWF       FARG_CANSetMask_val+2 
	MOVLW       255
	MOVWF       FARG_CANSetMask_val+3 
	MOVLW       255
	MOVWF       FARG_CANSetMask_CAN_CONFIG_FLAGS+0 
	CALL        _CANSetMask+0, 0
;BMSToucan.c,162 :: 		CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
	MOVLW       1
	MOVWF       FARG_CANSetMask_CAN_MASK+0 
	MOVF        CANbus_setup_mask_L0+0, 0 
	MOVWF       FARG_CANSetMask_val+0 
	MOVF        CANbus_setup_mask_L0+1, 0 
	MOVWF       FARG_CANSetMask_val+1 
	MOVF        CANbus_setup_mask_L0+2, 0 
	MOVWF       FARG_CANSetMask_val+2 
	MOVF        CANbus_setup_mask_L0+3, 0 
	MOVWF       FARG_CANSetMask_val+3 
	MOVLW       255
	MOVWF       FARG_CANSetMask_CAN_CONFIG_FLAGS+0 
	CALL        _CANSetMask+0, 0
;BMSToucan.c,166 :: 		CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);
	CLRF        FARG_CANSetFilter_CAN_FILTER+0 
	MOVLW       2
	MOVWF       FARG_CANSetFilter_val+0 
	MOVLW       2
	MOVWF       FARG_CANSetFilter_val+1 
	MOVLW       0
	MOVWF       FARG_CANSetFilter_val+2 
	MOVWF       FARG_CANSetFilter_val+3 
	MOVLW       255
	MOVWF       FARG_CANSetFilter_CAN_CONFIG_FLAGS+0 
	CALL        _CANSetFilter+0, 0
;BMSToucan.c,168 :: 		CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);
	MOVLW       1
	MOVWF       FARG_CANSetFilter_CAN_FILTER+0 
	MOVLW       80
	MOVWF       FARG_CANSetFilter_val+0 
	MOVLW       0
	MOVWF       FARG_CANSetFilter_val+1 
	MOVWF       FARG_CANSetFilter_val+2 
	MOVWF       FARG_CANSetFilter_val+3 
	MOVLW       255
	MOVWF       FARG_CANSetFilter_CAN_CONFIG_FLAGS+0 
	CALL        _CANSetFilter+0, 0
;BMSToucan.c,172 :: 		CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
	CLRF        FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,173 :: 		}/* The CANbus is now set up and ready for use  */
L_end_CANbus_setup:
	RETURN      0
; end of _CANbus_setup

_reset_candata:

;BMSToucan.c,179 :: 		void reset_candata()
;BMSToucan.c,182 :: 		for (i = 0; i < 8; i++)
	CLRF        R1 
	CLRF        R2 
L_reset_candata12:
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__reset_candata21
	MOVLW       8
	SUBWF       R1, 0 
L__reset_candata21:
	BTFSC       STATUS+0, 0 
	GOTO        L_reset_candata13
;BMSToucan.c,184 :: 		CAN_data[i] = 0;
	MOVLW       _CAN_data+0
	ADDWF       R1, 0 
	MOVWF       FSR1L 
	MOVLW       hi_addr(_CAN_data+0)
	ADDWFC      R2, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;BMSToucan.c,182 :: 		for (i = 0; i < 8; i++)
	INFSNZ      R1, 1 
	INCF        R2, 1 
;BMSToucan.c,185 :: 		}
	GOTO        L_reset_candata12
L_reset_candata13:
;BMSToucan.c,186 :: 		}
L_end_reset_candata:
	RETURN      0
; end of _reset_candata

_setup:

;BMSToucan.c,193 :: 		void setup()
;BMSToucan.c,196 :: 		TRISA = 0; // default PORTA to output
	CLRF        TRISA+0 
;BMSToucan.c,197 :: 		TRISB = 0; // default PORTB to output
	CLRF        TRISB+0 
;BMSToucan.c,198 :: 		TRISC = 0; // default PORTC to output
	CLRF        TRISC+0 
;BMSToucan.c,201 :: 		INTCON.GIE = 1;    // enable global interrupts
	BSF         INTCON+0, 7 
;BMSToucan.c,202 :: 		INTCON.PEIE = 1;   // enable peripheral interrupts
	BSF         INTCON+0, 6 
;BMSToucan.c,203 :: 		INTCON.TMR0IE = 1; // enable timer 0 interrupts to control
	BSF         INTCON+0, 5 
;BMSToucan.c,205 :: 		INTCON2.RBPU = 1;  // disable pull ups on PORTB
	BSF         INTCON2+0, 7 
;BMSToucan.c,206 :: 		INTCON2.INTEDG0 = 1; // interrupt INT0 on rising edge
	BSF         INTCON2+0, 6 
;BMSToucan.c,207 :: 		INTCON2.INTEDG1 = 1; // interrupt INT1 on rising edge
	BSF         INTCON2+0, 5 
;BMSToucan.c,208 :: 		INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
	BSF         INTCON2+0, 2 
;BMSToucan.c,209 :: 		INTCON3.INT2IE = 0; // disable INT2
	BCF         INTCON3+0, 4 
;BMSToucan.c,210 :: 		INTCON3.INT1IE = 1; // enable INT1
	BSF         INTCON3+0, 3 
;BMSToucan.c,211 :: 		INTCON.INT0IE = 1; // enable INT0
	BSF         INTCON+0, 4 
;BMSToucan.c,214 :: 		RCSTA.SPEN = 1; // enable the serial port
	BSF         RCSTA+0, 7 
;BMSToucan.c,215 :: 		RCSTA.RX9 = 0; // 8 bit mode
	BCF         RCSTA+0, 6 
;BMSToucan.c,216 :: 		TXSTA.SYNC = 0; // start in asynchronous mode
	BCF         TXSTA+0, 4 
;BMSToucan.c,217 :: 		TRISC.B7 = 1; // set the RX bit to output
	BSF         TRISC+0, 7 
;BMSToucan.c,220 :: 		TXSTA.BRGH = 1; // High speed serial
	BSF         TXSTA+0, 2 
;BMSToucan.c,221 :: 		SPBRG = 64; // set the baud to 20Mhz / 19200 baud
	MOVLW       64
	MOVWF       SPBRG+0 
;BMSToucan.c,224 :: 		TRISB.B3 = 1; // set CANRX for outputting transmission
	BSF         TRISB+0, 3 
;BMSToucan.c,225 :: 		TRISB.B2 = 0; // clear CANTX for inputting signal
	BCF         TRISB+0, 2 
;BMSToucan.c,228 :: 		T0CON.TMR0ON = 1; // turn on timer 0
	BSF         T0CON+0, 7 
;BMSToucan.c,229 :: 		T0CON.T08BIT = 0; // set up as a 16 bit timer
	BCF         T0CON+0, 6 
;BMSToucan.c,230 :: 		T0CON.T0CS = 0; // use CLK0 as the timing signal
	BCF         T0CON+0, 5 
;BMSToucan.c,231 :: 		T0CON.PSA = 0; // do not use the prescaler
	BCF         T0CON+0, 3 
;BMSToucan.c,232 :: 		T0CON.T0PS2 = 1; // set the prescaler to 1:256
	BSF         T0CON+0, 2 
;BMSToucan.c,233 :: 		T0CON.T0PS1 = 1; // this gives us an overflow of TMR0 every 0xFFFF * 256
	BSF         T0CON+0, 1 
;BMSToucan.c,234 :: 		T0CON.T0PS0 = 1; // clock cycles (at 20Mhz)
	BSF         T0CON+0, 0 
;BMSToucan.c,237 :: 		CANbus_setup();
	CALL        _CANbus_setup+0, 0
;BMSToucan.c,240 :: 		tx_counter = 0; // reset the transmit counter
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,241 :: 		flag_ovp = 0; // no ovp problem
	CLRF        _flag_ovp+0 
;BMSToucan.c,242 :: 		flag_lvp = 0; // no lvp problem
	CLRF        _flag_lvp+0 
;BMSToucan.c,243 :: 		flag_check_bms = 0; // don't check BMS
	CLRF        _flag_check_bms+0 
;BMSToucan.c,244 :: 		current_cell = 1; // start by querying cell #1
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,245 :: 		}
L_end_setup:
	RETURN      0
; end of _setup
