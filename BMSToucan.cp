#line 1 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
#line 25 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void setup();
void ISR();
void CANbus_setup();
void reset_candata();



const short SEND_FLAG =_CAN_TX_PRIORITY_0 & _CAN_TX_NO_RTR_FRAME;
const long CAN_ADDRESS = 0x88;
const unsigned int COUNTER_OVERFLOW = 38;





const unsigned char BMS_ERROR_BIT = 6;
const unsigned char V4_BIT = 4;
const unsigned char V3_BIT = 3;
const unsigned char V2_BIT = 2;
const unsigned char V1_BIT = 1;
const unsigned char CELL_NUM_BIT = 0;
const unsigned char BMS_QUERY_BIT_1 = 0x81;
const unsigned char BMS_QUERY_BIT_2 = 0xAA;
const unsigned char BMS_QUERY_LENGTH = 29;
const unsigned char MAX_BMS_CHECK_ABORTS = 10;



const unsigned char BMS_V1_B1 = 2;
const unsigned char BMS_V1_B2 = 3;
const unsigned char BMS_V2_B1 = 6;
const unsigned char BMS_V2_B2 = 7;
const unsigned char BMS_V3_B1 = 10;
const unsigned char BMS_V3_B2 = 11;
const unsigned char BMS_V4_B1 = 14;
const unsigned char BMS_V4_B2 = 15;



const int NUMBER_OF_CELLS = 18;
const int CELLS_PER_GROUP = 4;
const int CELL_IDS[] = {
 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
};
int cell_values[NUMBER_OF_CELLS][CELLS_PER_GROUP];
const float CELL_V_MULTIPLIER = 0.255;





volatile unsigned int tx_counter;
volatile unsigned char flag_ovp;
volatile unsigned char flag_lvp;
volatile unsigned char flag_check_bms;
unsigned char flag_send_can;


int current_cell;
unsigned char CAN_data[8];
unsigned char BMS_buffer[BMS_QUERY_LENGTH];
unsigned char BMS_buffer_idx;
unsigned char aborted_bms_checks;



int zz;
#line 100 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void main() {

 setup();


 PORTC.B4 = 0;
 PORTC.B5 = 0;


 for(;;)
 {

 reset_candata();


 if (flag_ovp == 0x01) {

 CAN_data[BMS_ERROR_BIT].B0 = 1;
 }
 if (flag_lvp = 0x01) {

 CAN_data[BMS_ERROR_BIT].B1 = 1;
 }


 if (flag_check_bms == 0x01) {




 if (BMS_buffer_idx > 0)
 {
 aborted_bms_checks++;


 if (aborted_bms_checks > MAX_BMS_CHECK_ABORTS)
 {

 CAN_data[BMS_ERROR_BIT].B2 = 1;
 aborted_bms_checks = 0;
 BMS_buffer_idx = 0;
 }
 } else {
 aborted_bms_checks = 0;


 current_cell++;
 if(current_cell >= NUMBER_OF_CELLS)
 {
 current_cell = 0;
 }


 UART1_Write(BMS_QUERY_BIT_1);
 UART1_Write(BMS_QUERY_BIT_2);


 UART1_Write(CELL_IDS[current_cell]);
 UART1_Write(CELL_IDS[current_cell]);
 PORTC.B4 = ~PORTC.B4;
 }

 flag_check_bms = 0x00;
 }


 if(UART1_Data_ready())
 {

 BMS_buffer[BMS_buffer_idx] = UART1_read();
 BMS_buffer_idx++;


 if (BMS_buffer_idx == BMS_QUERY_LENGTH)
 {

 CAN_data[0] = CELL_IDS[current_cell];







 cell_values[current_cell][0] =
 (char)(
 (float)(
 (BMS_buffer[BMS_V1_B2] << 8) | BMS_buffer[BMS_V1_B1]
 ) * CELL_V_MULTIPLIER
 );
 CAN_data[V1_bit] = cell_values[current_cell][0];

 cell_values[current_cell][1] =
 (char)(
 (float)(
 (BMS_buffer[BMS_V2_B2] << 8) | BMS_buffer[BMS_V2_B1]
 ) * CELL_V_MULTIPLIER
 );
 CAN_data[V2_bit] = cell_values[current_cell][1];

 cell_values[current_cell][2] =
 (char)(
 (float)(
 (BMS_buffer[BMS_V3_B2] << 8) | BMS_buffer[BMS_V3_B1]
 ) * CELL_V_MULTIPLIER
 );
 CAN_data[V3_bit] = cell_values[current_cell][2];

 cell_values[current_cell][3] =
 (char)(
 (float)(
 (BMS_buffer[BMS_V4_B2] << 8) | BMS_buffer[BMS_V4_B1]
 ) * CELL_V_MULTIPLIER
 );
 CAN_data[V4_bit] = cell_values[current_cell][3];



 flag_send_can = 0x01;
 }
 }


 if(flag_send_can == 0x01)
 {

 for (zz = 0; zz < 8; zz++)
 {
 UART1_Write(CAN_data[zz]);
 }


 CanWrite(CAN_ADDRESS, CAN_data, 1, SEND_FLAG);


 PORTC.B5 = ~PORTC.B5;


 BMS_buffer_idx = 0;
 flag_send_can = 0x00;
 }
 }
}
#line 250 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void ISR() iv 0x0008
{



 if (INTCON3.INT1IF == 1)
 {
 flag_ovp = 0x01;
 INTCON3.INT1IF = 0;
 }
 else if (INTCON.INT0IF == 1)
 {

 flag_lvp = 0x01;
 INTCON.INT0IF = 0;
 }
 else if (INTCON.TMR0IF == 1)
 {

 tx_counter++;
 if(tx_counter > COUNTER_OVERFLOW)
 {
 flag_check_bms = 0x01;
 tx_counter = 0;
 }
 INTCON.TMR0IF = 0;
 }
}
#line 288 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void CANbus_setup()
{
 char SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, txt[4];
 unsigned short init_flag;
 long mask;


 SJW = 1;
 BRP = 1;
 Phase_Seg1 = 6;
 Phase_Seg2 = 7;
 Prop_Seg = 6;

 init_flag = _CAN_CONFIG_SAMPLE_THRICE &
 _CAN_CONFIG_PHSEG2_PRG_ON &
 _CAN_CONFIG_STD_MSG &
 _CAN_CONFIG_DBL_BUFFER_ON &
 _CAN_CONFIG_VALID_STD_MSG &
 _CAN_CONFIG_LINE_FILTER_OFF;


 CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);


 CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);


 mask = -1;
 CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);


 CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);


 CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);

 CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);


 CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
}
#line 334 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void reset_candata()
{
 int i;
 for (i = 0; i < 8; i++)
 {
 CAN_data[i] = 0;
 }
}
#line 348 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void setup()
{

 TRISA = 0;
 TRISB = 0;
 TRISC = 0;


 LATA = 0;
 LATB = 0;
 LATC = 0;


 PORTC.B4 = 1;
 PORTC.B5 = 1;


 INTCON.GIE = 1;
 INTCON.PEIE = 1;
 INTCON.TMR0IE = 1;

 INTCON2.RBPU = 1;
 INTCON2.INTEDG0 = 1;
 INTCON2.INTEDG1 = 1;
 INTCON2.TMR0IP = 1;
 INTCON3.INT2IE = 0;
 INTCON3.INT1IE = 1;
 INTCON.INT0IE = 1;


 TRISC.B7 = 1;
 TRISC.B6 = 0;
 SPBRG = 64;
 TXSTA.BRGH = 1;
 TXSTA.SYNC = 0;
 RCSTA.SPEN = 1;
 TXSTA.TXEN = 1;
 RCSTA.CREN = 1;
 TXSTA.TX9 = 0;
 RCSTA.RX9 = 0;
 UART1_init(19200);


 TRISB.B3 = 1;
 TRISB.B2 = 0;


 T0CON.TMR0ON = 1;
 T0CON.T08BIT = 1;
 T0CON.T0CS = 0;
 T0CON.PSA = 0;
 T0CON |= 0b00000111;





 CANbus_setup();


 tx_counter = 0;
 flag_ovp = 0;
 flag_lvp = 0;
 flag_check_bms = 0x01;
 flag_send_can = 0;
 current_cell = 0;
}
