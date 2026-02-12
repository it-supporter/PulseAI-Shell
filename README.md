# PulseAI Shell

PulseAI Shell is a minimal, state-aware PowerShell prompt built with Oh My Posh, designed for focused development and intelligent Git awareness.

---

## Philosophy

PulseAI Shell follows one principle:

**State over decoration.**

It stays calm and minimal by default, and reacts visually only when state changes.

- Clean diamond layout
- Minimal visual noise
- Reactive error signaling
- Branch-aware color logic
- Nerd Font optimized

---

## Features — v0.1.0

- Live timestamp segment
- Error indicator (warning triangle)
- Username segment
- Agnoster-style path segment
- Git branch awareness
    - `dev` → light green
    - `main` → light red
    - other branches → lavender

---

## Requirements

- PowerShell 7+
- Oh My Posh v29+
- Nerd Font (recommended: CaskaydiaCove Nerd Font)
- Windows Terminal (recommended)

---

## Installation

Copy the theme file to:

```powershell
$HOME\.config\oh-my-posh\


Then add to your PowerShell profile:

oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\pulseai-shell.omp.json" | Invoke-Expression

## Roadmap

- [ ] Custom profile template
- [ ] Branch icon support
- [ ] Light theme variant
- [ ] Cross-platform testing
- [ ] v1.0 stabilization