# Test Specification and Report - Water-Tank PCS and SIS Control System

## Method

Tests compare documented preconditions and expected behavior with the deterministic reference model and interactive simulation. These results are not hardware FAT or SAT.

## Results

| Test | Scenario | Preconditions | Expected | Result | Evidence |
|---|---|---|---|---|---|
| WT-001 | Normal automatic start | Level 55%; duty A ready | A starts at minimum speed; tracked auto control enabled | PASS | Reference model + HTML |
| WT-002 | High-level disturbance | Auto stable | LCV closes progressively; discharge speed increases | PASS | Reference model + HTML |
| WT-003 | Low-level disturbance | Auto stable above LL | LCV opens; discharge speed reduces toward minimum | PASS | Reference model + HTML |
| WT-004 | Duty changeover A to B | Both pumps ready | B reaches tracked demand before A stops | PASS | HTML simulation |
| WT-005 | Duty-pump failure | A duty; B ready | A is removed and B assumes duty | PASS | HTML fault injection |
| WT-006 | PCS LT burnout | Auto running | Inlet closes; new auto starts blocked; protection remains available | PASS | Reference model |
| WT-007 | One LT-201 channel high | Other channels normal | No HH trip; disagreement/degraded indication | PASS | Reference model + HTML |
| WT-008 | Two channels high-high | Protection healthy | Inlet trip latches; discharge pump remains available | PASS | Reference model + HTML |
| WT-009 | One LT-201 channel low | Other channels normal | No LL trip | PASS | Reference model |
| WT-010 | Two channels low-low | Protection healthy | Both pumps trip and restart is inhibited | PASS | Reference model + HTML |
| WT-011 | Reset with active cause | HH or LL remains active | Reset rejected | PASS | Design inspection + HTML |
| WT-012 | Channel invalid | Trip latched | Degraded alarm; reset blocked | PASS | Code inspection |

Summary: 12/12 specified desktop tests PASS.

## Outstanding validation

- Compile against selected controller and hardware configuration.
- Execute I/O, boundary, timeout, power-cycle and abnormal scenario tests on a low-voltage rig.
- Record witness, defect, retest and checksum evidence.
