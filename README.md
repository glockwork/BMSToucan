#Oxford Brookes Racing
##Isis 11e BMS Telemetry Convertor

Oxford Brookes Racing (OBR) run an electric racing vehicle as part of the Formula Student competition organised by IMechE.  The Isis 11e is OBR's electric powered vehicle.  There was a need to view live telemetry data from the batteries to monitor cell voltages in realtime.  This would enable voltage issues to be proactively managed improving safety and vehicle performance.

The solution was the *BMS Toucan* (BMS To Can) - a small PIC18F258 device which connects to the BMS system via serial, and also connects to the Isis 11e on board CANOpen Network.  The BMS Toucan periodically polls the BMS for battery cell information via an RS-232 port, and then translates this information into a CAN message which is transmitted on the CANOpen network, and then sent via radio link to a PC based telemetry system
