(*
  WATER-TANK PCS REFERENCE LOGIC
  Omron IEC 61131-3 Structured Text design reference.
  Educational code only. Adapt declarations, PID blocks, I/O mapping and
  diagnostics to the selected Omron platform before compilation.
*)
PROGRAM PRG_WaterTankPCS
VAR
    AutoMode, StartCmd, StopCmd, ResetCmd, ChangeoverCmd : BOOL;
    DutySelectB, HH_InletTrip, LL_PumpTrip : BOOL;
    LT_PV, LevelSP, LastGoodSpeed : REAL;
    P_A_Ready, P_B_Ready, P_A_RunFb, P_B_RunFb : BOOL;
    P_A_VFDFault, P_B_VFDFault, P_A_MotorOL, P_B_MotorOL : BOOL;
    P_A_Remote, P_B_Remote, P_A_EStopHealthy, P_B_EStopHealthy : BOOL;
    P_A_SpeedFb, P_B_SpeedFb, DischargeFlow : REAL;
    ActiveA, ActiveB, ChangeoverActive, RunRequest : BOOL;
    Alarm_LT_Bad, Alarm_High, Alarm_Low, Alarm_BothUnavailable : BOOL;
    PumpATrip, PumpBTrip, AutoStartBlocked : BOOL;
    InventoryReductionDemand, LCV_Cmd, ActiveSpeedSP : REAL;
    P_A_SpeedSP, P_B_SpeedSP : REAL;
    RampUp : REAL := 2.0;
    RampDown : REAL := 2.5;
END_VAR

(* 1. Validate the normal PCS level signal. Burnout is upscale. *)
Alarm_LT_Bad := (LT_PV < 0.0) OR (LT_PV > 105.0);
IF Alarm_LT_Bad THEN
    LT_PV := 110.0;
    AutoStartBlocked := TRUE;
ELSE
    AutoStartBlocked := FALSE;
END_IF;
Alarm_High := LT_PV >= 80.0;
Alarm_Low  := LT_PV <= 25.0;

(* 2. Consolidate pump availability and non-SIS equipment trips. *)
PumpATrip := P_A_VFDFault OR P_A_MotorOL OR NOT P_A_EStopHealthy;
PumpBTrip := P_B_VFDFault OR P_B_MotorOL OR NOT P_B_EStopHealthy;
P_A_Ready := P_A_Ready AND P_A_Remote AND NOT PumpATrip AND NOT LL_PumpTrip;
P_B_Ready := P_B_Ready AND P_B_Remote AND NOT PumpBTrip AND NOT LL_PumpTrip;
Alarm_BothUnavailable := NOT (P_A_Ready OR P_B_Ready);

(* 3. Select duty equipment. Pump selection remains a PCS function. *)
IF NOT ActiveA AND NOT ActiveB THEN
    ActiveB := DutySelectB AND P_B_Ready;
    ActiveA := NOT ActiveB AND P_A_Ready;
END_IF;
RunRequest := AutoMode AND StartCmd AND NOT StopCmd AND NOT LL_PumpTrip;

(* 4. Inventory-reduction controller.
   Output rises when level rises above setpoint. A production implementation
   should use the vendor PID function block with tracking and anti-windup. *)
InventoryReductionDemand := LIMIT(0.0, 50.0 + ((LT_PV - LevelSP) * 3.0), 100.0);

(* 5. Coordinated split range.
   Low demand: inlet open, discharge pump at minimum stable speed.
   High demand: inlet closes while discharge capacity increases. *)
IF InventoryReductionDemand <= 35.0 THEN
    LCV_Cmd := 100.0;
    ActiveSpeedSP := 30.0;
ELSIF InventoryReductionDemand <= 65.0 THEN
    LCV_Cmd := 100.0 - ((InventoryReductionDemand - 35.0) * 2.0);
    ActiveSpeedSP := 30.0 + ((InventoryReductionDemand - 35.0) * 0.666667);
ELSE
    LCV_Cmd := 40.0 - ((InventoryReductionDemand - 65.0) * 1.142857);
    ActiveSpeedSP := 50.0 + ((InventoryReductionDemand - 65.0) * 1.428571);
END_IF;
LCV_Cmd := LIMIT(0.0, LCV_Cmd, 100.0);
ActiveSpeedSP := LIMIT(30.0, ActiveSpeedSP, 100.0);

(* A bad PCS LT closes the inlet and blocks a new automatic pump start.
   A running pump holds its last tracked speed pending operator intervention;
   independent protection remains available from LT-201A/B/C. *)
IF Alarm_LT_Bad THEN
    LCV_Cmd := 0.0;
    ActiveSpeedSP := LIMIT(30.0, LastGoodSpeed, 100.0);
ELSE
    LastGoodSpeed := ActiveSpeedSP;
END_IF;

(* 6. Controlled duty/standby changeover. *)
IF ChangeoverCmd OR (ActiveA AND PumpATrip) OR (ActiveB AND PumpBTrip) THEN
    ChangeoverActive := TRUE;
END_IF;

IF ChangeoverActive THEN
    IF ActiveA AND P_B_Ready THEN
        P_B_SpeedSP := MIN(ActiveSpeedSP, P_B_SpeedSP + RampUp);
        IF P_B_RunFb AND P_B_SpeedFb >= ActiveSpeedSP - 2.0 THEN
            P_A_SpeedSP := MAX(0.0, P_A_SpeedSP - RampDown);
            IF P_A_SpeedSP <= 0.0 THEN
                ActiveA := FALSE; ActiveB := TRUE; ChangeoverActive := FALSE;
            END_IF;
        END_IF;
    ELSIF ActiveB AND P_A_Ready THEN
        P_A_SpeedSP := MIN(ActiveSpeedSP, P_A_SpeedSP + RampUp);
        IF P_A_RunFb AND P_A_SpeedFb >= ActiveSpeedSP - 2.0 THEN
            P_B_SpeedSP := MAX(0.0, P_B_SpeedSP - RampDown);
            IF P_B_SpeedSP <= 0.0 THEN
                ActiveB := FALSE; ActiveA := TRUE; ChangeoverActive := FALSE;
            END_IF;
        END_IF;
    ELSE
        ChangeoverActive := FALSE;
    END_IF;
ELSIF RunRequest AND NOT AutoStartBlocked THEN
    IF ActiveA THEN
        P_A_SpeedSP := MIN(ActiveSpeedSP, P_A_SpeedSP + RampUp);
        P_B_SpeedSP := MAX(0.0, P_B_SpeedSP - RampDown);
    ELSIF ActiveB THEN
        P_B_SpeedSP := MIN(ActiveSpeedSP, P_B_SpeedSP + RampUp);
        P_A_SpeedSP := MAX(0.0, P_A_SpeedSP - RampDown);
    END_IF;
ELSIF NOT RunRequest THEN
    P_A_SpeedSP := MAX(0.0, P_A_SpeedSP - RampDown);
    P_B_SpeedSP := MAX(0.0, P_B_SpeedSP - RampDown);
END_IF;

(* 7. Independent protection overrides.
   HH closes only the inlet. LL trips both discharge pumps. *)
IF HH_InletTrip THEN LCV_Cmd := 0.0; END_IF;
IF LL_PumpTrip THEN
    P_A_SpeedSP := 0.0;
    P_B_SpeedSP := 0.0;
END_IF;
END_PROGRAM
