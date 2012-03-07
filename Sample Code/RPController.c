/****************************************************************

Relay Power Contr
For details of message contruction, see the system manual.
*/
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

Author:   Oxford Brookes University
Date:     May 2011
File:     RPController.c
**************************************************************/

// We start with the global variables
volatile unsigned int Tcount10Hz, Tcount1Hz; // Used for timing, incremented
                                             // each interrupt.
unsigned int energy;
unsigned int I=0, V=0, T1=0, T2=0; // Battery voltages and temperature
unsigned char charge;
unsigned char Accel; // Throttle postion
unsigned char state=1;  // If on, we must be state no. 1
unsigned char ERR_FLAG=0xFF;  // Turn error flag to nothing OK
unsigned char brakelight=0; // Is the brake light on?
unsigned char FN_flags=0; // Error flags from the front node.




//prototypes of the procedures used. Due to the use of global variables, they
// are all voids. Generally, their basic action is clear from their name.
void WhatState();
void IndicateState();
void SetErrorFlags();
void OperateRL3();
void CANbus_setup();
void interrupt();
void setup_interrupts();
// Now we have the main procedure.
void main()
{
  unsigned char CANdata[8];
  unsigned char A, B; // scratch-pad variables
  long id;
  unsigned short send_flag, dt, len, read_flag;
  float chargeInc=0;
  float energyInc=0;
  float x,y,E,Q;  // floats used for energy and charge calcs.
 
  // Set up the structures for the CANbus messages that are transmitted
  // by this node. See manual. These relate to its the system status, and
  // the total charge and energy used.
  struct CAN
  {
         long id;
         short len;
         unsigned char mdata[8];
  }errors, totals;
   errors.id=1024;
   errors.len=2;
   totals.id=1025;
   totals.len=3;
   
// Get the CANbus ready
send_flag = _CAN_TX_PRIORITY_0 & _CAN_TX_NO_RTR_FRAME;
CANbus_setup();
// Set up and start the timing interrupts
setup_interrupts();
// setup the ports
TRISA =0xFF;  // PORTA is input
ADCON1 =0x07;  // Configure AN pins 0-3 as digital I/O, page 242
TRISC = 0;   // PORT C is for output

// Read the energy and charge values out of EEPROM.
charge=EEPROM_Read(1);
delay_ms(20);
A = EEPROM_Read(2); //LSB of energy value
delay_ms(20);
B = EEPROM_Read(3); //MSB of energy value
energy = (B*256) + A;

E=energy;   // Convert charge and energy to float
Q=charge;


  for(;;)     /* Endless loop   */
  {
     WhatState();
     IndicateState();
     SetErrorFlags();
     OperateRL3();
     // See if any CAN messages in.
     dt = CANRead(&id, CANdata, &len, &read_flag);
            if (dt>0) { /*Message received     */
                   if (id==128){
                   FN_flags= CANdata[2]; // Map Fn errors
                   Accel = CANdata[0];  // Accel postion, 0-200
                   }
                   if (id==150){
                      I=(CANdata[0] + (CANdata[1]<<8));   // NB V and I are x10
                      V=(CANdata[2] + (CANdata[3]<<8));
                   }
                   if (id==512) brakelight=CANdata[0];
                   if  (id==1026){
                      T1=CANdata[0];
                      T2=CANdata[1];
                   }
                   if (id==1280){
                      energy=0, E=0, energyInc=0;
                      charge=0, Q=0, chargeInc=0;
                   }
             } // end of dealing with messages.
             
     if (Tcount1Hz>1000){   // Do this at 1 Hz
        Tcount1Hz=0;
        // Update float values of energy and charge totals.
        // E is in 10th of Watt hours, and Q is in 10th of Ah.
        E = E + (energyInc/360);
        energyInc=0;
        Q = Q + ((chargeInc/100)/360);
        chargeInc=0;
        // And udate low res integer values as well
        energy=E;
        charge=Q;
        // Send out the two CAN messages.
        errors.mdata[1]=state;
        errors.mdata[0]=ERR_FLAG;
        CANWrite(errors.id, errors.mdata, errors.len, send_flag);
        // Now set up the CAN charge and energy message, and write the data
        // to EEPROM.
        totals.mdata[0]=charge;
        EEPROM_write(1,charge);
        totals.mdata[1]=energy;
        EEPROM_write(2,totals.mdata[1]);
        totals.mdata[2]=energy>>8; // MS byte second
        EEPROM_write(3,totals.mdata[2]);
        CANWrite(totals.id, totals.mdata, totals.len, send_flag);
          } // end of 1 Hz actions
     if (Tcount10Hz>100) { // Do this at 10Hz
        Tcount10Hz=0;
        x = I;  // Be careful to do anything tricky while float
        chargeInc = (chargeInc + x);
        // chargeInc is in coulombs, and x100
        // Remember that I and V are both x10
        y = V;
        energyInc = (energyInc + ((x*y/1000)));
        // energyInc is the energy in Joules
        } // end of 10Hz energy and charge calculations.
     } /* End of endless loop    */
}   /* End of void main()   */




// This void reads the digital inputs to find what state we are in
void WhatState()
{    char X;
     X=PORTA & 0x07;
     state=1; //The default value
     if (X==1) state=2;
     if (X==3) state=3;
     if (X==7) state=4;
}
// The procedure turns on and off the tricolour LED which indicated what state
// the system is in. It uses the value of Tcount1Hz to make the LED flash at 1
// Hz. Tcount1Hz increments to 1000 and then resets. So it will be above 500
// half the time.
void IndicateState()
{
     if (Tcount1Hz>500) PORTC=PORTC & 0x0F;
     else{
          if (state==1)PORTC = PORTC | 0x10;
          if (state==2)PORTC = PORTC | 0x20;
          if (state>=3)PORTC = PORTC | 0x30;
     }
}
// The procedure sets each bit of the error flag byte. The relevant section of
// the manual must be read to see what is going on.
void SetErrorFlags()
 {
 // Bit 0
 if (state<3) ERR_FLAG.F0=!brakelight;
 else ERR_FLAG.F0=0;
 // Bit 1 accel pots stuck?
 ERR_FLAG.F1=FN_flags.F0;
 // Bit 2, batteries too hot?
 if ((T1>60) || (T2>60)) ERR_FLAG.F2=1;
 else ERR_FLAG.F2=0;
 // Bit 3 accel pots disconnected?
 ERR_FLAG.F3=FN_flags.F1;
 // Bit 4 battery dying?
 if (V<1730) ERR_FLAG.F4=1;  // V is the voltage x10, so this is for 173 Volts
 else ERR_FLAG.F4=0;
 // Bit 5, motor controller OK?
 ERR_FLAG.F5 = 0;
 // Bit 6, Accel pressed when in states 2 or 3
 if ((state<4) && (Accel>50)) ERR_FLAG.F6 = 1;
 else ERR_FLAG.F6 = 0;
 // Bit 7, CAN communication OK?
 ERR_FLAG.F7 = 0;
 }
 // Turns on RL3 if there are no errors.
 void OperateRL3() {
 unsigned char flag;
 // Ignore the battery voltage in states 1, 2 and 3.
 if (state<4) flag = ERR_FLAG & 0xEF;
 else flag = ERR_FLAG;

 if (flag==0) PORTC = PORTC | 0x03; // All is well, RL3 ON
 else PORTC = PORTC & 0xF0;  // All is not well, RL3 OFF
 }

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
//  Initialise CAN module
      CANInitialize(SJW, BRP, Phase_Seg1, Phase_Seg2, Prop_Seg, init_flag);
// Set CAN CONFIG mode
     CANSetOperationMode(_CAN_MODE_CONFIG, 0xFF);
      mask = -1;
// Set all MASK1 bits to 1's
      CANSetMask(_CAN_MASK_B1, mask, _CAN_CONFIG_STD_MSG);
      CANSetMask(_CAN_MASK_B2, mask, _CAN_CONFIG_STD_MSG);
//Filter 128 (pedal box), 150 (battery I and V), 512 (brake light)
// 1026 (battery temps) and 1280 (zero energy totals).
      CANSetFilter(_CAN_FILTER_B1_F1,128,_CAN_CONFIG_STD_MSG);
      CANSetFilter(_CAN_FILTER_B1_F2,150,_CAN_CONFIG_STD_MSG);
      CANSetFilter(_CAN_FILTER_B2_F1,512,_CAN_CONFIG_STD_MSG);
      CANSetFilter(_CAN_FILTER_B2_F2,1026,_CAN_CONFIG_STD_MSG);
      CANSetFilter(_CAN_FILTER_B2_F3,1280,_CAN_CONFIG_STD_MSG);
// Now set CAN module to NORMAL mode, as setup done.
      CANSetOperationMode(_CAN_MODE_NORMAL, 0xFF);
}// The CANbus is now set up and ready for use.

 /* This program uses interrupts to drive the timing.
    The only enabled interrupt is the TIMER0 interrupt, so the interrupt
    handler is very simple. It just increments a counter Tcount.

     This is the interrupt service procedure. All it does is increment
     the value of Tcount, reload Timer0, and reset the interrupts.
     The interrupts control register must be re-loaded, as explained in
     the relevant section of the PIC manual.     */
void interrupt(){
       Tcount10Hz++;
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
      Tcount10Hz=0;
      Tcount1Hz=0;
       T0CON= 0xD5; /* = 1101 0101. Pre-scaler for Timer0 =1:64, turn
                       on Timer0, and keep in 8 bit mode. See Timer0 section
                      of any PIC 18F data sheet. */
       TMR0L=178;   /* Load initial value of Timer0.  */
       INTCON=0xA0; /* 10100000, Enable interrupts generally, and Timer0 only.
                       See Interrupts section of PIC 18F manual.  */
      }