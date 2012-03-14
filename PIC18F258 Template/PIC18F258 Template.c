// THIS IS A STANDARD TEMPLATE PROJECT FOR PIC18F258 CIRCUITS

// forward declarations
void setup();
void interrupt_setup();

// some variables
unsigned int timer_count; // the number of overflows before we want to act on T0 overflow
const int MAX_OVERFLOWS = 76; // this is currently set for ~1 second
char flag_timer_overflow;


void main() {
    setup();
    interrupt_setup();
    PORTC.B6 = 1;
    while(1)
    {
         if(flag_timer_overflow == 0xFF)
         {
             PORTC.B6 = (PORTC.B6 == 1) ? 0 : 1;
             flag_timer_overflow = 0;
         }
    };
}


void setup()
{
    // set all ports to output
    TRISA = 0;
    TRISB = 0;
    TRISC = 0;
    
    // set up TIMER0 to use to control our BMS polling rate
    T0CON.TMR0ON = 1; // turn on timer 0
    T0CON.T08BIT = 1; // set up as an 8 bit timer
    T0CON.T0CS = 0; // use instruction clock cycle as the timing signal, not TOCKI
    T0CON.PSA = 0; // use the prescaler
    T0CON |= 0b00000111; // set the prescaler to 1:256 this gives us an
                         // overflow of TMR0 every 0xFF * 256 counts
                         // this equates to 1/76th of a second
    
    // set up interrupts
    interrupt_setup();
    
    // set up variables
    flag_timer_overflow = 0;
    timer_count = 0;
}


void interrupt_setup()
{
// set up the interrupts for LVP / OVP on rising edge
    INTCON.GIE = 1;    // enable global interrupts
    INTCON.TMR0IE = 1; // enable timer 0 interrupts
    INTCON2.TMR0IP = 1; // TMR0 interrupts are high priority
}


void ISR() iv 0x0008
{
    if (INTCON.T0IF == 1)
    {
        timer_count++;
        if (timer_count > MAX_OVERFLOWS) 
        {
            flag_timer_overflow = 0xFF;
            timer_count = 0;
        }
        INTCON.T0IF = 0;
    }
}