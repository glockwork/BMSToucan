
_main:

;BMSToucan.c,101 :: 		void main() {
;BMSToucan.c,103 :: 		setup();
	CALL        _setup+0, 0
;BMSToucan.c,106 :: 		PORTC.B4 = 0;
	BCF         PORTC+0, 4 
;BMSToucan.c,107 :: 		PORTC.B5 = 0;
	BCF         PORTC+0, 5 
;BMSToucan.c,110 :: 		for(;;)
L_main0:
;BMSToucan.c,113 :: 		reset_candata();
	CALL        _reset_candata+0, 0
;BMSToucan.c,116 :: 		if (flag_ovp == 0x01) {
	MOVF        _flag_ovp+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main3
;BMSToucan.c,119 :: 		CAN_data[BMS_ERROR_BIT].B0 = 1;
	BSF         _CAN_data+6, 0 
;BMSToucan.c,120 :: 		}
L_main3:
;BMSToucan.c,121 :: 		if (flag_lvp == 0x01) {
	MOVF        _flag_lvp+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main4
;BMSToucan.c,124 :: 		CAN_data[BMS_ERROR_BIT].B1 = 1;
	BSF         _CAN_data+6, 1 
;BMSToucan.c,125 :: 		}
L_main4:
;BMSToucan.c,128 :: 		if (flag_check_bms == 0x01) {
	MOVF        _flag_check_bms+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main5
;BMSToucan.c,133 :: 		if (BMS_buffer_idx > 0) // some data has been received but not all
	MOVF        _BMS_buffer_idx+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_main6
;BMSToucan.c,135 :: 		aborted_bms_checks++; // increment the number of aborted checks
	INCF        _aborted_bms_checks+0, 1 
;BMSToucan.c,138 :: 		if (aborted_bms_checks > MAX_BMS_CHECK_ABORTS)
	MOVF        _aborted_bms_checks+0, 0 
	SUBLW       10
	BTFSC       STATUS+0, 0 
	GOTO        L_main7
;BMSToucan.c,141 :: 		CAN_data[BMS_ERROR_BIT].B2 = 1; // set the comms error flag
	BSF         _CAN_data+6, 2 
;BMSToucan.c,142 :: 		CAN_data[0] = CELL_IDS[current_cell]; // set the cell number
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_cell+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _CELL_IDS+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_CELL_IDS+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_CELL_IDS+0)
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, _CAN_data+0
;BMSToucan.c,143 :: 		aborted_bms_checks = 0; // reset the abort counter
	CLRF        _aborted_bms_checks+0 
;BMSToucan.c,144 :: 		flag_send_can = 0x01;  // send an error onto CAN
	MOVLW       1
	MOVWF       _flag_send_can+0 
;BMSToucan.c,145 :: 		}
L_main7:
;BMSToucan.c,146 :: 		} else {
	GOTO        L_main8
L_main6:
;BMSToucan.c,147 :: 		aborted_bms_checks = 0; // no checks have been aborted
	CLRF        _aborted_bms_checks+0 
;BMSToucan.c,150 :: 		current_cell++; // move to the next cell
	INFSNZ      _current_cell+0, 1 
	INCF        _current_cell+1, 1 
;BMSToucan.c,151 :: 		if(current_cell >= NUMBER_OF_CELLS)
	MOVLW       128
	XORWF       _current_cell+1, 0 
	MOVWF       R0 
	MOVLW       128
	XORLW       0
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main27
	MOVLW       18
	SUBWF       _current_cell+0, 0 
L__main27:
	BTFSS       STATUS+0, 0 
	GOTO        L_main9
;BMSToucan.c,153 :: 		current_cell = 0; // move back to the first cell
	CLRF        _current_cell+0 
	CLRF        _current_cell+1 
;BMSToucan.c,154 :: 		}
L_main9:
;BMSToucan.c,157 :: 		UART1_Write(BMS_QUERY_BIT_1);
	MOVLW       129
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,158 :: 		UART1_Write(BMS_QUERY_BIT_2);
	MOVLW       170
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;BMSToucan.c,161 :: 		UART1_Write(CELL_IDS[current_cell]);
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_cell+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _CELL_IDS+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_CELL_IDS+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_CELL_IDS+0)
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, FARG_UART1_Write_data_+0
	CALL        _UART1_Write+0, 0
;BMSToucan.c,162 :: 		UART1_Write(CELL_IDS[current_cell]);
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_cell+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _CELL_IDS+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_CELL_IDS+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_CELL_IDS+0)
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, FARG_UART1_Write_data_+0
	CALL        _UART1_Write+0, 0
;BMSToucan.c,163 :: 		PORTC.B4 = ~PORTC.B4;
	BTG         PORTC+0, 4 
;BMSToucan.c,164 :: 		}
L_main8:
;BMSToucan.c,166 :: 		flag_check_bms = 0x00; // reset the BMS flag
	CLRF        _flag_check_bms+0 
;BMSToucan.c,167 :: 		}
L_main5:
;BMSToucan.c,170 :: 		while(UART1_Data_ready() && BMS_buffer_idx < BMS_QUERY_LENGTH)
L_main10:
	CALL        _UART1_Data_Ready+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main11
	MOVLW       29
	SUBWF       _BMS_buffer_idx+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_main11
L__main25:
;BMSToucan.c,173 :: 		BMS_buffer[BMS_buffer_idx] = UART1_read();
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
;BMSToucan.c,174 :: 		BMS_buffer_idx++;
	INCF        _BMS_buffer_idx+0, 1 
;BMSToucan.c,175 :: 		}
	GOTO        L_main10
L_main11:
;BMSToucan.c,178 :: 		if (BMS_buffer_idx == BMS_QUERY_LENGTH)
	MOVF        _BMS_buffer_idx+0, 0 
	XORLW       29
	BTFSS       STATUS+0, 2 
	GOTO        L_main14
;BMSToucan.c,181 :: 		CAN_data[0] = CELL_IDS[current_cell];
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVLW       0
	BTFSC       _current_cell+1, 7 
	MOVLW       255
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _CELL_IDS+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_CELL_IDS+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_CELL_IDS+0)
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, _CAN_data+0
;BMSToucan.c,189 :: 		cell_values[current_cell][0] =
	MOVLW       3
	MOVWF       R2 
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main28:
	BZ          L__main29
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__main28
L__main29:
	MOVLW       _cell_values+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_cell_values+0)
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	MOVWF       FLOC__main+0 
	MOVF        R1, 0 
	MOVWF       FLOC__main+1 
;BMSToucan.c,192 :: 		(BMS_buffer[BMS_V1_B2] << 8) | BMS_buffer[BMS_V1_B1]
	MOVF        _BMS_buffer+3, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        _BMS_buffer+2, 0 
	IORWF       R0, 1 
	MOVLW       0
	IORWF       R1, 1 
;BMSToucan.c,193 :: 		) * CELL_V_MULTIPLIER
	CALL        _Word2Double+0, 0
	MOVLW       92
	MOVWF       R4 
	MOVLW       143
	MOVWF       R5 
	MOVLW       2
	MOVWF       R6 
	MOVLW       125
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
;BMSToucan.c,194 :: 		);
	CALL        _Double2Byte+0, 0
	MOVFF       FLOC__main+0, FSR1L
	MOVFF       FLOC__main+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVLW       0
	MOVWF       POSTINC1+0 
;BMSToucan.c,195 :: 		CAN_data[V1_bit] = cell_values[current_cell][0];
	MOVLW       3
	MOVWF       R2 
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main30:
	BZ          L__main31
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__main30
L__main31:
	MOVLW       _cell_values+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_cell_values+0)
	ADDWFC      R1, 1 
	MOVFF       R0, FSR0L
	MOVFF       R1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       _CAN_data+1 
;BMSToucan.c,197 :: 		cell_values[current_cell][1] =
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       FLOC__main+0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FLOC__main+1 
;BMSToucan.c,200 :: 		(BMS_buffer[BMS_V2_B2] << 8) | BMS_buffer[BMS_V2_B1]
	MOVF        _BMS_buffer+7, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        _BMS_buffer+6, 0 
	IORWF       R0, 1 
	MOVLW       0
	IORWF       R1, 1 
;BMSToucan.c,201 :: 		) * CELL_V_MULTIPLIER
	CALL        _Word2Double+0, 0
	MOVLW       92
	MOVWF       R4 
	MOVLW       143
	MOVWF       R5 
	MOVLW       2
	MOVWF       R6 
	MOVLW       125
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
;BMSToucan.c,202 :: 		);
	CALL        _Double2Byte+0, 0
	MOVFF       FLOC__main+0, FSR1L
	MOVFF       FLOC__main+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVLW       0
	MOVWF       POSTINC1+0 
;BMSToucan.c,203 :: 		CAN_data[V2_bit] = cell_values[current_cell][1];
	MOVLW       3
	MOVWF       R2 
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main32:
	BZ          L__main33
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__main32
L__main33:
	MOVLW       _cell_values+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_cell_values+0)
	ADDWFC      R1, 1 
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _CAN_data+2 
;BMSToucan.c,205 :: 		cell_values[current_cell][2] =
	MOVLW       4
	ADDWF       R0, 0 
	MOVWF       FLOC__main+0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FLOC__main+1 
;BMSToucan.c,208 :: 		(BMS_buffer[BMS_V3_B2] << 8) | BMS_buffer[BMS_V3_B1]
	MOVF        _BMS_buffer+11, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        _BMS_buffer+10, 0 
	IORWF       R0, 1 
	MOVLW       0
	IORWF       R1, 1 
;BMSToucan.c,209 :: 		) * CELL_V_MULTIPLIER
	CALL        _Word2Double+0, 0
	MOVLW       92
	MOVWF       R4 
	MOVLW       143
	MOVWF       R5 
	MOVLW       2
	MOVWF       R6 
	MOVLW       125
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
;BMSToucan.c,210 :: 		);
	CALL        _Double2Byte+0, 0
	MOVFF       FLOC__main+0, FSR1L
	MOVFF       FLOC__main+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVLW       0
	MOVWF       POSTINC1+0 
;BMSToucan.c,211 :: 		CAN_data[V3_bit] = cell_values[current_cell][2];
	MOVLW       3
	MOVWF       R2 
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main34:
	BZ          L__main35
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__main34
L__main35:
	MOVLW       _cell_values+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_cell_values+0)
	ADDWFC      R1, 1 
	MOVLW       4
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _CAN_data+3 
;BMSToucan.c,213 :: 		cell_values[current_cell][3] =
	MOVLW       6
	ADDWF       R0, 0 
	MOVWF       FLOC__main+0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FLOC__main+1 
;BMSToucan.c,216 :: 		(BMS_buffer[BMS_V4_B2] << 8) | BMS_buffer[BMS_V4_B1]
	MOVF        _BMS_buffer+15, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        _BMS_buffer+14, 0 
	IORWF       R0, 1 
	MOVLW       0
	IORWF       R1, 1 
;BMSToucan.c,217 :: 		) * CELL_V_MULTIPLIER
	CALL        _Word2Double+0, 0
	MOVLW       92
	MOVWF       R4 
	MOVLW       143
	MOVWF       R5 
	MOVLW       2
	MOVWF       R6 
	MOVLW       125
	MOVWF       R7 
	CALL        _Mul_32x32_FP+0, 0
;BMSToucan.c,218 :: 		);
	CALL        _Double2Byte+0, 0
	MOVFF       FLOC__main+0, FSR1L
	MOVFF       FLOC__main+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVLW       0
	MOVWF       POSTINC1+0 
;BMSToucan.c,219 :: 		CAN_data[V4_bit] = cell_values[current_cell][3];
	MOVLW       3
	MOVWF       R2 
	MOVF        _current_cell+0, 0 
	MOVWF       R0 
	MOVF        _current_cell+1, 0 
	MOVWF       R1 
	MOVF        R2, 0 
L__main36:
	BZ          L__main37
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	ADDLW       255
	GOTO        L__main36
L__main37:
	MOVLW       _cell_values+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_cell_values+0)
	ADDWFC      R1, 1 
	MOVLW       6
	ADDWF       R0, 0 
	MOVWF       FSR0L 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       _CAN_data+4 
;BMSToucan.c,223 :: 		flag_send_can = 0x01;
	MOVLW       1
	MOVWF       _flag_send_can+0 
;BMSToucan.c,224 :: 		}
L_main14:
;BMSToucan.c,227 :: 		if(flag_send_can == 0x01)
	MOVF        _flag_send_can+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
;BMSToucan.c,230 :: 		CanWrite(CAN_ADDRESS, CAN_data, 1, SEND_FLAG);
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
;BMSToucan.c,233 :: 		PORTC.B5 = ~PORTC.B5;
	BTG         PORTC+0, 5 
;BMSToucan.c,236 :: 		BMS_buffer_idx = 0;
	CLRF        _BMS_buffer_idx+0 
;BMSToucan.c,237 :: 		flag_send_can = 0x00;
	CLRF        _flag_send_can+0 
;BMSToucan.c,238 :: 		}
L_main15:
;BMSToucan.c,239 :: 		}
	GOTO        L_main0
;BMSToucan.c,240 :: 		}
L_end_main:
	GOTO        $+0
; end of _main

_ISR:

;BMSToucan.c,248 :: 		void ISR() iv 0x0008
;BMSToucan.c,253 :: 		if (INTCON3.INT1IF == 1)
	BTFSS       INTCON3+0, 0 
	GOTO        L_ISR16
;BMSToucan.c,255 :: 		flag_ovp = 0x01;
	MOVLW       1
	MOVWF       _flag_ovp+0 
;BMSToucan.c,256 :: 		INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON3+0, 0 
;BMSToucan.c,257 :: 		}
	GOTO        L_ISR17
L_ISR16:
;BMSToucan.c,258 :: 		else if (INTCON.INT0IF == 1)
	BTFSS       INTCON+0, 1 
	GOTO        L_ISR18
;BMSToucan.c,261 :: 		flag_lvp = 0x01;
	MOVLW       1
	MOVWF       _flag_lvp+0 
;BMSToucan.c,262 :: 		INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
	BCF         INTCON+0, 1 
;BMSToucan.c,263 :: 		}
	GOTO        L_ISR19
L_ISR18:
;BMSToucan.c,264 :: 		else if (INTCON.TMR0IF == 1)
	BTFSS       INTCON+0, 2 
	GOTO        L_ISR20
;BMSToucan.c,267 :: 		tx_counter++;
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
;BMSToucan.c,268 :: 		if(tx_counter > COUNTER_OVERFLOW)
	MOVF        _tx_counter+1, 0 
	SUBLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__ISR40
	MOVF        _tx_counter+0, 0 
	SUBLW       38
L__ISR40:
	BTFSC       STATUS+0, 0 
	GOTO        L_ISR21
;BMSToucan.c,270 :: 		flag_check_bms = 0x01;
	MOVLW       1
	MOVWF       _flag_check_bms+0 
;BMSToucan.c,271 :: 		tx_counter = 0;
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,272 :: 		}
L_ISR21:
;BMSToucan.c,273 :: 		INTCON.TMR0IF = 0; // reset the TMR0 interrupt flag
	BCF         INTCON+0, 2 
;BMSToucan.c,274 :: 		}
L_ISR20:
L_ISR19:
L_ISR17:
;BMSToucan.c,275 :: 		}
L_end_ISR:
L__ISR39:
	RETFIE      1
; end of _ISR

_CANbus_setup:

;BMSToucan.c,286 :: 		void CANbus_setup()
;BMSToucan.c,307 :: 		CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
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
;BMSToucan.c,310 :: 		CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);
	MOVLW       128
	MOVWF       FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,313 :: 		mask = -1;
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+0 
	MOVLW       255
	MOVWF       CANbus_setup_mask_L0+1 
	MOVWF       CANbus_setup_mask_L0+2 
	MOVWF       CANbus_setup_mask_L0+3 
;BMSToucan.c,314 :: 		CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,317 :: 		CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,320 :: 		CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,322 :: 		CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);
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
;BMSToucan.c,325 :: 		CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
	CLRF        FARG_CANSetOperationMode_mode+0 
	MOVLW       255
	MOVWF       FARG_CANSetOperationMode_WAIT+0 
	CALL        _CANSetOperationMode+0, 0
;BMSToucan.c,326 :: 		} // The CANbus is now set up and ready for use
L_end_CANbus_setup:
	RETURN      0
; end of _CANbus_setup

_reset_candata:

;BMSToucan.c,332 :: 		void reset_candata()
;BMSToucan.c,335 :: 		for (i = 0; i < 8; i++)
	CLRF        R1 
	CLRF        R2 
L_reset_candata22:
	MOVLW       128
	XORWF       R2, 0 
	MOVWF       R0 
	MOVLW       128
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__reset_candata43
	MOVLW       8
	SUBWF       R1, 0 
L__reset_candata43:
	BTFSC       STATUS+0, 0 
	GOTO        L_reset_candata23
;BMSToucan.c,337 :: 		CAN_data[i] = 0;
	MOVLW       _CAN_data+0
	ADDWF       R1, 0 
	MOVWF       FSR1L 
	MOVLW       hi_addr(_CAN_data+0)
	ADDWFC      R2, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;BMSToucan.c,335 :: 		for (i = 0; i < 8; i++)
	INFSNZ      R1, 1 
	INCF        R2, 1 
;BMSToucan.c,338 :: 		}
	GOTO        L_reset_candata22
L_reset_candata23:
;BMSToucan.c,339 :: 		}
L_end_reset_candata:
	RETURN      0
; end of _reset_candata

_setup:

;BMSToucan.c,346 :: 		void setup()
;BMSToucan.c,349 :: 		TRISA = 0; // default PORTA to output
	CLRF        TRISA+0 
;BMSToucan.c,350 :: 		TRISB = 0; // default PORTB to output
	CLRF        TRISB+0 
;BMSToucan.c,351 :: 		TRISC = 0; // default PORTC to output
	CLRF        TRISC+0 
;BMSToucan.c,354 :: 		LATA = 0;
	CLRF        LATA+0 
;BMSToucan.c,355 :: 		LATB = 0;
	CLRF        LATB+0 
;BMSToucan.c,356 :: 		LATC = 0;
	CLRF        LATC+0 
;BMSToucan.c,359 :: 		PORTC.B4 = 1;
	BSF         PORTC+0, 4 
;BMSToucan.c,360 :: 		PORTC.B5 = 1;
	BSF         PORTC+0, 5 
;BMSToucan.c,363 :: 		INTCON.GIE = 1;    // enable global interrupts
	BSF         INTCON+0, 7 
;BMSToucan.c,364 :: 		INTCON.PEIE = 1;   // enable peripheral interrupts
	BSF         INTCON+0, 6 
;BMSToucan.c,365 :: 		INTCON.TMR0IE = 1; // enable timer 0 interrupts to control
	BSF         INTCON+0, 5 
;BMSToucan.c,367 :: 		INTCON2.RBPU = 1;  // disable pull ups on PORTB
	BSF         INTCON2+0, 7 
;BMSToucan.c,368 :: 		INTCON2.INTEDG0 = 1; // interrupt INT0 on rising edge
	BSF         INTCON2+0, 6 
;BMSToucan.c,369 :: 		INTCON2.INTEDG1 = 1; // interrupt INT1 on rising edge
	BSF         INTCON2+0, 5 
;BMSToucan.c,370 :: 		INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
	BSF         INTCON2+0, 2 
;BMSToucan.c,371 :: 		INTCON3.INT2IE = 0; // disable INT2
	BCF         INTCON3+0, 4 
;BMSToucan.c,372 :: 		INTCON3.INT1IE = 1; // enable INT1
	BSF         INTCON3+0, 3 
;BMSToucan.c,373 :: 		INTCON.INT0IE = 1; // enable INT0
	BSF         INTCON+0, 4 
;BMSToucan.c,376 :: 		TRISC.B7 = 1; // set RX to input
	BSF         TRISC+0, 7 
;BMSToucan.c,377 :: 		TRISC.B6 = 0; // set TX to output
	BCF         TRISC+0, 6 
;BMSToucan.c,378 :: 		SPBRG = 64; // set the baud rate at 19.23Kbps @ 20MHz clock
	MOVLW       64
	MOVWF       SPBRG+0 
;BMSToucan.c,379 :: 		TXSTA.BRGH = 1; // high speed baud mode
	BSF         TXSTA+0, 2 
;BMSToucan.c,380 :: 		TXSTA.SYNC = 0; // asynchronous mode
	BCF         TXSTA+0, 4 
;BMSToucan.c,381 :: 		RCSTA.SPEN = 1; // enable the serial port
	BSF         RCSTA+0, 7 
;BMSToucan.c,382 :: 		TXSTA.TXEN = 1; // enable transmission
	BSF         TXSTA+0, 5 
;BMSToucan.c,383 :: 		RCSTA.CREN = 1; // enable receival
	BSF         RCSTA+0, 4 
;BMSToucan.c,384 :: 		TXSTA.TX9 = 0; // 8 bit transmission
	BCF         TXSTA+0, 6 
;BMSToucan.c,385 :: 		RCSTA.RX9 = 0; // 8 bit reception
	BCF         RCSTA+0, 6 
;BMSToucan.c,386 :: 		UART1_init(19200);
	MOVLW       64
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;BMSToucan.c,389 :: 		TRISB.B3 = 1; // set CANRX for outputting transmission
	BSF         TRISB+0, 3 
;BMSToucan.c,390 :: 		TRISB.B2 = 0; // clear CANTX for inputting signal
	BCF         TRISB+0, 2 
;BMSToucan.c,393 :: 		T0CON.TMR0ON = 1; // turn on timer 0
	BSF         T0CON+0, 7 
;BMSToucan.c,394 :: 		T0CON.T08BIT = 1; // set up as an 8 bit timer
	BSF         T0CON+0, 6 
;BMSToucan.c,395 :: 		T0CON.T0CS = 0; // use the instruction clock as the timing signal
	BCF         T0CON+0, 5 
;BMSToucan.c,396 :: 		T0CON.PSA = 0; // use the prescaler
	BCF         T0CON+0, 3 
;BMSToucan.c,397 :: 		T0CON |= 0b00000111; // set a 1:256 prescaler on the T0
	MOVLW       7
	IORWF       T0CON+0, 1 
;BMSToucan.c,403 :: 		CANbus_setup();
	CALL        _CANbus_setup+0, 0
;BMSToucan.c,406 :: 		tx_counter = 0; // reset the transmit counter
	CLRF        _tx_counter+0 
	CLRF        _tx_counter+1 
;BMSToucan.c,407 :: 		flag_ovp = 0; // no ovp problem
	CLRF        _flag_ovp+0 
;BMSToucan.c,408 :: 		flag_lvp = 0; // no lvp problem
	CLRF        _flag_lvp+0 
;BMSToucan.c,409 :: 		flag_check_bms = 0x01; // check the BMS straight up
	MOVLW       1
	MOVWF       _flag_check_bms+0 
;BMSToucan.c,410 :: 		flag_send_can = 0; // no can messages to send yet
	CLRF        _flag_send_can+0 
;BMSToucan.c,411 :: 		current_cell = 0; // start by querying cell #1
	CLRF        _current_cell+0 
	CLRF        _current_cell+1 
;BMSToucan.c,412 :: 		}
L_end_setup:
	RETURN      0
; end of _setup
