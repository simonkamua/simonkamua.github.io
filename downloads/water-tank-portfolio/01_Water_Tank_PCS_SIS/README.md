# Water-Tank PCS and SIS Control System

Prepared by Simon Kamua  
Status: Simulation Complete - Hardware Validation Pending  
Issue date: 02 August 2026

Start with **01_Water_Tank_PCS_SIS_Engineering_Dossier.pdf**. The editable Word control philosophy and Excel engineering registers are supplied beside it. Open **Interactive_Simulation.html** in a modern browser for the offline simulation.

## Package contents

- Engineering dossier PDF
- Editable control philosophy DOCX
- Editable engineering-register XLSX
- Project brief, control philosophy, test report and engineering reflection in Markdown
- Conceptual system drawing in SVG
- Functional I/O, alarm, cause-and-effect, split-range, setpoint and test registers in CSV
- Omron IEC 61131-3 reference logic and ESP32-S3 educational demonstrator code
- Standalone interactive simulation
- Deterministic test script, execution log and SHA256 integrity manifest

## Protective-action correction

- High-high level: close and inhibit the inlet valve; keep an eligible discharge pump available.
- Low-low level: trip and inhibit both discharge pumps to prevent dry running.

## Evidence labels

- **Design documented:** architecture, I/O, alarms, sequences, protection responses and test cases are defined.
- **Desktop tested:** deterministic checks and the browser simulation are supplied.
- **Not hardware validated:** no compiled Omron project, field I/O, FAT, SAT, live process connection or SIL verification is claimed.

## Safety and confidentiality

This independently developed educational project uses simulated values and sanitized tags. It contains no employer drawings, operating data, screenshots, PLC backups or configuration files. The ESP32-S3 is not a certified safety PLC and is not suitable for live safety service.
