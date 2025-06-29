# 🎹 Piano ASM – PC Speaker Piano in x86 Assembly

Welcome to **Piano ASM**, a simple musical keyboard simulator built in **x86 Assembly (TASM)**. This project uses direct hardware control to generate sound through the **PC speaker**, turning your keyboard into a minimalist piano.

---

## 🎼 What It Does

Each keypress plays a different musical tone through the PC speaker.  
It’s a fun demonstration of low-level programming, real-time keyboard input, and hardware-level sound synthesis — no libraries, no OS sound APIs, just raw Assembly.

---

## 🛠 Tech Stack

- **Language**: x86 Assembly (TASM)
- **Sound Output**: PC Speaker via PIT (Programmable Interval Timer)
- **Tools**: Turbo Assembler (`TASM`), Turbo Linker (`TLINK`)
- **Emulation**: DOSBox

---

## 🎮 Controls

| Key | Note  |
|-----|-------|
| A   | W     |
| S   | E     |
| D   | T     |
| F   | y     |
| G   | u     |
| H   |       |
| J   |       |

> *you can open the meny by pressing "M" *

---

## 🚀 How to Run

tasm /zi pianoAri
tlink /v pianoAri
pianoAri
