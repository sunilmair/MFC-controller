String receivedStr;

float flowInputFloat = 0;
String flowInputString;
float flowActualFloat = 0;
String flowActualString = flotoStr(flowActualFloat);
float valveTestPointFloat = 0;
String valveTestPointString = flotoStr(valveTestPointFloat);

//variables for the simulation of the MFC
int i = 0;
float difference;
float response = 0.25;

void setup() {
  Serial.begin(9600);
  
}

void loop() {
  if (Serial.available() > 0) {
    receivedStr = Serial.readStringUntil('\n');
    if (receivedStr.substring(0,1) == "3") {
      flowInputString = receivedStr.substring(1);
      flowInputFloat = Strtoflo(flowInputString);
    }
  }
  
  //In the following block:
  //set the flow input on the MFC
  //record the actual flow from the MFC (as a float)
  //record the valve test point from the MFC (as a float)
  difference = flowInputFloat - flowActualFloat;
  flowActualFloat += response*difference;
  valveTestPointFloat = 4*sin(i) + 4; i++;
  //
  
  flowActualString = flotoStr(flowActualFloat);
  valveTestPointString = flotoStr(valveTestPointFloat);
  flowInputString = flotoStr(flowInputFloat); //just to check if it went smoothly
  
  Serial.println("0" + flowActualString);
  Serial.println("1" + valveTestPointString);
  Serial.println("2" + flowInputString);
  
  delay(100);
}
String flotoStr(float f) {
  String mant;
  String whole;
  int third = (int)(f*1000) - 10*(int)(f*100);
  if (third < 5) {
    whole = (String)((int)(f));
    mant = (String)(((int)(f*100)) - 100*((int)(f)));
  } else {
    float newf = (1 + f*100)/100;
    whole = (String)((int)(newf));
    mant = (String)(((int)(newf*100)) - 100*((int)(newf)));
  }
  if (mant.length() == 1) {
    mant = "0" + mant;
  }
  String out = whole + "." + mant;
  return out;
}
 
float Strtoflo(String s) {
  char floatbuf[32];
  s.toCharArray(floatbuf, sizeof(floatbuf));
  float out = atof(floatbuf);
  return out;
}
