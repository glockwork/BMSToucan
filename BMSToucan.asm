
_main:

;BMSToucan.c,86 :: 		void main() {
;BMSToucan.c,88 :: 		setup();
	CALL        _setup+0, 0
;BMSToucan.c,91 :: 		for(;;)
L_main0:
;BMSToucan.c,94 :: 		reset_candata();
	CALL        _reset_candata+0, 0
;BMSToucan.c,97 :: 		if (flag_ovp) {
	MOVF        _flag_ovp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main3
;BMSToucan.c,99 :: 		CAN_data[BMS_ERROR_BIT].B0 = 1;
	BSF         _CAN_data+6, 0 
;BMSToucan.c,100 :: 		}
L_main3:
;BMSToucan.c,101 :: 		if (flag_lvp) {
	MOVF        _flag_lvp+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main4
;BMSToucan.c,103 :: 		CAN_data[BMS_ERROR_BIT].B1 = 1;
	BSF         _CAN_data+6, 1 
;BMSToucan.c,104 :: 		}
L_main4:
;BMSToucan.c,107 :: 		if (flag_check_bms) {
	MOVF        _flag_check_bms+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main5
;BMSToucan.c,113 :: 		if (BMS_buffer_idx > 0)
	MOVF        _BMS_buffer_idx+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_main6
;BMSToucan.c,115 :: 		aborted_bms_checks++;
	INCF        _aborted_bms_checks+0, 1 
;BMSToucan.c,118 :: 		if (aborted_bms_checks > MAX_BMS_CHECK_ABORTS)
	MOVF        _aborted_bms_checks+0, 0 
	SUBLW       10
	BTFSC       STATUS+0, 0 
	GOTO        L_main7
;BMSToucan.c,121 :: 		CAN_data[BMS_ERROR_BIT].B2 = 1;
	BSF         _CAN_data+6, 2 
;BMSToucan.c,122 :: 		aborted_bms_checks = 0;
	CLRF        _aborted_bms_checks+0 
;BMSToucan.c,123 :: 		BMS_buffer_idx = 0;
	CLRF        _BMS_buffer_idx+0 
;BMSToucan.c,124 :: 		}
L_main7:
;BMSToucan.c,125 :: 		} else {
	GOTO        L_main8
L_main6:
;BMSToucan.c,126 :: 		aborted_bms_checks = 0; // no checks have been aborted
	CLRF        _aborted_bms_checks+0 
;BMSToucan.c,129 :: 		current_cell++; // move to the next cell
	INFSNZ      _current_cell+0, 1 
	INCF        _current_cell+1, 1 
;BMSToucan.c,130 :: 		if(current_cell > NUMBER_OF_CELLS)
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
;BMSToucan.c,132 :: 		current_cell = 1; // move back to the first cell
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,133 :: 		}
L_main9:
;BMSToucan.c,136 :: 		UART1_Write(BMS_QUERY_BIT_1);
	MOVLW       129
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,137 :: 		UART1_Write(BMS_QUERY_BIT_2);
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,140 :: 		UART1_Write(current_cell);
	MOVF        _current_cell+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,141 :: 		UART1_Write(current_cell);
	MOVF        _current_cell+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,142 :: 		}
L_main8:
;BMSToucan.c,143 :: 		}
L_main5:
;BMSToucan.c,146 :: 		if(UART1_Data_ready())
	CALL        _UART1_Data_Ready+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main10
;BMSToucan.c,149 :: 		BMS_buffer[BMS_buffer_idx] = UART1_read();
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
;BMSToucan.c,150 :: 		BMS_buffer_idx++;
	INCF        _BMS_buffer_idx+0, 1 
;BMSToucan.c,153 :: 		if (BMS_buffer_idx == BMS_QUERY_LENGTH)
	MOVF        _BMS_buffer_idx+0, 0 
	XORLW       29
	BTFSS       STATUS+0, 2 
	GOTO        L_main11
;BMSToucan.c,157 :: 		CAN_data[V1_bit] = ((BMS_buffer[BMS_V1_B2] << 8) &
	MOVF        _BMS_buffer+4, 0 
	MOVWF       R1 
	CLRF        R0 
;BMSToucan.c,158 :: 		BMS_buffer[BMS_V1_B1]) / 256;
	MOVF        _BMS_buffer+3, 0 
	ANDWF       R0, 0 
	MOVWF       R3 
	MOVF        R1, 0 
	MOVWF       R4 
	MOVLW       0
	ANDWF       R4, 1 
	MOVF        R4, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       _CAN_data+1 
;BMSToucan.c,159 :: 		CAN_data[V2_bit] = ((BMS_buffer[BMS_V2_B2] << 8) &
	MOVF        _BMS_buffer+8, 0 
	MOVWF       R1 
	CLRF        R0 
;BMSToucan.c,160 :: 		BMS_buffer[BMS_V2_B1]) / 256;
	MOVF        _BMS_buffer+7, 0 
	ANDWF       R0, 0 
	MOVWF       R3 
	MOVF        R1, 0 
	MOVWF       R4 
	MOVLW       0
	ANDWF       R4, 1 
	MOVF        R4, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       _CAN_data+2 
;BMSToucan.c,161 :: 		CAN_data[V3_bit] = ((BMS_buffer[BMS_V3_B2] << 8) &
	MOVF        _BMS_buffer+12, 0 
	MOVWF       R1 
	CLRF        R0 
;BMSToucan.c,162 :: 		BMS_buffer[BMS_V3_B1]) / 256;
	MOVF        _BMS_buffer+11, 0 
	ANDWF       R0, 0 
	MOVWF       R3 
	MOVF        R1, 0 
	MOVWF       R4 
	MOVLW       0
	ANDWF       R4, 1 
	MOVF        R4, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       _CAN_data+3 
;BMSToucan.c,163 :: 		CAN_data[V4_bit] = ((BMS_buffer[BMS_V4_B2] << 8) &
	MOVF        _BMS_buffer+16, 0 
	MOVWF       R1 
	CLRF        R0 
;BMSToucan.c,164 :: 		BMS_buffer[BMS_V4_B1]) / 256;
	MOVF        _BMS_buffer+15, 0 
	ANDWF       R0, 0 
	MOVWF       R3 
	MOVF        R1, 0 
	MOVWF       R4 
	MOVLW       0
	ANDWF       R4, 1 
	MOVF        R4, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       _CAN_data+4 
;BMSToucan.c,165 :: 		flag_send_can = 0x01; // as we have received a full buffer
	MOVLW       1
	MOVWF       _flag_send_can+0 
;BMSToucan.c,168 :: 		}
L_main11:
;BMSToucan.c,169 :: 		}
L_main10:
;BMSToucan.c,172 :: 		if(flag_send_can == 0x01)
	MOVF        _flag_send_can+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main12
;BMSToucan.c,175 :: 		CanWrite(CAN_ADDRESS, CAN_data, 1, SEND_FLAG);
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
;BMSToucan.c,178 :: 		BMS_buffer_idx = 0;
	CLRF        _BMS_buffer_idx+0 
;BMSToucan.c,179 :: 		flag_send_can = 0x00;
	CLRF        _flag_send_can+0 
;BMSToucan.c,180 :: 		}
L_main12:
;BMSToucan.c,181 :: 		}
	GOTO        L_main0
;BMSToucan.c,182 :: 		}
L_end_main:
	GOTO        $+0
; end of _main

_ISR:

;BMSToucan.c,190 :: 		void ISR() iv 0x0008
;BMSToucan.c,195 :: 		if (INTCON3.INT1IF == 1)
	BTFSS       INTCON3+0, 0 
	GOTO        L_ISR13
;BMSToucan.c,197 :: 		flag_ovp = 1;
	MOVLW       1
	MOVWF       _flag_ovp+0 
;BMSToucan.c,198 :: 		INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON3+0, 0 
;BMSToucan.c,199 :: 		}
	GOTO        L_ISR14
L_ISR13:
;BMSToucan.c,200 :: 		else if (INTCON.INT0IF == 1)
	BTFSS       INTCON+0, 1 
	GOTO        L_ISR15
;BMSToucan.c,203 :: 		flag_lvp = 1;
	MOVLW       1
	MOVWF       _flag_lvp+0 
;BMSToucan.c,204 :: 		INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON+0, 1 
;BMSToucan.c,205 :: 		}
	GOTO        L_ISR16
L_ISR15:
;BMSToucan.c,206 :: 		else if (INTCON.T0IF == 1)
	BTFSS       INTCON+0, 2 
	GOTO        L_ISR17
;BMSToucan.c,209 :: 		tx_counter++;
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
;BMSToucan.c,210 :: 		if(tx_counter > COUNTER_OVERFLOW)
	MOVF        _tx_counter+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__ISR26
	MOVF        _tx_counter+0, 0 
	SUBLW       38
L__ISR26:
	BTFSC       STATUS+0, 0 
	GOTO        L_ISR18
;BMSToucan.c,212 :: 		flag_check_bms = 1;
	MOVLW       1
	MOVWF       _flag_check_bms+0 
;BMSToucan.c,213 :: 		tx_counter = 0;
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,214 :: 		}
L_ISR18:
;BMSToucan.c,215 :: 		INTCON.T0IF = 0; // reset the TMR0 interrupt flag
	BCF         INTCON+0, 2 
;BMSToucan.c,216 :: 		}
L_ISR17:
L_ISR16:
L_ISR14:
;BMSToucan.c,217 :: 		}
L_end_ISR:
L__ISR25:
	RETFIE      1
; end of _ISR

_CANbus_setup:

;BMSToucan.c,229 :: 		void CANbus_setup()
;BMSToucan.c,250 :: 		CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
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
;BMSToucan.c,253 :: 		CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);
	MOVLW       128
	MOVWF       FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,256 :: 		mask = -1;
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+0 
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+1 
	MOVWF       CANbus_setup_mask_L0+2 
	MOVWF       CANbus_setup_mask_L0+3 
;BMSToucan.c,257 :: 		CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,260 :: 		CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,263 :: 		CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,265 :: 		CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,268 :: 		CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
	CLRF        FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,269 :: 		} // The CANbus is now set up and ready for use
L_end_CANbus_setup:
	RETURN      0
; end of _CANbus_setup

_reset_candata:

;BMSToucan.c,275 :: 		void reset_candata()
;BMSToucan.c,278 :: 		for (i = 0; i < 8; i++)
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
;BMSToucan.c,280 :: 		CAN_data[i] = 0;
	MOVLW       _CAN_data+0
	ADDWF       R1, 0 
	MOVWF       FSR1L 
	MOVLW       hi_addr(_CAN_data+0)
	ADDWFC      R2, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;BMSToucan.c,278 :: 		for (i = 0; i < 8; i++)
	INFSNZ      R1, 1 
	INCF        R2, 1 
;BMSToucan.c,281 :: 		}
	GOTO        L_reset_candata19
L_reset_candata20:
;BMSToucan.c,282 :: 		}
L_end_reset_candata:
	RETURN      0
; end of _reset_candata

_setup:

;BMSToucan.c,289 :: 		void setup()
;BMSToucan.c,292 :: 		TRISA = 0; // default PORTA to output
	CLRF        TRISA+0 
;BMSToucan.c,293 :: 		TRISB = 0; // default PORTB to output
	CLRF        TRISB+0 
;BMSToucan.c,294 :: 		TRISC = 0; // default PORTC to output
	CLRF        TRISC+0 
;BMSToucan.c,297 :: 		INTCON.GIE = 1;    // enable global interrupts
	BSF         INTCON+0, 7 
;BMSToucan.c,298 :: 		INTCON.PEIE = 1;   // enable peripheral interrupts
	BSF         INTCON+0, 6 
;BMSToucan.c,299 :: 		INTCON.TMR0IE = 1; // enable timer 0 interrupts to control
	BSF         INTCON+0, 5 
;BMSToucan.c,301 :: 		INTCON2.RBPU = 1;  // disable pull ups on PORTB
	BSF         INTCON2+0, 7 
;BMSToucan.c,302 :: 		INTCON2.INTEDG0 = 1; // interrupt INT0 on rising edge
	BSF         INTCON2+0, 6 
;BMSToucan.c,303 :: 		INTCON2.INTEDG1 = 1; // interrupt INT1 on rising edge
	BSF         INTCON2+0, 5 
;BMSToucan.c,304 :: 		INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
	BSF         INTCON2+0, 2 
;BMSToucan.c,305 :: 		INTCON3.INT2IE = 0; // disable INT2
	BCF         INTCON3+0, 4 
;BMSToucan.c,306 :: 		INTCON3.INT1IE = 1; // enable INT1
	BSF         INTCON3+0, 3 
;BMSToucan.c,307 :: 		INTCON.INT0IE = 1; // enable INT0
	BSF         INTCON+0, 4 
;BMSToucan.c,327 :: 		T0CON.TMR0ON = 1; // turn on timer 0
	BSF         T0CON+0, 7 
;BMSToucan.c,328 :: 		T0CON.T08BIT = 0; // set up as a 16 bit timer
	BCF         T0CON+0, 6 
;BMSToucan.c,329 :: 		T0CON.T0CS = 0; // use CLK0 as the timing signal
	BCF         T0CON+0, 5 
;BMSToucan.c,330 :: 		T0CON.PSA = 0; // do not use the prescaler
	BCF         T0CON+0, 3 
;BMSToucan.c,331 :: 		T0CON.T0PS2 = 1; // set the prescaler to 1:256
	BSF         T0CON+0, 2 
;BMSToucan.c,332 :: 		T0CON.T0PS1 = 1; // this gives us an overflow of TMR0 every 0xFFFF * 256
	BSF         T0CON+0, 1 
;BMSToucan.c,333 :: 		T0CON.T0PS0 = 1; // clock cycles (at 20Mhz)
	BSF         T0CON+0, 0 
;BMSToucan.c,339 :: 		tx_counter = 0; // reset the transmit counter
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,340 :: 		flag_ovp = 0; // no ovp problem
	CLRF        _flag_ovp+0 
;BMSToucan.c,341 :: 		flag_lvp = 0; // no lvp problem
	CLRF        _flag_lvp+0 
;BMSToucan.c,342 :: 		flag_check_bms = 0; // don't check BMS
	CLRF        _flag_check_bms+0 
;BMSToucan.c,343 :: 		flag_send_can = 0; // no can messages to send yet
	CLRF        _flag_send_can+0 
;BMSToucan.c,344 :: 		current_cell = 1; // start by querying cell #1
	MOVLW       1
	MOVWF       _current_cell+0 
	MOVLW       0
	MOVWF       _current_cell+1 
;BMSToucan.c,346 :: 		}
L_end_setup:
	RETURN      0
; end of _setup
