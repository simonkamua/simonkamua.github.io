# Water-Tank PCS and SIS Control System

Status: Simulation Complete - Hardware Validation Pending  
Platform: Omron IEC 61131-3 PCS reference; ESP32-S3 educational protection demonstrator; standalone HTML simulation  
Prepared by: Simon Kamua  
Issue date: 01 August 2026

## Scope

A reservoir feeds TK-101 through fail-close LCV-101. Two VFD pumps, P-101A and P-101B, discharge the tank in duty/standby service. The Omron PCS maintains level using an inventory-reduction controller whose split-range outputs progressively close the inlet valve and increase discharge-pump speed as level rises. A separate ESP32-S3 educational demonstrator receives LT-201A/B/C and applies independent 2oo3 votes: high-high closes and inhibits the inlet; low-low trips and inhibits both discharge pumps.

## Objectives

- Maintain TK-101 close to the illustrative 55% operating setpoint under changing inlet and downstream conditions.
- Coordinate fail-close LCV-101 and the selected discharge pump through an explicit split-range characteristic.
- Select duty and standby pumps in the PCS and perform a status-verified bumpless changeover.
- Detect start failure, unexpected stop, VFD/motor faults, speed deviation, no-flow operation and loss of both pumps.
- Demonstrate separate 2oo3 high-high inlet shutdown and low-low pump shutdown functions with latching and manual reset.

## Assumptions

- LCV-101 is installed on the reservoir-to-tank inlet and fails closed on loss of its protective permit.
- P-101A/B are parallel discharge pumps downstream of TK-101, with a 30% illustrative minimum stable VFD speed.
- LT-101 is the normal PCS measurement and uses detected upscale burnout handling.
- LT-201A/B/C are separate protection measurements with individual quality and disagreement diagnostics.
- Protection outputs override PCS commands through independent de-energize-to-trip interfaces.

## Exclusions

- No SIL claim, SIL verification, PFDavg calculation, certified diagnostics or proof-test coverage is provided.
- No live process connection, hydraulic sizing, NPSH study, valve Cv calculation, pump-curve validation or network design is included.
- Illustrative setpoints, tuning, delays and actuator limits are not suitable for direct plant application.
- The ESP32-S3 is not a certified safety PLC and must not be used for operational protection.

## Evidence status

- Design basis and control philosophy: complete.
- Reference source logic: supplied; requires vendor adaptation and compilation.
- Desktop reference-model tests: passed.
- Interactive simplified simulation: supplied.
- Hardware FAT, SAT and live-plant validation: not performed.

This is an independently developed educational project using simulated values and sanitized tags. It is not approved for live plant use.
