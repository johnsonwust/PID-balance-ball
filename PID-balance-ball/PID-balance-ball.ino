#include <Servo.h>
//#include <Wire.h>
//#include "IICLiquidCrystal.h"

// Connect via i2c, default address #0 (A0-A2 not jumpered)
//LiquidCrystal lcd(0);

float Kp = 3;   //2
float Kd = 1;  //35
float Ki = 0.5; //0.1
int Rint = 8;   //
int Rext = 40;  //
int aim = 0;
unsigned long time = 0; //execution time of the last cycle
unsigned long timeSerial = 0;
int period = 50;        //Sampling period in ms
int sensorPin = 0;        //Analog Pin where the Distance Sensor signal is connected
int measure;            //What the sensor measures. They are ADCs.
int dcal [] = {         //Remote ADC calibration
  -193, -160, -110, -60, 0, 40, 60, 90, 120
};
int ADCcal [] = {
  177, 189, 231, 273, 372, 483, 558, 742, 970
};
int lastDist;     //Previous value of Distance to calculate Speed
int dist;         //distance in mm with 0 in the center of the bar
int nvel = 5;       //number of velocity values over which we calculate the average
int v[5];
int vel;          //mean value of the last speed levels
float I;          //Integral Value


Servo myservo;    //create servo object to control a servo
float pos;
float reposo = 1350; //value held by horizontal bar

int ledPin = 13; //Green led pin.

void setup()
{
  analogReference(EXTERNAL);  //AREF connected to 3.3V
  myservo.attach(3);         //attaches the servo on pin X to the servo object
  Serial.begin(115200);
  pinMode(ledPin, OUTPUT);

  myservo.writeMicroseconds(reposo);
  delay(5000);

  //lcd.begin(16, 2);

}

void loop()
{
  if (millis() > timeSerial + 200)
  {
    timeSerial = millis();
//    Kp = map(analogRead(A1), 0, 1023, 0, 5000) / 100.0;
//    Kd = map(analogRead(A2), 0, 1023, 0, 400) / 100.0;
//    Ki = map(analogRead(A3), 0, 1023, 0, 300) / 100.0;

    //aim = map(analogRead(A5), 0, 1023, -20, 20);

    Serial.println();
    Serial.print("Kp:");
    Serial.println(Kp);

    Serial.print("Kd:");
    Serial.println(Kd);

    Serial.print("Ki:");
    Serial.println(Ki);

    Serial.print("Aim:");
    Serial.println(aim);

    Serial.print("Pos:");
    Serial.println(dist);
  }

  
  if (millis() > time + period) { //
    time = millis();

    //    lcd.setCursor(0, 0);
    //    lcd.print("Kp:");
    //    lcd.print(Kp);
    //
    //    lcd.setCursor(8, 0);
    //    lcd.print("Kd:");
    //    lcd.print(Kd);
    //
    //    lcd.setCursor(0, 1);
    //    lcd.print("Ki:");
    //    lcd.print(Ki);
    //
    //    lcd.setCursor(8, 1);
    //    lcd.print("Pos:");
    //    lcd.print(dist);






    //We measure DISTANCE
    measure = analogRead(sensorPin);
    measure = constrain(measure, ADCcal[0], ADCcal[8]);
    lastDist = dist; //We save the previous value of dist to calculate the speed
    for (int i = 0; i < 8; i++) { //We apply Calibration curve from ADC to mm
      if (measure >= ADCcal[i] && measure < ADCcal[i + 1]) {
        dist = map(measure, ADCcal[i], ADCcal[i + 1], dcal[i], dcal[i + 1]);
      }
    }
    //Average SPEED calculation
    for (int i = 0; i < nvel - 1; i++) { //We all move to the left to free the last one.
      v[i] = v[i + 1];
    }
    v[nvel - 1] = (dist - lastDist); //We put a new data
    vel = 0;
    for (int i = 0; i < nvel; i++) { //We calculate the mean
      vel = vel + v[i];
    }
    vel = vel / nvel;
    // Integral
    if (abs(dist - aim) > Rint && abs(dist - aim) < Rext) { //Only if it is inside (-Rext, Rext) and outside (-Rint, Rint)
      I = I + dist * Ki;
    }
    else {
      I = 0;
    }
    //We calculate servo position
    pos = Kp * (dist - aim) + Kd * vel + I;
    myservo.writeMicroseconds(reposo + pos);

    if (abs(dist) < Rint) { //If we are inside Rint turn on Led
      digitalWrite(ledPin, HIGH);
    }
    else {
      digitalWrite(ledPin, LOW);
    }

    if (1) { //Shipping for PROCESSING
      Serial.print(dist + 200);
      Serial.print(",");
      Serial.print(dist + 200);
      Serial.print(",");
      Serial.print(vel);
      Serial.print(",");
      Serial.print(vel);
      Serial.print("$");
    }
    if (0) { //Debug
      Serial.print(millis());
      Serial.print(" ms|dist: ");
      Serial.print(dist);
      Serial.print("|vel: ");
      Serial.print(vel);
      Serial.print("|Kp*dist: ");
      Serial.print(Kp * dist);
      Serial.print("|Kd*vel: ");
      Serial.print(Kd * vel);
      Serial.print("|Int: ");
      Serial.print(I);
      Serial.print("|pos: ");
      Serial.println(pos);
    }
    if (0) { //To calibrate Distance sensor
      Serial.print(dist);
      Serial.print("mm     ADC: ");
      Serial.println(measure);
    }
    if (0) { //DeBug Speeds
      for (int i = 0; i < (nvel); i++) {
        Serial.print(v[i]);
        Serial.print(",");
      }
      Serial.print("       vel:");
      Serial.println(vel);
    }
  }
}
