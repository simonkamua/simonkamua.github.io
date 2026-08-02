# Control Philosophy - Water-Tank PCS and SIS Control System

## Process and control objective

A reservoir feeds TK-101 through fail-close LCV-101. Two VFD pumps, P-101A and P-101B, discharge the tank in duty/standby service. The Omron PCS maintains level using an inventory-reduction controller whose split-range outputs progressively close the inlet valve and increase discharge-pump speed as level rises. A separate ESP32-S3 educational demonstrator receives LT-201A/B/C and applies independent 2oo3 votes: high-high closes and inhibits the inlet; low-low trips and inhibits both discharge pumps.

## Operating modes

- **Stopped:** Pumps stopped; inlet closed unless an authorized fill mode is active; monitoring and protection remain active.
- **Manual:** Authorized output proving with equipment interlocks and independent protection overrides retained.
- **Automatic:** LIC-101 regulates tank inventory while the PCS manages the selected duty pump and standby availability.
- **Changeover:** The incoming pump starts and ramps to tracked demand before the outgoing pump ramps down and stops.
- **High-high trip:** The protection layer closes and inhibits LCV-101; an eligible discharge pump remains available.
- **Low-low trip:** The protection layer trips and inhibits both discharge pumps until level recovery and manual reset.
- **Degraded:** A bad or disagreeing channel is annunciated; reset is blocked until voting health is restored.

## Sequence of operations

1. **Pre-start validation:** Confirm LT-101 valid, no low-low trip, selected pump available, downstream path healthy and protection status acceptable.
2. **Start duty pump:** Start the selected discharge pump at 30%; prove run feedback and speed response before the timeout.
3. **Enable automatic control:** Track current outputs, then release LIC-101 to automatic inventory control.
4. **Split-range response:** As level rises, progressively close LCV-101 and increase discharge-pump speed; reverse the response as level falls.
5. **Controlled changeover:** Start standby, prove run feedback, ramp to tracked demand, unload the old duty pump, stop it and transfer duty.
6. **Pump-fault transfer:** Remove the failed pump, latch the initiating fault and transfer to the healthy standby when available.
7. **High-high protection:** On 2oo3 at 90%, close and inhibit LCV-101; do not trip a healthy discharge pump solely for high level.
8. **Low-low protection:** On 2oo3 at 15%, trip and inhibit both discharge pumps to prevent dry running.
9. **Reset and recovery:** Require HH below 85% or LL above 20%, healthy channels and a deliberate manual reset.

## General interlock philosophy

- Inputs are scaled, range-checked and assigned a quality state before use.
- A start command is accepted only when all state-specific permissives are true.
- Outputs have safe defaults and are energized only by the current valid state.
- Faults remove the affected output, retain first-out/event information and block automatic restart.
- Reset is a deliberate command accepted only after the initiating condition has cleared.
- Independent trip or safety status overrides ordinary control commands.

## Testing boundary

The supplied logic and HTML simulation implement simplified dynamics for desktop verification. Setpoints, time delays, fail states and hardware interfaces require project-specific review before any physical implementation.
