/****************************************************************

Front node program.

At 20 Hz, it sends data on the following:-
  On message id 0x200, a Brake Light on/off command
  On message id 0x80:-
   * Accelerator position
   * Brake pedal position
   * An error flag, indicating possible problems with the
     accelerator pedal and the temperature sensing and rear nodes.

For details of message contruction, see the system manual.
*/

unsigned int Tcount20Hz, Tcount1Hz;
/* This are the variables incremented each interrupt
   They are used to time regular actions     */
                        
/*
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

Author:   James Larminie & Marco Cecotti
Date:     17 June 2010
File:     FrontNode.c
**************************************************************/

/* This void sets up the CAN bus. Careful reading of the manuals is needed
   to understand what is going on. But it can be taken on trust!!   */

void CANbus_setup()
{
     char SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, txt[4];
     unsigned short init_flag;
     long mask;
/*
   CAN BUS Timing Parameters
*/
     SJW = 1;
     BRP = 1;
     Phase_Seg1 = 6;
     Phase_Seg2 = 7;
     Prop_Seg = 6;

     init_flag = _CAN_CONFIG_SAMPLE_THRICE  &
                 _CAN_CONFIG_PHSEG2_PRG_ON  &
                 _CAN_CONFIG_STD_MSG        &
                 _CAN_CONFIG_DBL_BUFFER_ON  &
                 _CAN_CONFIG_VALID_STD_MSG &
                 _CAN_CONFIG_LINE_FILTER_OFF;
/*
  Initialise CAN module
*/
      CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
/*
   Set CAN CONFIG mode
*/
     CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);

      mask = -1;
/* Set all MASK1 bits to 1's
*/
      CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
/*
   Set all MASK2 bits to 1's    */
      CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
      
/* Filter 0x50 (temp node) and 0x202 (rear node) only   */

      CANSetFilter(_CAN_FILTER_B1_F1,0x202,_CAN_CONFIG_STD_MSG);

      CANSetFilter(_CAN_FILTER_B1_F2,0x50,_CAN_CONFIG_STD_MSG);

/* Now set CAN module to NORMAL mode, as setup done.   */

      CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
}/* The CANbus is now set up and ready for use  */

 /* This program uses interrupts to drive the timing.
    The only enabled interrupt is the TIMER0 interrupt, so the interrupt
    handler is very simple. It just increments a counter Tcount.

     This is the interrupt service procedure. All it does is increment
     the value of Tcount, reload Timer0, and reset the interrupts.
     The interrupts control register must be re-loaded, as explained in
     the relevant section of the PIC manual.     */
void interrupt(){
       Tcount20Hz++;
       Tcount1Hz++;
       TMR0L=178;   /* Re-load Timer0 to give 256-178 = 78 counts each int. */
       INTCON=0xA0;  /* Enable interrupts, enable Timer0 interrupts, clear
                        Timer0 interrupt flag     */
  } /* End of interrupt handler */


/*  This procedure sets up the interrupts to occur approx. 1kHz The reasoning
    is as follows:-

    Timer0 is driven from the clock, but divided by 4.
    (See Figure 11-1 on page 126)
    This is then pre-scaled by a divide by a 1:64 divider. (N.B. This can be
    changed.)
    So, the frequency of counting Timer0 = 20/4/64 Mhz = 78.125 kHz

    So, if we want interrupts at roughly 1kHz, we make Timer0 do 78
    counts between each interrupt. This means we load Timer0 with
    256 - 78 = 178. */

void setup_interrupts(){
      Tcount20Hz=0;
      Tcount1Hz=0;
       T0CON= 0xD5; /* = 1101 0101. Pre-scaler for Timer0 =1:64, turn
                       on Timer0, and keep in 8 bit mode. See Timer0 section
                      of any PIC 18F data sheet. */
       TMR0L=178;   /* Load initial value of Timer0.  */
       INTCON=0xA0; /* 10100000, Enable interrupts generally, and Timer0 only.
                       See Interrupts section of PIC 18F manual.  */
      }

void main()
{
  unsigned char value, lastValue, CANdata[8];
  /* These variables are used to check that the rear node and the
    temperature sensing node are active. */
  signed char WaitingPeriods, state202, state50, stateLight;
  unsigned char c; /* A counter for doing things several times */
  unsigned long Brake_light; /* 1 if brake light should be on, off=0  */
  unsigned char error_flag=0;
  long id;
  unsigned short send_flag, dt, len, read_flag;
  unsigned int total, V0,V1,V2,V3,tempX10;

  
  send_flag = _CAN_TX_PRIORITY_0          &
                 _CAN_TX_NO_RTR_FRAME;

/* The state of the CANbus Messages can be:
 0 or less : Message not received in the last WaitingPeriods periods
 x [x from 520 to 1] : Message received (WaitingPeriods-x) periods ago
   The states begin at 20:  */
  WaitingPeriods = 5;
  state202 = 0;
  state50 = 0;
  stateLight = 0;


  /* Get the CANbus ready    */
  CANbus_setup();
  /* Set up and start the timing interrupts   */
  setup_interrupts();

TRISA =0xFF;  /* PORTA is input    */
ADCON1=0x80; /* Use supply as Vref.   */


TRISC = 0;   /* PORT C is for output */
PORTC= 0x10; /* Turn on a LED to show life  */

/* Program loop.
*/
  Brake_light=0;

  for(;;)     /* Endless loop   */
  {

     if (Tcount20Hz>50){  /* Do this at 20 Hz, roughly  */
     
        /* Read the ADC channels
           Channels 0 and 1 first  */
        V0=Adc_Read(0);
        V1=Adc_Read(1);
        total=V0+V1;
        /* Now Channel 2, brake pedal */
        V2=Adc_Read(2);
        /* Repeat for Channel 3, brake light level setting pot. */
        V3=Adc_Read(3);

          /* Now decide if Brake light should be on.  */
        if (V2>V3) Brake_light=1;
           else Brake_light=0;
        /* Switch on-board LED for diagnostics      */
        PORTC.F5=Brake_light;

        /* Transmit the accelerator and brake pedal settings   */
        value=V0/5; /* Scale to 0 to 200 from 0 to 1023 */
        if (value>200) value=200;
        if ((value==lastValue)&&(value>60)) c++;
           else c=0;
        /* If the throttle pos is stuck, and over 30% for more than
           5*20= 120 loops, i.e. 5 seconds, then assume stuck. */
        if (c>120) error_flag.F1=1;
            else error_flag.F1=0;
        if (c>130) c=130; /* Stop c reseting to 0 by going over 255 */
        lastValue=value;
         
        /* Now check pedals are not stuck. The total reading from both
          pots should be 1023, as one falls as the other rises. Initially
          allow 300 either side of this. */
        if ((total<723)||(total>1323)) error_flag.F0=1;
            else error_flag.F0=0;
         
        /* Now set up the data for message 0x80 */
        CANdata[0]=value;
        /* Scale the brake pedal setting to 0-200 */
        value=V2/5;
        CANdata[1]=value;
        CANdata[2]=error_flag;
        id=0x80;
        CANWrite(id, CANdata, 3, send_flag);
        /* Transmit brake light message, which has id 0x200 */
        CANdata[0]=Brake_light;
        id=0x200;
        CANWrite(id, CANdata, 1, send_flag);
         
        Tcount20Hz=0;
    } /* End of things done at 20Hz    */

    if (Tcount1Hz>1000){  /* Do this at 1 Hz, roughly    */
        if (state202==0){
            error_flag.F6=1;
        }
        else{
            state202--;
            error_flag.F6=0;
        }
        if (state50==0){
            error_flag.F7=1;
        }
        else{
            state50--;
            error_flag.F7=0;
        }
                
        if (stateLight==0)
            error_flag.F3=1;
        else{
            stateLight--;
            error_flag.F3=0;
        }
                
                
                Tcount1Hz=0;
        }
                


        dt = CANRead(&id, CANdata, &len, &read_flag);
                
        if (dt>0){ /*Message received     */
                      if (id==0x202){
                            state202=WaitingPeriods;
                            error_flag.F4=CANdata[0].F1;
                            error_flag.F5=CANdata[0].F2;
                            if (Brake_light == CANdata[0].F0)
                                 stateLight=WaitingPeriods;
                      }
                            
                      if (id==0x50){
                            state50=WaitingPeriods;
                            tempX10= (CANdata[0]<<8) + CANdata[1];
                            if  (tempX10>600) error_flag.F2=1;
                                else error_flag.F2=0;
                      }
                   }


    } /* End of endless loop    */
}   /* End of void main()   */