#include <SoftwareSerial.h>

// designed to simulate the BMS for testing the BMS Toucan
#define LED_STATUS 13
#define FIRST_BIT 0x81
#define SECOND_BIT 0xAA
#define RX_PIN 7
#define TX_PIN 6

char current_bit;



SoftwareSerial BMSToucan(RX_PIN, TX_PIN);

void setup()
{
  Serial.begin(19200);
  BMSToucan.begin(19200);
  current_bit = 1; // we are expecting bit 1
}


void loop()
{
  delay(1000); // wait a second for everything to sort itself out
  
  // handle incoming serial
  while(BMSToucan.available() > 0)
  {
    // the action depends on what bit we are expecting
    if(current_bit == 1)
    {
      if (BMSToucan.read() == FIRST_BIT)
      {
        current_bit++; // if we receive the first bit increment
                       // the bit and wait for the second bit
                       // otherwise we don't do anything
        Serial.print("FIRST ");              
      }
    }
    else if (current_bit == 2)
    {
      if (BMSToucan.read() == SECOND_BIT)
      {
        current_bit++; // if we receive the second bit, increment
                       // the bit and clear two more bits
        Serial.print("SECOND ");
      }
      else 
      {
        current_bit = 1; // otherwise this is an incorrect 
                         // sequence, go back to the start
        Serial.println("Resetting...");
      }
    }
    else if (current_bit == 3 || current_bit == 4)
    {
      current_bit++; // ignore the bit (its should be a
                     // cell #), so just move on
      BMSToucan.read(); // throw away a char
      Serial.print("# ");
      
      // check if we should break out of the loop and send the serial reply
      if (current_bit > 4) break;
    }
    if (current_bit > 4) 
    {
      // uh oh, we have received another bit before we had 
      // time to send out our data... error!
      //digitalWrite(LED_STATUS, HIGH); // show the error led
      current_bit = 1; // reset our current status, start again
      Serial.println(" resetting (overflow)...");
    }
  }
  
  // now check if we should be sending data back
  if (current_bit > 4)
  {
    digitalWrite(LED_STATUS, HIGH);
    // write a specific sequence of data (borrowed from Luis')
    char val = 0x00; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0xA2; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0xA1; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0xA1; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0x9B; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0x9B; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0x91; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0x91; BMSToucan.write(val);
    val = 0x02; BMSToucan.write(val);
    val = 0x04; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x04; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x74; BMSToucan.write(val);
    val = 0x74; BMSToucan.write(val);
    val = 0x81; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    val = 0x00; BMSToucan.write(val);
    
    Serial.println("replied to BMSToucan");
    
    // now reset to wait for the next message
    current_bit = 1;
    digitalWrite(LED_STATUS, LOW);
  }
}

