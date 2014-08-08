import processing.serial.*;
import controlP5.*;


//window sizes
int winSizeX = 800;
int winSizeY = 800;

int indentX = 20;

//element positions
int flowSetY = 20;
int flowSetXsize = 75;
int flowSetYsize = 40;
int flowActualY = 110;
int valveTestPointY = 200;

//graph positions
float graphTopLeftX = 175;
float graphTopLeftY = 20;
float graphBottomRightX = winSizeX - 70;
float graphBottomRightY = winSizeY - 70;
float graphBorder = 2;

float graphX = graphTopLeftX + graphBorder;
float graphYActual = graphBottomRightY - graphBorder;
float graphYSet = graphYActual;


//Declaring some stuff
Serial myPort;
ControlP5 cp5;

//Declaring more, less important, stuff
String flowActualString = "0";
float flowActualFloat = 0;
String flowActualStringDelay = "0";
String valveTestPointString = "0";
String valveTestPointStringDelay = "0";
String flowSetInputString = "30\n";
String flowSetInputStringFromArd = "0";
float flowSetInputFloatFromArd = 0;

//time between value updates (in ms)
float time;
float timeInt = 1000;

void setup() {
  
  //setting up port connection and implementing CP5 package
  myPort = new Serial(this, "/dev/ttyACM0", 9600);
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 20);
  
  //create window, black background
  size(winSizeX, winSizeY);
  background(0);
  
  //set flow input element
  cp5.addTextfield("SET FLOW")
     .setPosition(indentX, flowSetY)
     .setSize(flowSetXsize, flowSetYsize)
     .setFont(createFont("arial", 20))
     .setAutoClear(false)
     ;
     
  //create input button
  cp5.addBang("enterFlowSet")
     .setPosition(indentX + flowSetXsize + 10, flowSetY)
     .setSize(flowSetYsize, flowSetYsize)
     //.setTriggerEvent(Bang.RELEASE)
     .setLabel("Enter")
     ;
  
  //set labels for Actual Flow and Valve Test Point
  Textlabel flowActualLabel = cp5.addTextlabel("Flow Actual")
                                 .setText("ACTUAL FLOW")
                                 .setPosition(indentX - 2, flowActualY + 10)
                                 ;
  
  Textlabel valveTestPointLabel = cp5.addTextlabel("Valve Test Point")
                                     .setText("VALVE TEST POINT")
                                     .setPosition(indentX - 2, valveTestPointY + 10)
                                     ;
time = 0;
rectMode(CORNERS);
stroke(0);
fill(255);
rect(graphTopLeftX, graphTopLeftY, graphBottomRightX, graphBottomRightY);
fill(0);
rect(graphTopLeftX + graphBorder, graphTopLeftY + graphBorder, graphBottomRightX - graphBorder, graphBottomRightY - graphBorder);
}

void draw() {
  //change this to only write over appropriate parts
  stroke(0);
  fill(0);
  rect(0, 0, graphTopLeftX, winSizeY);
  
  //recieve Actual Flow and Valve Test Point values from controller
  if (myPort.available() > 0) {
    String received = myPort.readStringUntil('\n');
    if (received != null) {
      println("gotit");
      switch (int(received.substring(0,1))) {
        case 0: flowActualString = received.substring(1); break;
        case 1: valveTestPointString = received.substring(1); break;
        case 2: flowSetInputStringFromArd = received.substring(1); break;
      }
      //println(received.substring(1));
    }
  }
  
  //display the delayed values of the Actual Flow and Valve Test Point
  fill(255);
  textFont(createFont("arial", 20)); //not sure if this is necessary //it is
  text(flowActualStringDelay, indentX, flowActualY);
  text(valveTestPointStringDelay, indentX, valveTestPointY);
  
  //update Actual Flow and Valve Test Point every some appropriate time period
  if (millis() > time + timeInt) {    
    flowActualStringDelay = flowActualString;
    valveTestPointStringDelay = valveTestPointString;
    time = millis();
  }
  
  //Draw graph
  flowActualFloat = float(flowActualString);
  flowSetInputFloatFromArd = float(flowSetInputStringFromArd);
  
  graphYActual = map(flowActualFloat, 0, 10, graphBottomRightY - graphBorder, graphTopLeftY + graphBorder);
  graphYSet = map(flowSetInputFloatFromArd, 0, 10, graphBottomRightY - graphBorder, graphTopLeftY + graphBorder);
  
  stroke(0);
  rect(graphX + 1, graphTopLeftY + graphBorder, graphX, graphBottomRightY - graphBorder);
  
  stroke(255);
  point(graphX, graphYActual);
  stroke(100);
  point(graphX, graphYSet);
  
  if (graphX >= graphBottomRightX - graphBorder - 1) {
    graphX = graphTopLeftX + graphBorder;
  } else {
    graphX++;
  }
}

//button updates Set Flow and sends to controller
public void enterFlowSet() {
  flowSetInputString = cp5.get(Textfield.class,"SET FLOW").getText();
  myPort.write("3" + flowSetInputString + "\n");
 //println("clickedit");
} 

void keyPressed() {
  if ((key == ENTER) && (cp5.get(Textfield.class,"SET FLOW").getText() != null)) {
    flowSetInputString = cp5.get(Textfield.class,"SET FLOW").getText();
    myPort.write("3" + flowSetInputString + "\n");
 //println("clickedit");
  }
}

