// Arduino: _14_HV_logger_2Ch
// VOLTAGE IN PIN Analog0
// CURRENT IN PIN Analog1
import processing.serial.*;
Serial USB;
String message = null;
int jmax = 100000; // Stored readings
int[] VminADC; // From 0 to jmax
int[] VmaxADC; // Raw values 
int[] IminADC;
int[] ImaxADC;
float[] Vmin; // From 0 to jmax
float[] Vmax; // in kV and uA
float[] Imin;
float[] Imax;
int j = 0; // Whole Register
int x = 0; // On Screen
int xpant = 1000; // Dimensions of the screen
int ypant = 800;
int mSup = 60; // Margin Sup and Inf of the trace
int mInf = 50;
int mLat = 50;
int xgraf = xpant - 2 * mLat;
int xDisplay = 30; // Beginning of the text
int yDisplay = 30;
float Cal0 = 1;
float Cal1 = 1;
float CalVEL =  300; // 
float CalPOS = 400; // 
PFont fontVerdana;
String [] com = new String [3];
void setup() {
  size(1000, 800, P3D);
  println(Serial.list());
  String portName = Serial.list()[0]; //    Puerto COM 14 
  USB = new Serial(this, portName, 115200);
  VminADC = new int [jmax];
  VmaxADC = new int [jmax];
  IminADC = new int [jmax];
  ImaxADC = new int [jmax];
  Vmin = new float [jmax];
  Vmax = new float [jmax];
  Imin = new float [jmax];
  Imax = new float [jmax];
  com = new String [3];
  fontVerdana = loadFont("Verdana-20.vlw");
}
void draw() {
  background(190);
  // New Data ***************************************************************************
  while (USB.available () > 0) {
    message = USB.readStringUntil(36); // 644,659,725,733$
    if (message != null) {    
      if (j < jmax - 2) {
        j++;
      } 
      else {
        j = 0;
      }
      message = message.substring(0, message.length()-1); // 644,659,725,733
      String[] com = splitTokens(message, ",");
      VminADC [j] = int(com[0])-200;   // Stored in VminADC[j] as ADC 
      VmaxADC [j] = int(com[1])-200;
      IminADC [j] = int(com[2]);
      ImaxADC [j] = int(com[3]);
      print(VminADC [j]);
      print("\t");
      print(VmaxADC [j]);
      print("\t");
      print(IminADC [j]);
      print("\t");
      println(ImaxADC [j]);
      Vmin [j] = VminADC [j] * Cal0;  // Stored in Vmin[j] as kV
      Vmax [j] = VmaxADC [j] * Cal0;
      Imin [j] = IminADC [j] * Cal1;
      Imax [j] = ImaxADC [j] * Cal1;
    }
  }

  //  Axis ********************************************************************************
  stroke(255);
  strokeWeight(2);
  line(mLat-10, ypant-mInf, xpant-mLat, ypant-mInf);
  line(mLat, ypant-mInf+10, mLat, mSup);
  // Reference Axis *************************************************************************************
  /*  fill(#FF1C20); // Red
   //  text("500uA", 10, (ypant-mInf)-500*(ypant-mSup-mInf)/660+4);
   stroke(#FF1C20, 20); // Red
   line(mLat, (ypant-mInf)-500*(ypant-mSup-mInf)/660, xpant-mLat, (ypant-mInf)-500*(ypant-mSup-mInf)/660);
   */
  fill(#321CFF); // Blue
  text("0", 30, mSup+(ypant-mInf-mSup)/2+4);
  stroke(#321CFF, 20); // Blue
  line(mLat, mSup+(ypant-mInf-mSup)/2, xpant-mLat, mSup+(ypant-mInf-mSup)/2);

  // Draw before 1st scroll ********************************************************************************************
  if (j <= xgraf) {
    for ( int i = 0; i < j; i ++) {
      strokeWeight(1);
      stroke(#FF1C20); // Red VELOCIDAD
      line(i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Imin[i]*(ypant-mInf-mSup)/CalVEL-2, i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Imax[i]*(ypant-mInf-mSup)/CalVEL+2);

      stroke(#321CFF); // Blue POSICIÓN
      line(i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Vmin[i]*(ypant-mInf-mSup)/CalPOS-2, i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Vmax[i]*(ypant-mInf-mSup)/CalPOS+2);
    }
  }
  // Draw with scroll **************************************************************************************************************
  if (j > xgraf) {
    for ( int i = 0; i <= xgraf; i ++) {
      strokeWeight(1);
      stroke(#FF1C20); // Red
      //      line(i+mLat, int((ypant-mInf)-Imin [j-xgraf+i]*(ypant-mSup-mInf)/660), i+mLat, int((ypant-mInf)-Imax [j-xgraf+i]*(ypant-mSup-mInf)/660));      
      line(i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Imin[j-xgraf+i]*(ypant-mInf-mSup)/CalVEL-2, i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Imax[j-xgraf+i]*(ypant-mInf-mSup)/CalVEL+2);
      stroke(#321CFF); // Blue
      // line(i+mLat, int((ypant-mInf)-Vmin [j-xgraf+i]*(ypant-mSup-mInf)/15), i+mLat, int((ypant-mInf)-Vmax [j-xgraf+i]*(ypant-mSup-mInf)/15));
      line(i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Vmin[j-xgraf+i]*(ypant-mInf-mSup)/CalPOS-2, i+mLat, int(mSup+(ypant-mInf-mSup)/2)-Vmax[j-xgraf+i]*(ypant-mInf-mSup)/CalPOS+2);
    }
  }
  // Text Channels Readings ***************************************************************
  stroke(190);
  fill(190); // Blue
  rect(30, 12, 330, 20);
  textFont(fontVerdana, 20);
  fill(#321CFF); // Blue
  text(int(Vmin[j]) +" mm", xDisplay, yDisplay);
  textFont(fontVerdana, 10);
  //  text("+/-" + nf((Vmax[j] - Vmin[j]), 0, 1) +" kV", xDisplay + 80, yDisplay);
  textFont(fontVerdana, 20);
  fill(#FF1C20); // Red
  text(int(Imax[j]) +" mm/s", xDisplay + 200, yDisplay);
  textFont(fontVerdana, 10);
  //  text("+/-" + int((Imax[j] - Imin[j])) +" uA", xDisplay + 200 + 80, yDisplay);
}
/*void keyPressed() {
 if (key == 's' || key =='S') {
 grabar();
 }
 if (key == 'v' || key =='V') {
 Cal0 = 9.0/((VminADC [j]+VmaxADC [j])/2); // 9 kV equals 489 ADC
 println("Calibración de Tensión: "+ Cal0);
 }
 if (key == 'i' || key =='I') {
 Cal1 = 660.0/((IminADC [j]+ImaxADC [j])/2);
 println("Calibración de Intensidad: "+ Cal1);
 }
 }
 */
void grabar() {
  String[] lines = new String[j];
  for (int i = 0; i < j; i++) {
    lines[i] = str(Vmin [i+1]) + "\t" + str(Vmax [i+1]) + "\t" + str(Imin [i+1]) + "\t" + str(Imax [i+1]); // Vmin  Vmax  Imin  Imax
  }
  saveStrings("Registro.txt", lines);
  exit();
}
