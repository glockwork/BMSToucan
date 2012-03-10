/**
*   BMS Toucan, William Hart for Oxford Brookes Racing
*   11082131@brookes.ac.uk / hart.wl@gmail.com
*
*   This module queries the BMS cells at a rate of 2Hz.  On each cycle
*   one cell grouping is queried via the serial connections.  (One cell
*   group is four individual battery cells).
*
*   When cell information is received from the LifeBatt BMS it is converted
*   to a can message and retransmitted under address 207.  The message contains
*   format conforms to the following template:
*   $0000000207,CELL#,V1,V2,V3,V3,00,00*PARITY
*
*   Cell voltages are from 0-255, with a multiplier of 0.05 (e.g. a value of
*   0xAB is equal to 171 decimal, when multiplied by 0.05 this corresponds to
*   a cell reading of 8.55v.
*/


// forward function delcarations
void setup();
void ISR();
void CANbus_setup();

// global variables
volatile int tx_counter;
volatile char flag_ovp;
volatile char flag_lvp;
volatile char flag_check_bms;

void main() {
    // perform setup
    setup();
    
    // loop
    while(0);
}


// performs microcontroller setup, including CANBus settings,
// serial comms settings and various peripherals
void setup()
{
    // set up default port settings
    TRISA = 0; // default PORTA to output
    TRISB = 0; // default PORTB to output
    TRISC = 0; // default PORTC to output
    
    // set up the interrupts for LVP / OVP on rising edge
    INTCON.GIE = 1;    // enable global interrupts
    INTCON.PEIE = 1;   // enable peripheral interrupts
    INTCON.TMR0IE = 1; // enable timer 0 interrupts to control
                       // BMS polling frequency
    INTCON2.RBPU = 1;  // disable pull ups on PORTB
    INTCON2.INTEDG0 = 1; // interrupt INT0 on rising edge
    INTCON2.INTEDG1 = 1; // interrupt INT1 on rising edge
    INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
    INTCON3.INT2IE = 0; // disable INT2
    INTCON3.INT1IE = 1; // enable INT1
    INTCON.INT0IE = 1; // enable INT0

    // enable the serial module
    RCSTA.SPEN = 1; // enable the serial port
    RCSTA.RX9 = 0; // 8 bit mode
    TXSTA.SYNC = 0; // start in asynchronous mode
    TRISC.B7 = 1; // set the RX bit to output
    
    // configure the serial baud rate using the baud rate generator
    TXSTA.BRGH = 1; // High speed serial
    SPBRG = 64; // set the baud to 20Mhz / 19200 baud
    
    // set up the can module
    TRISB.B3 = 1; // set CANRX for outputting transmission
    TRISB.B2 = 0; // clear CANTX for inputting signal
    
    // set up TIMER0 to use to control our BMS polling rate
    T0CON.TMR0ON = 1; // turn on timer 0
    T0CON.T08BIT = 0; // set up as a 16 bit timer
    T0CON.T0CS = 0; // use CLK0 as the timing signal
    T0CON.PSA = 0; // do not use the prescaler
    T0CON.T0PS2 = 1; // set the prescaler to 1:256
    T0CON.T0PS1 = 1; // this gives us an overflow of TMR0 every 0xFFFF * 256
    T0CON.T0PS0 = 1; // clock cycles (at 20Mhz)
    
    // perform CAN bus setup
    CANbus_setup();
    
    // initialise values
    tx_counter = 0; // reset the transmit counter
    flag_ovp = 0; // no ovp problem
    flag_lvp = 0; // no lvp problem
    flag_check_bms = 0; // don't check the BMS just yet
}



// The high priority interrupt service routine.  This is called
// if either the LVP or OVP pin changes to high (indicating a fault)
// or when TMR0 overflows.  The ISR handles both of these events
void ISR() iv 0x0008
{
    // start by checking which interrupt was called
    // highest priority is the LVP and OVP signals on
    // INT0 and INT1
    if (INTCON3.INT1IF == 1)
    {   // INT1 indicates an over voltage problem

        INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
    }
    else if (INTCON.INT0IF == 1)
    {
        INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
    }
    else if (INTCON.T0IF == 1)
    {
        INTCON.T0IF = 0; // reset the TMR0 interrupt flag
    }
}


// The following code was written by James Larminie and Marco Cecotti.
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