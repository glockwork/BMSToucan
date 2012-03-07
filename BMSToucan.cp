#line 1 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
#line 9 "C:/Users/mecharius/Dropbox/Projects/HXN-5 BMStoCAN/Code/BMSToucan.c"
void main() {

}




void setup()
{

 TRISA = 0;
 TRISB = 0;
 TRISC = 0;





 RCSTA.SPEN = 1;
 RCSTA.RX9 = 0;
 TXSTA.SYNC = 0;
 TRISC.B7 = 1;


 TXSTA.BRGH = 1;
 SPBRG = 64;


 TRISB.B3 = 1;
 TRISB.B2 = 0;
}





void ISR() ix0008h
{

}
