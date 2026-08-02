/*
  ESP32-S3 EDUCATIONAL PROTECTION DEMONSTRATOR
  NOT A CERTIFIED SAFETY PLC. NOT FOR OPERATIONAL SIL SERVICE.

  Demonstrates three independent level inputs, diagnostics, separate 2oo3
  high-high and low-low votes, latched protective actions and manual reset.
*/
#include <Arduino.h>

const int LT_A_PIN=1, LT_B_PIN=2, LT_C_PIN=3;
const int INLET_PERMIT_PIN=10, PUMP_PERMIT_PIN=11;
const int RESET_PIN=13;
const float HH_SP=90.0f, HH_RESET=85.0f;
const float LL_SP=15.0f, LL_RESET=20.0f;
const float DISAGREE=5.0f;

bool hhLatch=true;       // power-up conservative state
bool llLatch=true;
uint32_t lastScan=0;

float readPct(int pin){
  int raw=analogRead(pin);
  return constrain((raw/4095.0f)*100.0f,0.0f,100.0f);
}
bool valid(float pv){ return pv>=0.5f && pv<=99.5f; }

void setOutputs(){
  // HIGH energizes a healthy permit; LOW is trip or loss-of-power state.
  digitalWrite(INLET_PERMIT_PIN, hhLatch ? LOW : HIGH);
  digitalWrite(PUMP_PERMIT_PIN,  llLatch ? LOW : HIGH);
}

void setup(){
  Serial.begin(115200);
  pinMode(INLET_PERMIT_PIN,OUTPUT);
  pinMode(PUMP_PERMIT_PIN,OUTPUT);
  pinMode(RESET_PIN,INPUT_PULLUP);
  setOutputs();
}

void loop(){
  if(millis()-lastScan<100) return;
  lastScan=millis();

  float pv[3]={readPct(LT_A_PIN),readPct(LT_B_PIN),readPct(LT_C_PIN)};
  bool bad[3]={!valid(pv[0]),!valid(pv[1]),!valid(pv[2])};
  int hhVotes=0, llVotes=0, badCount=0;
  for(int i=0;i<3;i++){
    if(bad[i]){ badCount++; continue; }
    if(pv[i]>=HH_SP) hhVotes++;
    if(pv[i]<=LL_SP) llVotes++;
  }

  bool disagreement=(max(pv[0],max(pv[1],pv[2]))-
                     min(pv[0],min(pv[1],pv[2])))>DISAGREE;
  bool votingUnavailable=badCount>=2;

  if(hhVotes>=2) hhLatch=true;
  if(llVotes>=2) llLatch=true;

  bool allValid=badCount==0;
  bool resetPressed=digitalRead(RESET_PIN)==LOW;
  bool hhSafe=pv[0]<HH_RESET && pv[1]<HH_RESET && pv[2]<HH_RESET;
  bool llSafe=pv[0]>LL_RESET && pv[1]>LL_RESET && pv[2]>LL_RESET;
  if(resetPressed && allValid && !votingUnavailable){
    if(hhSafe && hhVotes<2) hhLatch=false;
    if(llSafe && llVotes<2) llLatch=false;
  }

  setOutputs();
  Serial.printf("LT %.1f %.1f %.1f | HH=%d LL=%d bad=%d disagree=%d inletTrip=%d pumpTrip=%d\n",
                pv[0],pv[1],pv[2],hhVotes,llVotes,badCount,disagreement,hhLatch,llLatch);
}
