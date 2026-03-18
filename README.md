# 🐍 Snake Game (8086 Assembly)

A classic Snake Game implemented in **8086 Assembly Language** using BIOS interrupts.
This project demonstrates low-level programming, direct hardware interaction, and game logic without any high-level libraries.

---

## 🎮 Game Features

* 🟩 Snake movement using **Arrow Keys / WASD**
* 🍎 Random food generation
* 📈 Score tracking system
* 💀 Collision detection:

  * Wall collision
  * Self collision
* 🔁 Game loop with real-time updates
* 🎨 Colored UI using BIOS interrupts
* 🧾 Welcome screen with ASCII art
* 🛑 Game Over screen with final score

---

## 🧠 Concepts Used

* 8086 Assembly Programming
* BIOS Interrupts (`INT 10h`, `INT 16h`, `INT 15h`)
* Memory manipulation (arrays for snake body)
* Game loop design
* Collision detection logic
* Pseudo-random number generation
* Screen buffer handling

---

## ⌨️ Controls

| Key   | Action     |
| ----- | ---------- |
| ↑ / W | Move Up    |
| ↓ / S | Move Down  |
| ← / A | Move Left  |
| → / D | Move Right |
| ESC   | Exit Game  |

---

## 🖥️ How to Run

### 🧾 Requirements

* DOSBox or any 8086 emulator
```
nasm snake.asm -f bin -o snake.com
```
```
snake.com
```
---

## 🚀 Future Improvements

* 🔊 Add sound effects
* ⏸️ Pause functionality
* ⚡ Increase speed with score
* 💾 LeadersBoard

---

🔥 Developed as part of coursework — but built like a real system.
