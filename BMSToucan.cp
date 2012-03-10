#line 1 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
#line 21 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void setup();
void ISR();
void CANbus_setup();
void reset_candata();


volatile unsigned int tx_counter;
const unsigned int COUNTER_OVERFLOW = 100;
volatile unsigned char flag_ovp;
volatile unsigned char flag_lvp;
volatile unsigned char flag_check_bms;


int current_cell;
const int NUMBER_OF_CELLS = 18;
unsigned char CAN_data[8];
const long CAN_ADDRESS = 0x88;
#line 46 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void main() {

 setup();


 for(;;)
 {

 reset_candata();


 if (flag_ovp) {


 }
 if (flag_lvp) {


 }
 if (flag_check_bms) {


 }
 }
}
#line 78 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void ISR() iv 0x0008
{



 if (INTCON3.INT1IF == 1)
 {
 flag_ovp = 1;
 INTCON3.INT1IF = 0;
 }
 else if (INTCON.INT0IF == 1)
 {

 flag_lvp = 1;
 INTCON.INT0IF = 0;
 }
 else if (INTCON.T0IF == 1)
 {

 tx_counter++;
 if(tx_counter > COUNTER_OVERFLOW)
 {
 flag_check_bms = 1;
 tx_counter = 0;
 }
 INTCON.T0IF = 0;
 }
}
#line 117 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void CANbus_setup()
{
 char SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, txt[4];
 unsigned short init_flag;
 long mask;
#line 125 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
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
#line 140 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
#line 144 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);

 mask = -1;
#line 149 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
#line 152 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);



 CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);

 CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);



 CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
}
#line 169 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void reset_candata()
{
 int i;
 for (i = 0; i < 8; i++)
 {
 CAN_data[i] = 0;
 }
}
#line 183 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void setup()
{

 TRISA = 0;
 TRISB = 0;
 TRISC = 0;


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


 RCSTA.SPEN = 1;
 RCSTA.RX9 = 0;
 TXSTA.SYNC = 0;
 TRISC.B7 = 1;


 TXSTA.BRGH = 1;
 SPBRG = 64;


 TRISB.B3 = 1;
 TRISB.B2 = 0;


 T0CON.TMR0ON = 1;
 T0CON.T08BIT = 0;
 T0CON.T0CS = 0;
 T0CON.PSA = 0;
 T0CON.T0PS2 = 1;
 T0CON.T0PS1 = 1;
 T0CON.T0PS0 = 1;


 CANbus_setup();


 tx_counter = 0;
 flag_ovp = 0;
 flag_lvp = 0;
 flag_check_bms = 0;
 current_cell = 1;
}
