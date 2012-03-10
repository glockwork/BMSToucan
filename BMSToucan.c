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
*   $0000000207,CELL#,V1,V2,V3,V4,LVP_FLAG,OVP_FLAG,00*PARITY
*
*   Cell voltages are from 0-255, with a multiplier of 0.05 (e.g. a value of
*   0xAB is equal to 171 decimal, when multiplied by 0.05 this corresponds to
*   a cell reading of 8.55v.
*/


// forward function delcarations
void setup();
void ISR();
void CANbus_setup();
void reset_candata();

// global flags and counters for use with interrupts
volatile unsigned int tx_counter; // counter used for TMR0 overflow
const unsigned int COUNTER_OVERFLOW = 100; // counter overflows after this many loops
volatile unsigned char flag_ovp; // flags an OVP problem raised by the BMS
volatile unsigned char flag_lvp; // flags an LVP problem raised by the BMS
volatile unsigned char flag_check_bms; // flag set when it is time to query a BMS cell

// other global variables
int current_cell;
unsigned char CAN_data[8];


// Constants
const short SEND_FLAG =_CAN_TX_PRIORITY_0 & _CAN_TX_NO_RTR_FRAME;
const int NUMBER_OF_CELLS = 18; // the number of battery cells to check
const long CAN_ADDRESS = 0x88; // the address of this can message
const unsigned char OVP_BIT = 6; // some constants for addressing CAN_data
const unsigned char LVP_BIT = 5; // message bits
const unsigned char V4_BIT = 4;
const unsigned char V3_BIT = 3;
const unsigned char V2_BIT = 2;
const unsigned char V1_BIT = 1;
const unsigned char CELL_NUM_BIT = 0;

/**
*  The main loop - checks the status of interrupt flags and actions
*  them if required.  Flags indicate different actions are required:
*    - flag_ovp:  if equal to 1, an over voltage problem exists
*    - flag_lvp:  if equal to 1, a low voltage problem exists
*    - flag_check_bms: if equal to 1, it is time to check the next BMS cell
*/
void main() {
    // perform setup
    setup();
    
    // main loop
    for(;;)
    {
        // clear previous CAN_data[] values
        reset_candata();
        
        // check for flags
        if (flag_ovp) {
            // we have found a OVP problem - send the appropriate CAN message
            CAN_data[OVP_BIT] = 0x01;
        }
        if (flag_lvp) {
            // we have found a LVP problem - send the appropriate CAN message
            CAN_data[LVP_BIT] = 0x01;
        }
        if (flag_check_bms) {
            // we need to check the next BMS cell
            
        }
        
        // write the CAN message
        CanWrite(CAN_ADDRESS, CAN_data, 1, SEND_FLAG);
    }
}


/**
* The high priority interrupt service routine.  This is called
* if either the LVP or OVP pin changes to high (indicating a fault)
* or when TMR0 overflows.  The ISR handles both of these events
*/
void ISR() iv 0x0008
{
    // start by checking which interrupt was called
    // highest priority is the LVP and OVP signals on
    // INT0 and INT1
    if (INTCON3.INT1IF == 1)
    {   // INT1 indicates an over voltage problem
        flag_ovp = 1;
        INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
    }
    else if (INTCON.INT0IF == 1)
    {
        // INT0 indicates a low voltage problem
        flag_lvp = 1;
        INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
    }
    else if (INTCON.T0IF == 1)
    {
        // increment the counter and check if we have reached the limit
        tx_counter++;
        if(tx_counter > COUNTER_OVERFLOW)
        {
            flag_check_bms = 1;
            tx_counter = 0;
        }
        INTCON.T0IF = 0; // reset the TMR0 interrupt flag
    }
}


/**
* The following code was written by James Larminie and Marco Cecotti and
* modified for purpose by William Hart.
*
* Original Comments:
* This void sets up the CAN bus. Careful reading of the manuals is needed
   to understand what is going on. But it can be taken on trust!!   
*/

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


/*
* Loops through the CAN data array and clears previous values
*/
void reset_candata()
{
    int i;
    for (i = 0; i < 8; i++)
    {
        CAN_data[i] = 0;
    }
}


/**
* This function performs microcontroller setup, including CANBus settings,
* serial comms settings and disabling peripherals that aren't required
*/
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
    flag_check_bms = 0; // don't check BMS
    current_cell = 1; // start by querying cell #1
}
