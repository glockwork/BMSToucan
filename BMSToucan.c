/**
*
*
*
*
*/


void main() {
    // perform setup
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
}


// The high priority interrupt service routine.  This is called
// if either the LVP or OVP pin changes to high (indicating a fault)
// or when TMR0 overflows.  The ISR handles both of these events
void ISR() iv 0x0008h
{
    // start by checking which interrupt was called
    // highest priority is the LVP and OVP signals on
    // INT0 and INT1
    if (INTCON3.INT1IF == 1)
    {

        INTCON3.INT1IF = 0; // reset the interrupt flag to prevent looping
    }
    else if (INTCON.INT0IF == 1)
    {
        INTCON.INT0IF = 0; // reset the interrupt flag to prevent looping
    }
    else if (INTCON

}