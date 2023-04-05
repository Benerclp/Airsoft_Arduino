#include <Wire.h> 
#include <Keypad.h>
//#incluir <LiquidCrystal_I2C.h>
#include <LiquidCrystal.h>


LiquidCrystal lcd(7, 6, 5, 4, 3, 2);
const byte ROWS = 4;
const byte COLS = 4; 
char keys[ROWS][COLS] = {
  {'1','2','3','a'},
  {'4','5','6','b'},
  {'7','8','9','c'},
  {'*','0','#','d'}
};
//byte rowPins[ROWS] = {A4, A5, 13, 12}; 
//byte colPins[COLS] = {A0, A1, A2, A3}; 
byte rowPins[ROWS] = {A0, A1, A2, A3}; 
byte colPins[COLS] = {A4, A5, 13, 12}; 

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );


char enteredText[8];
char password[8];
int key=-1;
char lastKey;
char var;
boolean passwordEnable=false;


char BT_RIGHT = '4';
char BT_UP = 'a';
char BT_DOWN = 'b';
char BT_LEFT = '6';
char BT_SEL = 'd';   
char BT_CANCEL = 'c';
char BT_DEFUSER = 'x';   // not implemented

//leds

const int REDLED = 9;
const int GREENLED = 11;

boolean mosfetEnable = false;
const int mosfet = 9;
//IS VERY IMPORTANT THAT YOU TEST THIS TIME. BY DEFAULT IS IN 1 SEC. THAT IS NOT TOO MUCH. SO TEST IT!
const int MOSFET_TIME = 15000;

//TIME INTS
int GAMEHOURS = 0;
int GAMEMINUTES = 45;
int BOMBMINUTES = 4;
int ACTIVATESECONDS = 5;

boolean endGame = false;

boolean sdStatus = false; //search and destroy game enable used in config
boolean saStatus = false; //same but SAbotaghe
boolean doStatus = false; //for DEmolition
boolean start = true;
boolean defuseando;
boolean cancelando;
// SOUND TONES
boolean soundEnable = true;
int tonepin = 8; 
int tonoPitido = 3000;
int tonoAlarma1 = 700;
int tonoAlarma2 = 2600;
int tonoActivada = 1330;
int errorTone = 100;

unsigned long iTime;
unsigned long timeCalcVar;
unsigned long redTime;
unsigned long greenTime;
unsigned long iZoneTime;
byte team=0;

void setup(){
  lcd.begin(16, 2);
  Serial.begin(9600);
  //  lcd.init();                      
  //  lcd.backlight();
  lcd.setCursor(2,0);
  lcd.print(" K A J A K I");
  lcd.setCursor(1,1);
  lcd.print(" A I R S O F T");
  keypad.setHoldTime(50);
  keypad.setDebounceTime(50);
  keypad.addEventListener(keypadEvent);
  delay(3000); 
  pinMode(GREENLED, OUTPUT);     
  pinMode(REDLED, OUTPUT); 
  pinMode(mosfet, OUTPUT);  
  // 
  byte bar1[8] = {
    B10000,
    B10000,
    B10000,
    B10000,
    B10000,
    B10000,
    B10000,
    B10000,
  };
  byte bar2[8] = {
    B11000,
    B11000,
    B11000,
    B11000,
    B11000,
    B11000,
    B11000,
    B11000,
  };
  byte bar3[8] = {
    B11100,
    B11100,
    B11100,
    B11100,
    B11100,
    B11100,
    B11100,
    B11100,
  };
  byte bar4[8] = {
    B11110,
    B11110,
    B11110,
    B11110,
    B11110,
    B11110,
    B11110,
    B11110,
  };
  byte bar5[8] = {
    B11111,
    B11111,
    B11111,
    B11111,
    B11111,
    B11111,
    B11111,
    B11111,
  };
  byte up[8] = {
    B00000,
    B00100,
    B01110,
    B11111,
    B11111,
    B00000,
    B00000,
  };

  byte down[8] = {
    B00000,
    B00000,
    B11111,
    B11111,
    B01110,
    B00100,
    B00000,
  };
  lcd.createChar(0,bar1);
  lcd.createChar(1,bar2);
  lcd.createChar(2,bar3);
  lcd.createChar(3,bar4);
  lcd.createChar(4,bar5);
  lcd.createChar(5,up);
  lcd.createChar(6,down);
}

void loop(){
  menuPrincipal();
}
void keypadEvent(KeypadEvent key){
  switch (keypad.getState()){
    case PRESSED:
      switch (key){

      }
    break;
    case RELEASED:
      switch (key){
         case 'd': defuseando= false;
         Serial.println("d Releases");
         break;
         case 'c': cancelando=false;
         Serial.println("c Releases");
         break;
      }
    break;
    case HOLD:
      switch (key){
        case 'd': defuseando= true;
        Serial.println("d hold");
        break;
        case 'c': cancelando=true;
        Serial.println("c hold");
        break;
      }
    break;
  }
}

void disarmedSplash(){
  endGame = false;
  digitalWrite(REDLED, LOW); 
  digitalWrite(GREENLED, LOW);
  if(sdStatus || saStatus){
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("BOMBA DESARMADA");
    lcd.setCursor(0,1);
    lcd.print(" BUENOS GANAN");
    digitalWrite(GREENLED, LOW);  
    delay(5000);
    digitalWrite(GREENLED, HIGH); 
  }
  //end code
  lcd.clear();
  lcd.print("Jugar otra vez?");
  lcd.setCursor(0,1);
  lcd.print("A: SI    B: NO");
  digitalWrite(REDLED, HIGH);  
  digitalWrite(GREENLED, HIGH); 
  while(1)
  {
    var = keypad.waitForKey();
    if(var == 'a' ){
      tone(tonepin,2400,30);
      //
      if(sdStatus){
        startGameCount();
        search();
      }
      if(saStatus){
        saStatus=true;
        startGameCount();
        start=true; //
        sabotage();
      }
    }  
    if(var == 'b' ){
      tone(tonepin,2400,30);
      menuPrincipal();
      break;
    }  
  } 
}

void explodeSplash(){
  digitalWrite(REDLED, HIGH);  
  digitalWrite(GREENLED, HIGH); 
  cls();
  delay(100);
  endGame = false;
  lcd.setCursor(1,0);
  lcd.print("TERRORISTAS WIN");
  lcd.setCursor(0,1);
  lcd.print("  FIN DEL JUEGO");
  for(int i = 200; i>0; i--)// 
  {
    tone(tonepin,i);
    delay(20);
  }
  noTone(tonepin);
  if(mosfetEnable){
    activateMosfet(); 
  }
  delay(5000);
  cls();

  //end code
  lcd.print("Jugar otra vez?");
  lcd.setCursor(0,1);
  lcd.print("A: SI    B: NO");
  while(1)
  {
    var = keypad.waitForKey();
    if(var == 'a' ){
      tone(tonepin,2400,30);
      //
      if(sdStatus){
        startGameCount();
        search();
      }
      if(saStatus){
        saStatus=true;
        startGameCount();
        start=true; //
        sabotage();
      }
    }  
    if(var == 'b' ){
      tone(tonepin,2400,30);
      menuPrincipal();

      break;
    }  
  } 
}



void domination(){

  //SETUP INITIAL TIME 
  int minutos = GAMEMINUTES-1;
  boolean showGameTime=true;
  unsigned long a;
  unsigned long iTime=millis(); //  initialTime in millisec 
  unsigned long aTime;
  redTime=0;
  greenTime=0;

  int largoTono = 50;
// 0 = neutral, 1 = green team, 2 = red team
  a=millis();
  //Starting Game Code
  while(1)  // this is the important code, is a little messy but works good.
  {
    keypad.getKey();
    aTime=millis()- iTime;
    //Code for led blinking
    timeCalcVar=(millis()- iTime)%1000;
    if(timeCalcVar >= 0 && timeCalcVar <= 40)
    {
      if(team==1)digitalWrite(GREENLED, LOW);  
      if(team==2)digitalWrite(REDLED, LOW);  
    }
    if(timeCalcVar >= 50 && timeCalcVar <= 100)
    {    
      if(team==1)digitalWrite(GREENLED, HIGH);  
      if(team==2)digitalWrite(REDLED, HIGH);
    }
    // Sound!!! same as Destroy 
    if(timeCalcVar >= 0 && timeCalcVar <= 40 && soundEnable)tone(tonepin,tonoActivada,largoTono);

    if(timeCalcVar >= 245 && timeCalcVar <= 255 && minutos-aTime/60000<2 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if(timeCalcVar >= 495 && timeCalcVar <= 510 && minutos-aTime/60000<4 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if(timeCalcVar >= 745 && timeCalcVar <= 760 && minutos-aTime/60000<2 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    //Help to count 3 secs
    if(a+2000<millis()){
      a=millis();   
      showGameTime=!showGameTime;
      cls();
    }
    //THE NEXT TO METHODS SHOW "GAME TIME" AND "CONTROLED ZONE TIME" IT SHOWS 2 AND 2 SEC EACH

    if(showGameTime){ //THE SECOND IS /2
      lcd.setCursor(3,0);
      lcd.print("GAME TIME");
      lcd.setCursor(3,1);
      printTime(minutos, aTime);
    }
    else if (!showGameTime){

      lcd.setCursor(2,0);
      if(team == 0)lcd.print("NEUTRAL ZONE");
      if(team == 1)lcd.print(" GREEN ZONE");
      if(team == 2)lcd.print("  RED ZONE");

      if(team>0){
        lcd.setCursor(3,1);
        printTimeDom(millis()-iZoneTime,true);
      }
    }

    //###########################CHECKINGS##################

    //Check If Game End
    if(minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0)
    {
      gameOver();
    }

    //Check If IS neutral
    while((defuseando || cancelando) && team > 0)
    {
      cls();
      if(team>0)lcd.print("NEUTRALIZING...");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis(); //start disabling time
      while(defuseando || cancelando)
      {
         keypad.getKey();
        timeCalcVar = (millis()- xTime)%1000;

        if( timeCalcVar >= 0 && timeCalcVar <= 20)
        {
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 500)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(REDLED, HIGH);
        }

        unsigned long seconds= millis() - xTime;
        percent = (seconds)/(ACTIVATESECONDS*10);
        drawPorcent(percent);

        if(percent >= 100)
        {
          delay(1000);
          
          if(team==1){ 
            greenTime+=millis()-iZoneTime;
            iZoneTime=0; 

          }
          if(team==2){ 
            redTime+=millis()-iZoneTime;
            iZoneTime=0; 
          }
          team=0;
          break;
        }
      }
      cls();
    }

//Capturing red

    while(defuseando && team == 0 )
    {
      cls();
      if(team==0)lcd.print(" CAPTURING ZONE");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis(); //start disabling time
      while(defuseando)
      {
        keypad.getKey();
        timeCalcVar = (millis()- xTime)%1000;

        if( timeCalcVar >= 0 && timeCalcVar <= 20)
        {
          digitalWrite(REDLED, LOW);  
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 500)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(REDLED, HIGH);
        }

        unsigned long seconds= millis() - xTime;
        percent = (seconds)/(ACTIVATESECONDS*10);
        drawPorcent(percent);

        if(percent >= 100)
        {
          digitalWrite(GREENLED, HIGH);
          team=2;
          iZoneTime=millis();
          delay(1000);
          break;
        }
      }
      cls();
      digitalWrite(REDLED, HIGH);
    }

    //getting to green zone
    while(cancelando && team == 0 )
    {
      cls();
      if(team==0)lcd.print(" CAPTURING ZONE");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis(); //start disabling time
      while(cancelando)
      {
         keypad.getKey();
        timeCalcVar = (millis()- xTime)%1000;

        if( timeCalcVar >= 0 && timeCalcVar <= 20)
        {
          digitalWrite(GREENLED, LOW);  
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 500)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(GREENLED, HIGH);
        }

        unsigned long seconds= millis() - xTime;
        percent = (seconds)/(ACTIVATESECONDS*10);
        drawPorcent(percent);

        if(percent >= 100)
        {
          digitalWrite(GREENLED, HIGH);
          team=1;
          iZoneTime=millis();
          delay(1000);
          break;
        }
      }
      cls();
      digitalWrite(GREENLED, HIGH);  
    }
  }
}

void gameOver(){

  if(team==1)greenTime+=millis()-iZoneTime;
  if(team==2)redTime+=millis()-iZoneTime;
  
  while(!isPressed(BT_SEL)){
    lcd.clear();
    lcd.setCursor(3,0);
    lcd.print("TIME OVER!");
    lcd.setCursor(0,1);

    //check who team win the base
    if(greenTime>redTime){
      //greenteam wins
      lcd.print(" GREEN TEAM WIN ");
    }
    else{
      //redteam wins 
      lcd.print(" RED TEAM WIN ");
    }
    delay(3000);
    cls();
    lcd.print("Red Time:");
    lcd.setCursor(5,1);
    printTimeDom(redTime,false);
    delay(3000);
    cls();
    lcd.print("Green Time:");
    lcd.setCursor(5,1);
    printTimeDom(greenTime,false);
    delay(3000);
  }
  lcd.print("Play Again?");
  lcd.setCursor(0,1);
  lcd.print("A : Yes B : No");
  while(1)
  {
    var = keypad.waitForKey();
    if(var == 'a' ){
      tone(tonepin,2400,30);
      search();
      break;
    }  
    if(var == 'b' ){
      tone(tonepin,2400,30);
      menuPrincipal();
      break;
    }  
  } 
}





void search(){
  cls();
  digitalWrite(REDLED, HIGH); 
  digitalWrite(GREENLED, HIGH);   
  //SETUP INITIAL TIME 
  int minutos = GAMEMINUTES-1;
  unsigned long iTime=millis(); //  initialTime in millisec 
  unsigned long aTime;
  //var='o';

  //Starting Game Code
  while(1){  // this is the important code, is a little messy but works good.
    //Code for led blinking
    timeCalcVar=(millis()- iTime)%1000;
    if(timeCalcVar >= 0 && timeCalcVar <= 50)
    {
      digitalWrite(GREENLED, LOW);  
    }
    if(timeCalcVar >= 90 && timeCalcVar <= 130)
    {    
      digitalWrite(GREENLED, HIGH);  
    }

    lcd.setCursor(0,0);
    lcd.print("TIEMPO de JUEGO");
    aTime=millis()- iTime;
    lcd.setCursor(3,1);

    //PRINT TIME ON LCD

    printTime(minutos, aTime);

    //###########################CHECKINGS##################

    //Check If Game End
    if(minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0)
    {
      lcd.clear();
      while(1){
        lcd.print("FIN DEL TIEMPO!");
        lcd.setCursor(0,1);
        lcd.print("DEFENSORES WIN ");  

        digitalWrite(mosfet, HIGH);
        delay(300);
        digitalWrite(mosfet, LOW);
        delay(1000);
        digitalWrite(mosfet, HIGH);
        delay(300);
        digitalWrite(mosfet, LOW);
        delay(1000);
        digitalWrite(mosfet, HIGH);
        delay(300);
        digitalWrite(mosfet, LOW);
        delay(1000);
        digitalWrite(mosfet, HIGH);
        delay(200);
        digitalWrite(mosfet, LOW);
        delay(100);
        digitalWrite(mosfet, HIGH);
        delay(200);
        digitalWrite(mosfet, LOW);
        delay(100);


        for(int i = 1000; i>200; i--){
          if(soundEnable)tone(tonepin,i);
          delay(5);
        }
        noTone(tonepin);
        delay(5000);
        cls();
        menuPrincipal();
      }
    }
    //Serial.println(keypad.getKey());
    //USED IN PASSWORD GAME 
    if('d' == keypad.getKey() && passwordEnable){
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("ARMANDO BOMBA");
      delay(1000);//a little delay to think in the password
      lcd.clear();
      lcd.setCursor(3, 0);
      lcd.print("Enter Code");

      setCode();// we need to set the comparation variable first it writes on enteredText[]

      //then compare :D

      if(comparePassword()){
        destroy();
      }        
      lcd.clear();
      lcd.setCursor(3,0);
      lcd.print("Code Error!");
      if(soundEnable)tone(tonepin,errorTone,200);
      delay(500);
      cls();
    }
    //Check If Is Activating
    while(defuseando && !passwordEnable)
    {
      digitalWrite(GREENLED, HIGH);
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print(" ARMANDO BOMBA");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis(); //start disabling time
      while(defuseando)
      {
        keypad.getKey();
        timeCalcVar = (millis()- xTime)%1000;

        if( timeCalcVar >= 0 && timeCalcVar <= 40)
        {
          digitalWrite(REDLED, LOW);  
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 520)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(REDLED, LOW);
        }

        unsigned long seconds= millis() - xTime;
        percent = (seconds)/(ACTIVATESECONDS*10);
        drawPorcent(percent);

        if(percent >= 100)
        {
          digitalWrite(GREENLED, HIGH);
          destroy();// jump to the next gamemode
        }
      }
      cls();
      digitalWrite(REDLED, HIGH);  

    }
  }
}

void destroy(){
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(" BOMBA ARMADA");
  delay(1000);
  int minutos=BOMBMINUTES-1;
  unsigned long iTime=millis();
  unsigned long aTime;
  int largoTono = 50;

  //MAIN LOOP
  while(1){
    
    //If you fail disarm. 
    if(endGame){
      explodeSplash();
    }

    //Led Blink

    timeCalcVar=(millis()- iTime)%1000;
    if(timeCalcVar >= 0 && timeCalcVar <= 40)
    {
      digitalWrite(REDLED, LOW);  
      if(soundEnable)tone(tonepin,tonoActivada,largoTono);
    }
    if(timeCalcVar >= 180 && timeCalcVar <= 220){
      digitalWrite(REDLED, HIGH);  
    }
    //Sound 
    aTime= millis()- iTime;
    timeCalcVar=(millis()- iTime)%1000;
    if(timeCalcVar >= 245 && timeCalcVar <= 255 && minutos-aTime/60000<2 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if(timeCalcVar >= 495 && timeCalcVar <= 510 && minutos-aTime/60000<4 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if(timeCalcVar >= 745 && timeCalcVar <= 760 && minutos-aTime/60000<2 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if( minutos-aTime/60000==0 && 59-((aTime/1000)%60) < 10)largoTono = 300;

    lcd.setCursor(0,0);
    lcd.print(" DETONACION EN ");
    //Passed Time
   
    lcd.setCursor(3,1);

    ////////HERE ARE THE TWO OPTIONS THAT ENDS THE GAME///////////

    ////TIME PASED AWAY AND THE BOMB EXPLODES
    if(minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0)// Check if game ends
    {
      explodeSplash();
    }
    //print time

    printTime(minutos, aTime);

    //// SECOND OPTION: YOU PRESS DISARMING BUTTON  

    //IF IS A PASSWORD GAME 

    if('d' == keypad.getKey() && passwordEnable){

      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("DESARMANDO BOMBA");
      delay(1000);//a little delay to think in the password

      lcd.clear();
      lcd.setCursor(3,0);
      lcd.print("Enter Code");

      setCode();// we need to set the compare variable first

      //then compare :D

      if(comparePassword()){
        disarmedSplash();
      }        
      lcd.clear();
      lcd.setCursor(3,0);
      lcd.print("Code Error!");
      if(soundEnable)tone(tonepin,errorTone,200);
      delay(500);
      cls();
    }

    if(defuseando && !passwordEnable)// disarming bomb
    {
      lcd.clear();
      digitalWrite(REDLED, HIGH);  
      lcd.setCursor(0,0);
      lcd.print(" DESARMANDO ");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis();
      while(defuseando)
      {
        keypad.getKey();
        //check if game time runs out during the disabling
        aTime= millis()- iTime;
        if((minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0) || minutos-aTime/60000>4000000000){ 
          endGame = true;
        }
        timeCalcVar=(millis()- xTime)%1000;
        if(timeCalcVar>= 0 && timeCalcVar <= 20)
        {
          digitalWrite(GREENLED, LOW);  
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 500)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(GREENLED, HIGH);  
        }
        unsigned long seconds=(millis()- xTime);
        percent= seconds/(ACTIVATESECONDS*10);
        drawPorcent(percent);  

        //BOMB DISARMED GAME OVER
        if(percent >= 100)
        {
          disarmedSplash();   
        }
      }
      digitalWrite(REDLED, HIGH); 
      digitalWrite(GREENLED, HIGH);
      cls();
    }
  }
}






//Used to get keys, here you can configure how works the input without modify the other code





boolean isPressed(char key) 
{

  Serial.print("checkeando= ");
  Serial.print(key);
  
   Serial.print(" estado = ");
  Serial.print(keypad.getState());
  
     Serial.print(" estado = ");
  Serial.print(keypad.getKey());
  
  if(keypad.getKey() == key)
  {
    Serial.println(" TRUE");

    
    return true;
  }
  else if(keypad.getKey() == key && keypad.getState() == 2)
  {
    Serial.print(" Hold!!");
    Serial.println(key);
    
    return true;
  }
  Serial.println(" Falso");
  return false;
}



//This fuction compare enteredText[8] and password[8] variables
boolean comparePassword(){

  for(int i=0;i<8;i++){
    if(enteredText[i]!=password[i])return false;
  }
  return true;

}

//Set the password variable
void setCode(){

  lcd.setCursor(0, 1);
  for(int i=0;i<8;i++){
    while(1){
      var= getNumber();
      if(var !='x'){
        enteredText[i] = var;

        if (i != 0){
          lcd.setCursor(i-1,1);
          lcd.print("*");
          lcd.print(var);
        }
        else
        {
          lcd.print(var);
        }
        tone(tonepin,2400,30);
        break;
      }
    }
  }
}
void setPass(){
  lcd.setCursor(0, 1);

  for(int i=0;i<8;i++){ 
    while(1){
      var= getNumber();
      if(var !='x'){
        password[i] =  var;
        if (i != 0){
          lcd.setCursor(i-1,1);
          lcd.print("*");
          lcd.print(var);
        }
        else
        {
          lcd.print(var);
        }
        tone(tonepin,2400,30);
        break;
      }
    }  
  }
}


void setNewPass(){

  while(1){
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Enter New Pass");
    setPass();

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Retype Pass");

    setCode();

    if(comparePassword()){

      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Password Set OK!");
      delay(2000); 
      break; 
    }
    else {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("ERROR Dont Match!");
      if(soundEnable)tone(tonepin,errorTone,200);
      delay(2000); 

    }
  }

}
//Whait until a button is pressed is is a number return the number 'char' if not return x
char getNumber(){

  var = keypad.waitForKey();

  switch (var) {
  case 'a': 
    return 'x';
    break;
  case 'b': 
    return 'x';
    break;

  case 'c': 
    return 'x';
    break;
  case 'd': 
    return 'x';
    break;
  case '*': 
    return 'x';
    break;
  case '#': 
    return 'x';
    break;
  default:
    return var;
    break;
  }

}










//##################MENUS###############################

void menuPrincipal(){   //MAIN MENU

  digitalWrite(GREENLED, HIGH); 
 digitalWrite(REDLED, HIGH); 
  //Draw menu
  cls();//clear lcd and set cursor to 0,0
  int i=0;
  char* menu1[]={
    "Search&Destroy","Sabotage","Domination", "Bomb Setup"        }; // HERE YOU CAN ADD MORE ITEMS ON THE MAIN MENU
  lcd.print(menu1[i]);
  lcd.setCursor(15,1);
  checkArrows(i,2);
  while(1){

    var = keypad.waitForKey();
    if(var == BT_UP && i>0){
      tone(tonepin,2400,30);
      i--;
      cls();
      lcd.print(menu1[i]);
      checkArrows(i,3);
      delay(100);
    }
    if(var == BT_DOWN && i<3){
      tone(tonepin,2400,30);
      i++;
      cls(); 
      lcd.print(menu1[i]);    
      checkArrows(i,3);
      delay(100);

    }

    if(var == BT_SEL){
      tone(tonepin,2400,30);
      cls();
      switch (i){

      case 0:
        sdStatus=true;
        configQuickGame();
        startGameCount();
        search();
        break;
      case 1: 
        saStatus=true;
        configQuickGame();
        startGameCount();
        sabotage();
        break;
      case 2:
        doStatus=true;
        configQuickGame();
        startGameCount();
        domination();
        break;
      case 3:
        config();
        break;
        
       
      }
    }
  }
}

void config(){
  //Draw menu
  lcd.clear();
  lcd.setCursor(0, 0);
  int i=0;
  char* menu2[]={
    "Game Config","OFF Time TEST", "RELE Test 3 sec.","...vacio..."}; // HERE YOU CAN ADD MORE ITEMS ON THE MENU
  delay(500);
  lcd.print(menu2[i]);
  checkArrows(i,3);

  while(1){
    var=keypad.waitForKey();
    if(var == BT_UP && i>0){
      tone(tonepin,2400,30);
      i--;
      lcd.clear();  
      lcd.print(menu2[i]);
      checkArrows(i,3);
      delay(50);

    }
    if(var == BT_DOWN && i<3){
      tone(tonepin,2400,30);
      i++;
      lcd.clear();  
      lcd.print(menu2[i]);
      checkArrows(i,3);
      delay(50);
    }
    if(var == BT_CANCEL){
      tone(tonepin,2400,30);
      menuPrincipal();
    }
    if(var == BT_SEL){
      tone(tonepin,2400,30);
      lcd.clear();
      switch (i){

      case 0:
        //gameConfigMenu
        lcd.print("No config menu!");
        delay(2000);
        config();
        break;

      case 1:
        //final time test menu
        lcd.print("Final time sound");

        digitalWrite(mosfet, HIGH);
        delay(300);
        digitalWrite(mosfet, LOW);
        delay(1000);
        digitalWrite(mosfet, HIGH);
        delay(300);
        digitalWrite(mosfet, LOW);
        delay(1000);
        digitalWrite(mosfet, HIGH);
        delay(300);
        digitalWrite(mosfet, LOW);
        delay(1000);
        digitalWrite(mosfet, HIGH);
        delay(200);
        digitalWrite(mosfet, LOW);
        delay(100);
        digitalWrite(mosfet, HIGH);
        delay(200);
        digitalWrite(mosfet, LOW);
        delay(100);


        config();
        break;

      case 2:
      //test rele menu
        cls();
        lcd.print("RELE ON!");
        digitalWrite(mosfet, HIGH);   // turn the LED on (HIGH is the voltage level)
        delay(3000);   // wait for 3 second
        cls();
        lcd.print("RELE OFF!");
        digitalWrite(mosfet, LOW);
        delay(2000);
        config();
        break;        

      }
    }
  }
}

void configQuickGame(){

  cls();
  //GAME TIME
  if(sdStatus || doStatus || saStatus){
    lcd.print("Game Time:");
    lcd.setCursor(0,1);
    checkArrows(1,2);
    delay(400);

    while(1){


      lcd.setCursor(0,1);  
      lcd.print(GAMEMINUTES);  
      lcd.print("   Minutos");

      var = keypad.waitForKey();

      if(var == 'a' && GAMEMINUTES<180){
        tone(tonepin,2400,30);
        GAMEMINUTES++;
        delay(50);
      }
      if(var == 'b' && GAMEMINUTES>1){
        tone(tonepin,2400,30);
        GAMEMINUTES--;
        delay(50);
      }
      if(var == 'c') // Cancel or Back Button :')
      {
        tone(tonepin,2400,30);
        menuPrincipal();
      } 
      if(var == 'd') // Cancel or Back Button :')
      {
        tone(tonepin,2400,30);
        break;
      }        
    }
    tone(tonepin,2400,30);
    cls();
  }
  //BOMB TIME
  if(sdStatus || saStatus){
    lcd.print("Bomb Time:");
    lcd.setCursor(0,1);
    checkArrows(1,2);
    delay(400);

    while(1){
      lcd.setCursor(0,1);  
      lcd.print(BOMBMINUTES);  
      lcd.print(" Minutos");
      var = keypad.waitForKey();


      if(var == 'b' && BOMBMINUTES>1){
        tone(tonepin,2400,30);
        BOMBMINUTES--;
        delay(50);
      }
      if(var == 'a' && BOMBMINUTES<20){
        tone(tonepin,2400,30);
        BOMBMINUTES++;
        delay(50);
      }
      if(var == 'c') // Cancel or Back Button :')
      {
        tone(tonepin,2400,30);
        menuPrincipal();
      } 
      if(var == 'd') // Cancel or Back Button :')
      {
        tone(tonepin,2400,30);
        break;
      }          
    }
    tone(tonepin,2400,30);
  }
  cls();
  //ARMING TIME
  if(sdStatus || doStatus || saStatus){
    lcd.print("Arm time:");
    lcd.setCursor(0,1);
    checkArrows(1,2);
    delay(400);

    while(1){
      lcd.setCursor(0,1);  
      lcd.print(ACTIVATESECONDS);  
      lcd.print(" segundos");
      var = keypad.waitForKey();
      
      if(var == 'b' && ACTIVATESECONDS>5){
        tone(tonepin,2400,30);
        ACTIVATESECONDS--;
        delay(50);
      }   
      if(var == 'a' && ACTIVATESECONDS<30){
        ACTIVATESECONDS++;
        tone(tonepin,2400,30);
        delay(50);
      }
      if(var == 'c') // Cancel or Back Button :')
      {
        tone(tonepin,2400,30);
        menuPrincipal();
      } 
      if(var == 'd') // Cancel or Back Button :')
      {
        tone(tonepin,2400,30);
        break;
      }     
    }
    tone(tonepin,2400,30);
    ACTIVATESECONDS-=1; // Just a fix

  }
  //Want sound??
  if(sdStatus || saStatus || doStatus){
    cls();
  lcd.print("Activar sonido?");
  lcd.setCursor(0,1);
  lcd.print("A:  SI  B: NO");


    while(1)
    {
      var = keypad.waitForKey();
      if(var == 'a' ){
        soundEnable=true;
        tone(tonepin,2400,30);
        break;
      }  

      if(var == 'b' ){
        soundEnable=false;
        tone(tonepin,2400,30);
        break;
      }  
    }
  } 
  //Activate Mosfet at Terrorist game ends??? Boom!

  if(sdStatus || saStatus){
    cls();
    lcd.print("Activar RELE?");
    lcd.setCursor(0,1);
    lcd.print("A:  SI  B: NO");
    while(1)
    {
      var = keypad.waitForKey();
      if(var == 'a' ){
        mosfetEnable=true;
        tone(tonepin,2400,30);
        break;
      }  
      if(var == 'b' ){
        mosfetEnable=false;
        tone(tonepin,2400,30);
        break;
      }  
    } 
  }
  //You Want a password enable-disable game?
  if(sdStatus || saStatus){
    cls();
    lcd.print("Activar CODIDO?");
    lcd.setCursor(0,1);
    lcd.print("A:  SI  B: NO");

    while(1)
    {
      var = keypad.waitForKey();
      if(var == 'a' ){
        tone(tonepin,2400,30);
        setNewPass();
        passwordEnable = true;
        break;
      }  
      if(var == 'b' ){
        tone(tonepin,2400,30);
        passwordEnable = false;
        break;
      }  
    } 
    tone(tonepin,2400,30);
  }  
  //Continue the game :D
}







void sabotage(){
  cls();
  digitalWrite(REDLED, HIGH); 
  digitalWrite(GREENLED, HIGH);   
  //SETUP INITIAL TIME 
  int minutos = GAMEMINUTES-1;

  
  if(start){
  iTime=millis(); //  initialTime in millisec 
  start=false;
  }
  
  unsigned long aTime;

  //Starting Game Code
  while(1){  // this is the important code, is a little messy but works good.

    //Code for led blinking
    timeCalcVar=(millis()- iTime)%1000;
    if(timeCalcVar >= 0 && timeCalcVar <= 50)
    {
      digitalWrite(GREENLED, LOW);  
    }
    if(timeCalcVar >= 90 && timeCalcVar <= 130)
    {    
      digitalWrite(GREENLED, HIGH);  
    }

    lcd.setCursor(3,0);
    lcd.print("GAME TIME");
    aTime=millis()- iTime;
    lcd.setCursor(3,1);

    //PRINT TIME ON LCD

    printTime(minutos, aTime);

    //###########################CHECKINGS##################

    //Check If Game End
    if(minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0)
    {
      lcd.clear();
      while(1){
        lcd.print(" GAME OVER! ");
        lcd.setCursor(0,1);
        lcd.print(" DEFENDERS WIN ");  

        for(int i = 1000; i>200; i--){
          if(soundEnable)tone(tonepin,i);
          delay(5);
        }
        noTone(tonepin);
        delay(5000);
        cls();
        menuPrincipal();
      }
    }
    //USED IN PASSWORD GAME 
    if('d' == keypad.getKey() && passwordEnable){
      lcd.clear();
      lcd.setCursor(2,0);      
      lcd.print("ARMING BOMB");
      delay(1000);//a little delay to think in the password
      lcd.clear();
      lcd.setCursor(3, 0);
      lcd.print("Enter Code");

      setCode();// we need to set the compare variable first

      //then compare :D

      if(comparePassword()){
        destroySabotage();
      }        
      lcd.clear();
      lcd.setCursor(2,0);
      lcd.print("Code Error!");
      if(soundEnable)tone(tonepin,errorTone,200);
      delay(500);
      cls();
    }

    //Check If Is Activating
    while(defuseando && !passwordEnable)
    {
      keypad.getKey();
      cls();
      digitalWrite(GREENLED, HIGH);
      lcd.clear();
      lcd.setCursor(2,0);
      lcd.print("ARMING BOMB");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis(); //start disabling time
      while(defuseando)
      {
        keypad.getKey();
        timeCalcVar = (millis()- xTime)%1000;

        if( timeCalcVar >= 0 && timeCalcVar <= 40)
        {
          digitalWrite(REDLED, LOW);  
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 520)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(REDLED, HIGH);
        }
        unsigned long seconds= millis() - xTime;
        percent = (seconds)/(ACTIVATESECONDS*10);
        drawPorcent(percent);

        if(percent >= 100)
        {
          digitalWrite(GREENLED, HIGH);
          destroySabotage();// jump to the next gamemode
        }
      }
      cls();
      digitalWrite(REDLED, HIGH);  
    }
  }
}

void destroySabotage(){
  lcd.clear();
  lcd.setCursor(3,0);
  lcd.print("BOMB ARMED");
  delay(1000);
  int minutos=BOMBMINUTES-1;
  unsigned long iTime=millis();
  unsigned long aTime;
  int largoTono = 50;

  //MAIN LOOP
  while(1){

    //If you fail disarm. 
    if(endGame){
      explodeSplash();
    }

    //Led Blink

    timeCalcVar=(millis()- iTime)%1000;
    if(timeCalcVar >= 0 && timeCalcVar <= 40)
    {
      digitalWrite(REDLED, LOW);  
      if(soundEnable)tone(tonepin,tonoActivada,largoTono);
    }
    if(timeCalcVar >= 180 && timeCalcVar <= 220){
      digitalWrite(REDLED, HIGH);  
    }
    //Sound 

    timeCalcVar=(millis()- iTime)%1000;
    aTime= millis()- iTime;
    if(timeCalcVar >= 245 && timeCalcVar <= 255 && minutos-aTime/60000<2 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if(timeCalcVar >= 495 && timeCalcVar <= 510 && minutos-aTime/60000<4 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if(timeCalcVar >= 745 && timeCalcVar <= 760 && minutos-aTime/60000<2 && soundEnable)tone(tonepin,tonoActivada,largoTono);
    if( minutos-aTime/60000==0 && 59-((aTime/1000)%60) < 10)largoTono = 300;

    lcd.setCursor(1,0);
    lcd.print("DETONATION IN");
    //Passed Time
    
    lcd.setCursor(3,1);

    ////////HERE ARE THE TWO OPTIONS THAT ENDS THE GAME///////////

    ////TIME PASED AWAY AND THE BOMB EXPLODES
    if(minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0)// Check if game ends
    {
      explodeSplash();
    }
    //print time
    printTime(minutos, aTime);

    //// SECOND OPTION: YOU PRESS DISARMING BUTTON  

    //IF IS A PASSWORD GAME 

    if('d' == keypad.getKey() && passwordEnable){

      cls();
      digitalWrite(REDLED, HIGH);  
      digitalWrite(GREENLED, LOW); 
      lcd.print(" DISARMING BOMB");
      delay(1000);//a little delay to think in the password

      lcd.clear();
      lcd.setCursor(3,0);
      lcd.print("Enter Code");

      setCode();// we need to set the compare variable first

      //then compare :D

      if(comparePassword()){
        sabotage();
      }        
      lcd.clear();
      lcd.setCursor(2,0);
      lcd.print("Code Error!");
      if(soundEnable)tone(tonepin,errorTone,200);
      delay(500);
      cls();
    }

    if(defuseando && !passwordEnable)// disarming bomb
    {
      lcd.clear();
      digitalWrite(REDLED, HIGH);
      lcd.setCursor(3,0);
      lcd.print("DISARMING");
      lcd.setCursor(0,1);
      unsigned int percent=0;
      unsigned long xTime=millis();
      while(defuseando)
      {
        keypad.getKey();
        //check if game time runs out during the disabling
        aTime= millis()- iTime;
        if((minutos-aTime/60000==0 && 59-((aTime/1000)%60)==0) || minutos-aTime/60000>4000000000){ 
          endGame = true;
        }
        timeCalcVar=(millis()- xTime)%1000;
        if(timeCalcVar>= 0 && timeCalcVar <= 20)
        {
          digitalWrite(GREENLED, LOW);  
          if(soundEnable)tone(tonepin,tonoAlarma1,200);
        }
        if(timeCalcVar >= 480 && timeCalcVar <= 500)
        {
          if(soundEnable)tone(tonepin,tonoAlarma2,200);
          digitalWrite(GREENLED, HIGH);  
        }
        unsigned long seconds=(millis()- xTime);
        percent= seconds/(ACTIVATESECONDS*10);
        drawPorcent(percent);  

        //BOMB DISARMED GAME OVER
        if(percent >= 100)
        {
          sabotage();   
        }
      }
      digitalWrite(REDLED, HIGH); 
      digitalWrite(GREENLED, HIGH);
      cls(); 
    }
  }
}
  
  
  
  
 
 
 
  
  
  
  
  


void drawPorcent(byte porcent){
  //TODO: Optimize this code 
  byte i=1;
  int aDibujar=(8*porcent)/10;
  lcd.setCursor(0,1);

  if(aDibujar<5)
  {
    switch(aDibujar){
    case 0:
      break;
    case 1:
      lcd.write((uint8_t)0);
      break;
    case 2:
      lcd.write(1);
      break;
    case 3:
      lcd.write(2);
      break;
    case 4:
      lcd.write(3);
      break;
    }
  }
  while(aDibujar>=5){
    if(aDibujar>=5)
    {
      lcd.write(4);
      aDibujar-=5;
    }
    if(aDibujar<5)
    {
      switch(aDibujar){
      case 0:
        break;
      case 1:
        lcd.write((uint8_t)0);
        break;
      case 2:
        lcd.write(1);
        break;
      case 3:
        lcd.write(2);
        break;
      case 4:
        lcd.write(3);
        break;
      }
    }
  }
}
void cls(){
  lcd.clear();
  lcd.setCursor(0,0);
}

void printTime(unsigned long minutos, unsigned long aTiempo){
  //minutes
  if((minutos-aTiempo/60000)<10)
  {
    lcd.print("0");
    lcd.print(minutos-aTiempo/60000);
  }
  else
  {
    lcd.print(minutos-aTiempo/60000);
  }
  lcd.print(":");
  //seconds
  if((59-((aTiempo/1000)%60))<10)
  {
    lcd.print("0");
    lcd.print(59-((aTiempo/1000)%60));
  }
  else
  {
    lcd.print(59-((aTiempo/1000)%60));
  }
  lcd.print(":");
  //this not mach with real time, is just a effect, it says 999 because millis%1000 sometimes give 0 LOL
  lcd.print(999-(millis()%1000));
}

void printTimeDom(unsigned long aTiempo, boolean showMillis){
  //minutes
  if((aTiempo/60000)<10)
  {
    lcd.print("0");
    lcd.print(aTiempo/60000);
  }
  else
  {
    lcd.print(aTiempo/60000);
  }
  lcd.print(":");
  //seconds
  if(((aTiempo/1000)%60)<10)
  {
    lcd.print("0");
    lcd.print((aTiempo/1000)%60);
  }
  else
  {
    lcd.print((aTiempo/1000)%60);
  }
  if(showMillis){
    lcd.print(":");
    //this not mach with real time, is just a effect, it says 999 because millis%1000 sometimes give 0 LOL
      lcd.print(999-millis()%1000);

  }
}


void startGameCount(){
  cls();
  lcd.setCursor(1,0);
  lcd.print("Ready to Begin");
  lcd.setCursor(0,1);
  lcd.print(".Pulsa un Boton.");
  keypad.waitForKey();//if you press a button game start

  cls();
  lcd.setCursor(1,0);
  lcd.print("Starting Game");
  for(int i = 5; i > 0 ; i--){ // START COUNT GAME INIT
    lcd.setCursor(5,1);
    tone(tonepin,2000,100);
    lcd.print("IN ");
    lcd.print(i);
    delay(1000);
  }
  cls();
}

void checkArrows(byte i,byte maxx ){

  if(i==0){
    lcd.setCursor(15,1);
    lcd.write(6); 
  }
  if(i==maxx){  
    lcd.setCursor(15,0);
    lcd.write(5);
  }
  if(i>0 && i<maxx){
    lcd.setCursor(15,1);
    lcd.write(6);
    lcd.setCursor(15,0);
    lcd.write(5);  
  }
}

void activateMosfet(){

  //lcd.print("Mosfet ON!");
  digitalWrite(mosfet, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(MOSFET_TIME);   // wait for 4 second
  //lcd.print("Mosfet OFF!");
  digitalWrite(mosfet, LOW);

}




