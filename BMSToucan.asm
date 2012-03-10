
_main:

;BMSToucan.c,63 :: 		void main() {
;BMSToucan.c,65 :: 		setup();
	CALL        _setup+0, 0
;BMSToucan.c,68 :: 		for(;;)
L_main0:
;BMSToucan.c,71 :: 		reset_candata();
	CALL        _reset_candata+0, 0
;BMSToucan.c,74 :: 		if (flag_ovp) {
	MOVF        _flag_ovp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main3
;BMSToucan.c,76 :: 		CAN_data[OVP_BIT] = 0x01;
	MOVLW       1
	MOVWF       _CAN_data+6 
;BMSToucan.c,77 :: 		}
L_main3:
;BMSToucan.c,78 :: 		if (flag_lvp) {
	MOVF        _flag_lvp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main4
;BMSToucan.c,80 :: 		CAN_data[LVP_BIT] = 0x01;
	MOVLW       1
	MOVWF       _CAN_data+5 
;BMSToucan.c,81 :: 		}
L_main4:
;BMSToucan.c,82 :: 		if (flag_check_bms) {
	MOVF        _flag_check_bms+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main5
;BMSToucan.c,84 :: 		current_cell++; // move to the next cell
	INFSNZ      _current_cell+0, 1 
	INCF        _current_cell+1, 1 
;BMSToucan.c,85 :: 		if(current_cell > NUMBER_OF_CELLS)
	MOVLW       128
	XORLW       0
	MOVWF       R0 
	MOVLW       128
	XORWF       _current_cell+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main17
	MOVF        _current_cell+0, 0 
	SUBLW       18
L__main17:
	BTFSC       STATUS+0, 0 
	GOTO        L_main6
;BMSToucan.c,87 :: 		current_cell = 1; // move back to the first cell
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,88 :: 		}
L_main6:
;BMSToucan.c,91 :: 		UART1_Write(BMS_QUERY_BIT_1);
	MOVLW       129
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,92 :: 		UART1_Write(BMS_QUERY_BIT_2);
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,95 :: 		UART1_Write(current_cell);
	MOVF        _current_cell+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,96 :: 		UART1_Write(current_cell);
	MOVF        _current_cell+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,98 :: 		}
L_main5:
;BMSToucan.c,101 :: 		CanWrite(CAN_ADDRESS, CAN_data, 1, SEND_FLAG);
	MOVLW       136
	MOVWF       FARG_CANWrite_id+0 
	MOVLW       0
	MOVWF       FARG_CANWrite_id+1 
	MOVLW       0
	MOVWF       FARG_CANWrite_id+2 
	MOVLW       0
	MOVWF       FARG_CANWrite_id+3 
	MOVLW       _CAN_data+0
	MOVWF       FARG_CANWrite_data_+0 
	MOVLW       hi_addr(_CAN_data+0)
	MOVWF       FARG_CANWrite_data_+1 
	MOVLW       1
	MOVWF       FARG_CANWrite_DataLen+0 
	MOVLW       252
	MOVWF       FARG_CANWrite_CAN_TX_MSG_FLAGS+0 
	CALL        _CANWrite+0, 0
;BMSToucan.c,102 :: 		}
	GOTO        L_main0
;BMSToucan.c,103 :: 		}
L_end_main:
	GOTO        $+0
; end of _main

_ISR:

;BMSToucan.c,111 :: 		void ISR() iv 0x0008
;BMSToucan.c,116 :: 		if (INTCON3.INT1IF == 1)
	BTFSS       INTCON3+0, 0 
	GOTO        L_ISR7
;BMSToucan.c,118 :: 		flag_ovp = 1;
	MOVLW       1
	MOVWF       _flag_ovp+0 
;BMSToucan.c,119 :: 		INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON3+0, 0 
;BMSToucan.c,120 :: 		}
	GOTO        L_ISR8
L_ISR7:
;BMSToucan.c,121 :: 		else if (INTCON.INT0IF == 1)
	BTFSS       INTCON+0, 1 
	GOTO        L_ISR9
;BMSToucan.c,124 :: 		flag_lvp = 1;
	MOVLW       1
	MOVWF       _flag_lvp+0 
;BMSToucan.c,125 :: 		INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON+0, 1 
;BMSToucan.c,126 :: 		}
	GOTO        L_ISR10
L_ISR9:
;BMSToucan.c,127 :: 		else if (INTCON.T0IF == 1)
	BTFSS       INTCON+0, 2 
	GOTO        L_ISR11
;BMSToucan.c,130 :: 		tx_counter++;
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
;BMSToucan.c,131 :: 		if(tx_counter > COUNTER_OVERFLOW)
	MOVF        _tx_counter+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__ISR20
	MOVF        _tx_counter+0, 0 
	SUBLW       38
L__ISR20:
	BTFSC       STATUS+0, 0 
	GOTO        L_ISR12
;BMSToucan.c,133 :: 		flag_check_bms = 1;
	MOVLW       1
	MOVWF       _flag_check_bms+0 
;BMSToucan.c,134 :: 		tx_counter = 0;
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,135 :: 		}
L_ISR12:
;BMSToucan.c,136 :: 		INTCON.T0IF = 0; // reset the TMR0 interrupt flag
	BCF         INTCON+0, 2 
;BMSToucan.c,137 :: 		}
L_ISR11:
L_ISR10:
L_ISR8:
;BMSToucan.c,138 :: 		}
L_end_ISR:
L__ISR19:
	RETFIE      1
; end of _ISR

_CANbus_setup:

;BMSToucan.c,150 :: 		void CANbus_setup()
;BMSToucan.c,173 :: 		CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
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
;BMSToucan.c,177 :: 		CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);
	MOVLW       128
	MOVWF       FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,179 :: 		mask = -1;
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+0 
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+1 
	MOVWF       CANbus_setup_mask_L0+2 
	MOVWF       CANbus_setup_mask_L0+3 
;BMSToucan.c,182 :: 		CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,185 :: 		CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,189 :: 		CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,191 :: 		CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,195 :: 		CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
	CLRF        FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,196 :: 		}/* The CANbus is now set up and ready for use  */
L_end_CANbus_setup:
	RETURN      0
; end of _CANbus_setup

_reset_candata:

;BMSToucan.c,202 :: 		void reset_candata()
;BMSToucan.c,205 :: 		for (i = 0; i < 8; i++)
	CLRF        R1 
	CLRF        R2 
L_reset_candata13:
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__reset_candata23
	MOVLW       8
	SUBWF       R1, 0 
L__reset_candata23:
	BTFSC       STATUS+0, 0 
	GOTO        L_reset_candata14
;BMSToucan.c,207 :: 		CAN_data[i] = 0;
	MOVLW       _CAN_data+0
	ADDWF       R1, 0 
	MOVWF       FSR1L 
	MOVLW       hi_addr(_CAN_data+0)
	ADDWFC      R2, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;BMSToucan.c,205 :: 		for (i = 0; i < 8; i++)
	INFSNZ      R1, 1 
	INCF        R2, 1 
;BMSToucan.c,208 :: 		}
	GOTO        L_reset_candata13
L_reset_candata14:
;BMSToucan.c,209 :: 		}
L_end_reset_candata:
	RETURN      0
; end of _reset_candata

_setup:

;BMSToucan.c,216 :: 		void setup()
;BMSToucan.c,219 :: 		TRISA = 0; // default PORTA to output
	CLRF        TRISA+0 
;BMSToucan.c,220 :: 		TRISB = 0; // default PORTB to output
	CLRF        TRISB+0 
;BMSToucan.c,221 :: 		TRISC = 0; // default PORTC to output
	CLRF        TRISC+0 
;BMSToucan.c,224 :: 		INTCON.GIE = 1;    // enable global interrupts
	BSF         INTCON+0, 7 
;BMSToucan.c,225 :: 		INTCON.PEIE = 1;   // enable peripheral interrupts
	BSF         INTCON+0, 6 
;BMSToucan.c,226 :: 		INTCON.TMR0IE = 1; // enable timer 0 interrupts to control
	BSF         INTCON+0, 5 
;BMSToucan.c,228 :: 		INTCON2.RBPU = 1;  // disable pull ups on PORTB
	BSF         INTCON2+0, 7 
;BMSToucan.c,229 :: 		INTCON2.INTEDG0 = 1; // interrupt INT0 on rising edge
	BSF         INTCON2+0, 6 
;BMSToucan.c,230 :: 		INTCON2.INTEDG1 = 1; // interrupt INT1 on rising edge
	BSF         INTCON2+0, 5 
;BMSToucan.c,231 :: 		INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
	BSF         INTCON2+0, 2 
;BMSToucan.c,232 :: 		INTCON3.INT2IE = 0; // disable INT2
	BCF         INTCON3+0, 4 
;BMSToucan.c,233 :: 		INTCON3.INT1IE = 1; // enable INT1
	BSF         INTCON3+0, 3 
;BMSToucan.c,234 :: 		INTCON.INT0IE = 1; // enable INT0
	BSF         INTCON+0, 4 
;BMSToucan.c,237 :: 		RCSTA.SPEN = 1; // enable the serial port
	BSF         RCSTA+0, 7 
;BMSToucan.c,238 :: 		RCSTA.RX9 = 0; // 8 bit mode
	BCF         RCSTA+0, 6 
;BMSToucan.c,239 :: 		TXSTA.SYNC = 0; // start in asynchronous mode
	BCF         TXSTA+0, 4 
;BMSToucan.c,240 :: 		TRISC.B7 = 1; // set the RX bit to output
	BSF         TRISC+0, 7 
;BMSToucan.c,243 :: 		TXSTA.BRGH = 1; // High speed serial
	BSF         TXSTA+0, 2 
;BMSToucan.c,244 :: 		SPBRG = 64; // set the baud to 20Mhz / 19200 baud
	MOVLW       64
	MOVWF       SPBRG+0 
;BMSToucan.c,247 :: 		UART1_init(19200);
	MOVLW       64
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;BMSToucan.c,250 :: 		TRISB.B3 = 1; // set CANRX for outputting transmission
	BSF         TRISB+0, 3 
;BMSToucan.c,251 :: 		TRISB.B2 = 0; // clear CANTX for inputting signal
	BCF         TRISB+0, 2 
;BMSToucan.c,254 :: 		T0CON.TMR0ON = 1; // turn on timer 0
	BSF         T0CON+0, 7 
;BMSToucan.c,255 :: 		T0CON.T08BIT = 0; // set up as a 16 bit timer
	BCF         T0CON+0, 6 
;BMSToucan.c,256 :: 		T0CON.T0CS = 0; // use CLK0 as the timing signal
	BCF         T0CON+0, 5 
;BMSToucan.c,257 :: 		T0CON.PSA = 0; // do not use the prescaler
	BCF         T0CON+0, 3 
;BMSToucan.c,258 :: 		T0CON.T0PS2 = 1; // set the prescaler to 1:256
	BSF         T0CON+0, 2 
;BMSToucan.c,259 :: 		T0CON.T0PS1 = 1; // this gives us an overflow of TMR0 every 0xFFFF * 256
	BSF         T0CON+0, 1 
;BMSToucan.c,260 :: 		T0CON.T0PS0 = 1; // clock cycles (at 20Mhz)
	BSF         T0CON+0, 0 
;BMSToucan.c,263 :: 		CANbus_setup();
	CALL        _CANbus_setup+0, 0
;BMSToucan.c,266 :: 		tx_counter = 0; // reset the transmit counter
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,267 :: 		flag_ovp = 0; // no ovp problem
	CLRF        _flag_ovp+0 
;BMSToucan.c,268 :: 		flag_lvp = 0; // no lvp problem
	CLRF        _flag_lvp+0 
;BMSToucan.c,269 :: 		flag_check_bms = 0; // don't check BMS
	CLRF        _flag_check_bms+0 
;BMSToucan.c,270 :: 		current_cell = 1; // start by querying cell #1
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,271 :: 		}
L_end_setup:
	RETURN      0
; end of _setup
