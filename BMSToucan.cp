#line 1 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
#line 20 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void setup();
void ISR();
void CANbus_setup();

void main() {

 setup();


 while(0);
}




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
}






void ISR() iv 0x0008
{



 if (INTCON3.INT1IF == 1)
 {

 INTCON3.INT1IF = 0;
 }
 else if (INTCON.INT0IF == 1)
 {
 INTCON.INT0IF = 0;
 }
 else if (INTCON.T0IF == 1)
 {
 INTCON.T0IF = 0;
 }
}
#line 112 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void CANbus_setup()
{
 char SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, txt[4];
 unsigned short init_flag;
 long mask;
#line 120 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
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
#line 135 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
#line 139 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);

 mask = -1;
#line 144 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
#line 147 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
 CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);



 CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);

 CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);



 CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
}
