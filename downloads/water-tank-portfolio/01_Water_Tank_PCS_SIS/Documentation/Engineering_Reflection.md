# Engineering Reflection - Water-Tank PCS and SIS Control System

## Key decisions

- **Inventory-reduction demand:** A rising controller output means more inventory removal: close the inlet and increase discharge capacity.
- **Correct protective split:** High-high removes inflow but preserves healthy outflow; low-low removes pump outflow to prevent dry running.
- **Separate transmitters:** LT-101 serves normal control while LT-201A/B/C provide an independent educational voting layer.
- **Manual reset with hysteresis:** Separate reset thresholds prevent chatter and automatic restart at the trip boundary.
- **Bumpless pump transfer:** Proving and loading the incoming pump before unloading the outgoing pump reduces hydraulic disturbance.

## Limitations

- The simplified model omits pump curves, NPSH, valve stiction, line packing and pressure transients.
- PID tuning, split-range overlap and ramps are illustrative and require validated process data.
- The ST listing is a design reference, not a compiled Omron hardware project.
- The ESP32-S3 lacks certified diagnostics, systematic capability and independence evidence.

## Recommended improvements

- Implement the selected Omron PID block with tracking, anti-windup and validated tuning.
- Add run-hour balancing, maintenance counters and equipment plausibility diagnostics.
- Build a low-voltage rig and execute witnessed FAT-style tests.
- Use certified hardware and complete an SRS and SIL verification before any genuine safety application.

## Professional reflection

The project demonstrates the progression from process requirement to instrumentation and I/O definition, control philosophy, sequence logic, abnormal-condition handling and structured testing. The strongest evidence is not the amount of code, but the traceability between process purpose, signal condition, control decision, equipment response and recovery requirement.
