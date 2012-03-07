/****************************************************************

Rear node program.
This node receives commands to turn on/off the brake light, the
coolant pump, and a fan.
Three bits of Port C are connected to high current MOSFETs to
drive these three outputs, using the bits 0, 1 and 2.
LEDs are connected to bits 4, 5 and 6, and these are turned on
to correspond to the high current outputs, as a fault finding
aid.
About twice a second the node transmits a single data byte giving
its current status. This is so that the supervisory node can
verify that the node is working correctly.

For details of message contruction, see the system manual.

Last update : 20th May 2010
Copyright Oxford Brookes University

Program begins with variable declarations. This sole global
variable is incremented each interrupt. It is used to time regular
actions, in this case just the transmit status byte.

*/
unsigned int Tcount;

 /*
Now set up the CANbus
CAN speed parameters are:

    Microcontroller clock:  20MHz
    CAN Bus bit rate:       500Kb/s
    Sync_Seg:               1
    Prop_Seg:               6
    Phase_Seg1:             6
    Phase_Seg2:             7
    SJW:                    1
    BRP:                    1
    Sample point:           65%

Author:   FSE team
Date:     May 2010
File:     RearNode.c
**************************************************************/

/* This void sets up the CAN bus. Careful reading of the manuals is needed
   to understand what is going on. But it can be taken on trust!!   */
   
void CANbus_setup()
{
     char SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, txt[4];
     unsigned short init_flag;
     long mask;

/* CAN BUS Timing Parameters
*/
     SJW = 1;
     BRP = 1;
     Phase_Seg1 = 6;
     Phase_Seg2 = 7;
     Prop_Seg = 6;

     init_flag = CAN_CONFIG_SAMPLE_THRICE  &
                 CAN_CONFIG_PHSEG2_PRG_ON  &
                 CAN_CONFIG_STD_MSG        &
                 CAN_CONFIG_DBL_BUFFER_ON  &
                 CAN_CONFIG_VALID_STD_MSG &
                 CAN_CONFIG_LINE_FILTER_OFF;
/*
 Initialise CAN module
*/
      CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);

/* Set CAN CONFIG mode  */

     CANSetOperationMode(CAN_MODE_CONFIG, 0xFF);
/* Set all MASK1 bits to 1's  */
      mask = -1;
      CANSetMask(CAN_MASK_B1, mask, CAN_CONFIG_STD_MSG);

/* Set all MASK2 bits to 1's  */
      CANSetMask(CAN_MASK_B2, mask, CAN_CONFIG_STD_MSG);
/* The only messages listened to have id 0x200 and 0x201. Set filters to
   let these through only.   */
      CANSetFilter(CAN_FILTER_B2_F3,0x200,CAN_CONFIG_STD_MSG);
      CANSetFilter(CAN_FILTER_B1_F1,0x201,CAN_CONFIG_STD_MSG);
/* Now set CAN module to NORMAL mode, as setup done.  */
      CANSetOperationMode(CAN_MODE_NORMAL, 0xFF);
}
/* The CANbus is now set up and ready for use    */

 /* This program uses interrupts to drive the timing.
    The only enabled interrupt is the TIMER0 interrupt, so the interrupt
    handler is very simple. It just increments a counter Tcount. */

  /* THis is the interrupt service procedure. All it does is increment
     the value of Tcount, reload Timer0, and reset the interrupts.
     The interrupts control register must be re-loaded, as explained in
     the relevant section of the PIC manual.     */
void interrupt(){
       Tcount++;
       TMR0L=178;   /*Re-load Timer0 to give 256-178 = 78 counts each int.*/
       INTCON=0xA0;  /* Enable interrupts, enable Timer0 interrupts, clear
                     Timer0 interrupt flag  */
                } /* End of interrupt handler */
  
  
/* This procedure sets up the interrupts to occur approx. 1kHz The reasoning
   is as follows:-
   
    Timer0 is driven from the clock, but divided by 4.
     (See Figure 11-1 on page 126)
     This is then pre-scaled by a divide by a 1:64 divider. (N.B. This can be
     cahnged.)
     So, the frequency of counting Timer0 = 20/4/64 Mhz = 78.125 kHz

     So, if we want interrupts at roughly 1kHz, we make Timer0 do 78
     counts between each interrupt. This means we load Timer0 with
     256 - 78 = 178.
     */

void setup_interrupts(){
       Tcount=0;
       T0CON= 0xC5; /* = 1100 0101. Pre-scaler for Timer0 =1:64, turn
                      on Timer0, and keep in 8 bit mode. See Timer0 section
                      of any PIC 18F data sheet. */
      TMR0L=178;       /* Load initial value of Timer0.   */
      INTCON=0xA0;     /* 10100000, Enable interrupts generally, and Timer0 only.
                       See Interrupts section of PIC 18F manual.*/
      }
      
void main()
{
  unsigned char loadStatus, readData, data[8];
  long id;
  unsigned short send_flag, dt, len, read_flag;
     loadStatus=0;
     TRISC = 0;   /* PORT C is for output   */
     PORTC= 0x11; /* Turn on a LED and brake light to show life */
     Delay_ms(1000);
     PORTC=0x00; /* Turn both off again */
     
  send_flag = CAN_TX_PRIORITY_0  &
                 CAN_TX_STD_FRAME   &
                 CAN_TX_NO_RTR_FRAME;

  read_flag = 0;
  /* Get the CANbus ready  */
  CANbus_setup();
  /* Set up and start the timing interrupts   */
  setup_interrupts();
  


  for(;;)     /* Endless loop  */
  {

        if (Tcount>500) { /* Approx twice a second   */
                     id = 0x202;        /* Send present status */
                     data[0]=loadStatus;
                     CANWrite(id, data, 1, send_flag);
                     Tcount=0; /* reset back to 0  */
                        } /*End periodic action of sending status   */

        dt = CANRead(&id, data, &len, &read_flag);
        if (dt>0) { /* Message received !!    */
            readData= data[0];  /* Only look at the first byte.  */

          if(id == 0x200){
                /* Turn on or off brake light  */
                PORTC.F0=readData.F0;  /* Brake light  */
                PORTC.F4=readData.F0;  /* On board LED diagnostic  */
                loadStatus.F0 = readData.F0; /*Set or reset bit is status byte */
                 } /* end of stuff for message i.d =0x200  */
                 
           if (id == 0x201){ /* Bits 0 and 1 are looked at here */
                    /*  Deal with pump first   */
                   PORTC.F1=readData.F0; /* Pump    */
                   PORTC.F5=readData.F0; /* On-board LED */
                   loadStatus.F1 =readData.F0; /* Status byte   */
                   /* And now the radiator fan    */
                   PORTC.F2=readData.F1;
                   PORTC.F6=readData.F1;
                   loadStatus.F2 =readData.F1;
              }  /* end of stuff for message i.d =0x201   */
        }  /* End of bit done if any message received.  */
    } /* End of endless loop    */
}   /* End of void main()   */

