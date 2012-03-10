
_main:

;BMSToucan.c,85 :: 		void main() {
;BMSToucan.c,87 :: 		setup();
	CALL        _setup+0, 0
;BMSToucan.c,90 :: 		for(;;)
L_main0:
;BMSToucan.c,93 :: 		reset_candata();
	CALL        _reset_candata+0, 0
;BMSToucan.c,96 :: 		if (flag_ovp) {
	MOVF        _flag_ovp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main3
;BMSToucan.c,98 :: 		CAN_data[BMS_ERROR_BIT].B0 = 1;
	BSF         _CAN_data+6, 0 
;BMSToucan.c,99 :: 		}
L_main3:
;BMSToucan.c,100 :: 		if (flag_lvp) {
	MOVF        _flag_lvp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main4
;BMSToucan.c,102 :: 		CAN_data[BMS_ERROR_BIT].B1 = 1;
	BSF         _CAN_data+6, 1 
;BMSToucan.c,103 :: 		}
L_main4:
;BMSToucan.c,106 :: 		if (flag_check_bms) {
	MOVF        _flag_check_bms+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main5
;BMSToucan.c,112 :: 		if (BMS_buffer_idx > 0)
	MOVF        _BMS_buffer_idx+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_main6
;BMSToucan.c,114 :: 		aborted_bms_checks++;
	INCF        _aborted_bms_checks+0, 1 
;BMSToucan.c,117 :: 		if (aborted_bms_checks > MAX_BMS_CHECK_ABORTS)
	MOVF        _aborted_bms_checks+0, 0 
	SUBLW       10
	BTFSC       STATUS+0, 0 
	GOTO        L_main7
;BMSToucan.c,120 :: 		CAN_data[BMS_ERROR_BIT].B2 = 1;
	BSF         _CAN_data+6, 2 
;BMSToucan.c,121 :: 		aborted_bms_checks = 0;
	CLRF        _aborted_bms_checks+0 
;BMSToucan.c,122 :: 		BMS_buffer_idx = 0;
	CLRF        _BMS_buffer_idx+0 
;BMSToucan.c,123 :: 		}
L_main7:
;BMSToucan.c,124 :: 		} else {
	GOTO        L_main8
L_main6:
;BMSToucan.c,125 :: 		aborted_bms_checks = 0; // no checks have been aborted
	CLRF        _aborted_bms_checks+0 
;BMSToucan.c,128 :: 		current_cell++; // move to the next cell
	INFSNZ      _current_cell+0, 1 
	INCF        _current_cell+1, 1 
;BMSToucan.c,129 :: 		if(current_cell > NUMBER_OF_CELLS)
	MOVLW       128
	XORLW       0
	MOVWF       R0 
	MOVLW       128
	XORWF       _current_cell+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main23
	MOVF        _current_cell+0, 0 
	SUBLW       18
L__main23:
	BTFSC       STATUS+0, 0 
	GOTO        L_main9
;BMSToucan.c,131 :: 		current_cell = 1; // move back to the first cell
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,132 :: 		}
L_main9:
;BMSToucan.c,135 :: 		UART1_Write(BMS_QUERY_BIT_1);
	MOVLW       129
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,136 :: 		UART1_Write(BMS_QUERY_BIT_2);
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,139 :: 		UART1_Write(current_cell);
	MOVF        _current_cell+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,140 :: 		UART1_Write(current_cell);
	MOVF        _current_cell+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,141 :: 		}
L_main8:
;BMSToucan.c,142 :: 		}
L_main5:
;BMSToucan.c,145 :: 		if(UART1_Data_ready())
	CALL        _UART1_Data_Ready+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main10
;BMSToucan.c,148 :: 		BMS_buffer[BMS_buffer_idx] = UART1_read();
	MOVLW       _BMS_buffer+0
	MOVWF       FLOC__main+0 
	MOVLW       hi_addr(_BMS_buffer+0)
	MOVWF       FLOC__main+1 
	MOVF        _BMS_buffer_idx+0, 0 
	ADDWF       FLOC__main+0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FLOC__main+1, 1 
	CALL        _UART1_Read+0, 0
	MOVFF       FLOC__main+0, FSR1L
	MOVFF       FLOC__main+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;BMSToucan.c,149 :: 		BMS_buffer_idx++;
	INCF        _BMS_buffer_idx+0, 1 
;BMSToucan.c,152 :: 		if (BMS_buffer_idx == BMS_QUERY_LENGTH)
	MOVF        _BMS_buffer_idx+0, 0 
	XORLW       29
	BTFSS       STATUS+0, 2 
	GOTO        L_main11
;BMSToucan.c,156 :: 		flag_send_can = 0x01; // as we have received a full buffer
	MOVLW       1
	MOVWF       _flag_send_can+0 
;BMSToucan.c,159 :: 		}
L_main11:
;BMSToucan.c,160 :: 		}
L_main10:
;BMSToucan.c,163 :: 		if(flag_send_can == 0x01)
	MOVF        _flag_send_can+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main12
;BMSToucan.c,165 :: 		CanWrite(CAN_ADDRESS, CAN_data, 1, SEND_FLAG);
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
;BMSToucan.c,166 :: 		flag_send_can = 0x00;
	CLRF        _flag_send_can+0 
;BMSToucan.c,167 :: 		}
L_main12:
;BMSToucan.c,168 :: 		}
	GOTO        L_main0
;BMSToucan.c,169 :: 		}
L_end_main:
	GOTO        $+0
; end of _main

_ISR:

;BMSToucan.c,177 :: 		void ISR() iv 0x0008
;BMSToucan.c,182 :: 		if (INTCON3.INT1IF == 1)
	BTFSS       INTCON3+0, 0 
	GOTO        L_ISR13
;BMSToucan.c,184 :: 		flag_ovp = 1;
	MOVLW       1
	MOVWF       _flag_ovp+0 
;BMSToucan.c,185 :: 		INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON3+0, 0 
;BMSToucan.c,186 :: 		}
	GOTO        L_ISR14
L_ISR13:
;BMSToucan.c,187 :: 		else if (INTCON.INT0IF == 1)
	BTFSS       INTCON+0, 1 
	GOTO        L_ISR15
;BMSToucan.c,190 :: 		flag_lvp = 1;
	MOVLW       1
	MOVWF       _flag_lvp+0 
;BMSToucan.c,191 :: 		INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON+0, 1 
;BMSToucan.c,192 :: 		}
	GOTO        L_ISR16
L_ISR15:
;BMSToucan.c,193 :: 		else if (INTCON.T0IF == 1)
	BTFSS       INTCON+0, 2 
	GOTO        L_ISR17
;BMSToucan.c,196 :: 		tx_counter++;
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
;BMSToucan.c,197 :: 		if(tx_counter > COUNTER_OVERFLOW)
	MOVF        _tx_counter+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__ISR26
	MOVF        _tx_counter+0, 0 
	SUBLW       38
L__ISR26:
	BTFSC       STATUS+0, 0 
	GOTO        L_ISR18
;BMSToucan.c,199 :: 		flag_check_bms = 1;
	MOVLW       1
	MOVWF       _flag_check_bms+0 
;BMSToucan.c,200 :: 		tx_counter = 0;
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,201 :: 		}
L_ISR18:
;BMSToucan.c,202 :: 		INTCON.T0IF = 0; // reset the TMR0 interrupt flag
	BCF         INTCON+0, 2 
;BMSToucan.c,203 :: 		}
L_ISR17:
L_ISR16:
L_ISR14:
;BMSToucan.c,204 :: 		}
L_end_ISR:
L__ISR25:
	RETFIE      1
; end of _ISR

_CANbus_setup:

;BMSToucan.c,216 :: 		void CANbus_setup()
;BMSToucan.c,239 :: 		CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
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
;BMSToucan.c,243 :: 		CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);
	MOVLW       128
	MOVWF       FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,245 :: 		mask = -1;
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+0 
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+1 
	MOVWF       CANbus_setup_mask_L0+2 
	MOVWF       CANbus_setup_mask_L0+3 
;BMSToucan.c,248 :: 		CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,251 :: 		CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,255 :: 		CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,257 :: 		CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,261 :: 		CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
	CLRF        FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,262 :: 		}/* The CANbus is now set up and ready for use  */
L_end_CANbus_setup:
	RETURN      0
; end of _CANbus_setup

_reset_candata:

;BMSToucan.c,268 :: 		void reset_candata()
;BMSToucan.c,271 :: 		for (i = 0; i < 8; i++)
	CLRF        R1 
	CLRF        R2 
L_reset_candata19:
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__reset_candata29
	MOVLW       8
	SUBWF       R1, 0 
L__reset_candata29:
	BTFSC       STATUS+0, 0 
	GOTO        L_reset_candata20
;BMSToucan.c,273 :: 		CAN_data[i] = 0;
	MOVLW       _CAN_data+0
	ADDWF       R1, 0 
	MOVWF       FSR1L 
	MOVLW       hi_addr(_CAN_data+0)
	ADDWFC      R2, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;BMSToucan.c,271 :: 		for (i = 0; i < 8; i++)
	INFSNZ      R1, 1 
	INCF        R2, 1 
;BMSToucan.c,274 :: 		}
	GOTO        L_reset_candata19
L_reset_candata20:
;BMSToucan.c,275 :: 		}
L_end_reset_candata:
	RETURN      0
; end of _reset_candata

_setup:

;BMSToucan.c,282 :: 		void setup()
;BMSToucan.c,285 :: 		TRISA = 0; // default PORTA to output
	CLRF        TRISA+0 
;BMSToucan.c,286 :: 		TRISB = 0; // default PORTB to output
	CLRF        TRISB+0 
;BMSToucan.c,287 :: 		TRISC = 0; // default PORTC to output
	CLRF        TRISC+0 
;BMSToucan.c,290 :: 		INTCON.GIE = 1;    // enable global interrupts
	BSF         INTCON+0, 7 
;BMSToucan.c,291 :: 		INTCON.PEIE = 1;   // enable peripheral interrupts
	BSF         INTCON+0, 6 
;BMSToucan.c,292 :: 		INTCON.TMR0IE = 1; // enable timer 0 interrupts to control
	BSF         INTCON+0, 5 
;BMSToucan.c,294 :: 		INTCON2.RBPU = 1;  // disable pull ups on PORTB
	BSF         INTCON2+0, 7 
;BMSToucan.c,295 :: 		INTCON2.INTEDG0 = 1; // interrupt INT0 on rising edge
	BSF         INTCON2+0, 6 
;BMSToucan.c,296 :: 		INTCON2.INTEDG1 = 1; // interrupt INT1 on rising edge
	BSF         INTCON2+0, 5 
;BMSToucan.c,297 :: 		INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
	BSF         INTCON2+0, 2 
;BMSToucan.c,298 :: 		INTCON3.INT2IE = 0; // disable INT2
	BCF         INTCON3+0, 4 
;BMSToucan.c,299 :: 		INTCON3.INT1IE = 1; // enable INT1
	BSF         INTCON3+0, 3 
;BMSToucan.c,300 :: 		INTCON.INT0IE = 1; // enable INT0
	BSF         INTCON+0, 4 
;BMSToucan.c,303 :: 		RCSTA.SPEN = 1; // enable the serial port
	BSF         RCSTA+0, 7 
;BMSToucan.c,304 :: 		RCSTA.RX9 = 0; // 8 bit mode
	BCF         RCSTA+0, 6 
;BMSToucan.c,305 :: 		TXSTA.SYNC = 0; // start in asynchronous mode
	BCF         TXSTA+0, 4 
;BMSToucan.c,306 :: 		TRISC.B7 = 1; // set the RX bit to output
	BSF         TRISC+0, 7 
;BMSToucan.c,309 :: 		TXSTA.BRGH = 1; // High speed serial
	BSF         TXSTA+0, 2 
;BMSToucan.c,310 :: 		SPBRG = 64; // set the baud to 20Mhz / 19200 baud
	MOVLW       64
	MOVWF       SPBRG+0 
;BMSToucan.c,313 :: 		UART1_init(19200);
	MOVLW       64
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;BMSToucan.c,316 :: 		TRISB.B3 = 1; // set CANRX for outputting transmission
	BSF         TRISB+0, 3 
;BMSToucan.c,317 :: 		TRISB.B2 = 0; // clear CANTX for inputting signal
	BCF         TRISB+0, 2 
;BMSToucan.c,320 :: 		T0CON.TMR0ON = 1; // turn on timer 0
	BSF         T0CON+0, 7 
;BMSToucan.c,321 :: 		T0CON.T08BIT = 0; // set up as a 16 bit timer
	BCF         T0CON+0, 6 
;BMSToucan.c,322 :: 		T0CON.T0CS = 0; // use CLK0 as the timing signal
	BCF         T0CON+0, 5 
;BMSToucan.c,323 :: 		T0CON.PSA = 0; // do not use the prescaler
	BCF         T0CON+0, 3 
;BMSToucan.c,324 :: 		T0CON.T0PS2 = 1; // set the prescaler to 1:256
	BSF         T0CON+0, 2 
;BMSToucan.c,325 :: 		T0CON.T0PS1 = 1; // this gives us an overflow of TMR0 every 0xFFFF * 256
	BSF         T0CON+0, 1 
;BMSToucan.c,326 :: 		T0CON.T0PS0 = 1; // clock cycles (at 20Mhz)
	BSF         T0CON+0, 0 
;BMSToucan.c,329 :: 		CANbus_setup();
	CALL        _CANbus_setup+0, 0
;BMSToucan.c,332 :: 		tx_counter = 0; // reset the transmit counter
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,333 :: 		flag_ovp = 0; // no ovp problem
	CLRF        _flag_ovp+0 
;BMSToucan.c,334 :: 		flag_lvp = 0; // no lvp problem
	CLRF        _flag_lvp+0 
;BMSToucan.c,335 :: 		flag_check_bms = 0; // don't check BMS
	CLRF        _flag_check_bms+0 
;BMSToucan.c,336 :: 		flag_send_can = 0; // no can messages to send yet
	CLRF        _flag_send_can+0 
;BMSToucan.c,337 :: 		current_cell = 1; // start by querying cell #1
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,339 :: 		}
L_end_setup:
	RETURN      0
; end of _setup
