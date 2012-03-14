#line 1 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/PIC18F258 Template/PIC18F258 Template.c"



void setup();
void interrupt_setup();


unsigned int timer_count;
const int MAX_OVERFLOWS = 76;
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

 TRISA = 0;
 TRISB = 0;
 TRISC = 0;


 T0CON.TMR0ON = 1;
 T0CON.T08BIT = 1;
 T0CON.T0CS = 0;
 T0CON.PSA = 0;
 T0CON |= 0b00000111;




 interrupt_setup();


 flag_timer_overflow = 0;
 timer_count = 0;
}


void interrupt_setup()
{

 INTCON.GIE = 1;
 INTCON.TMR0IE = 1;
 INTCON2.TMR0IP = 1;
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
