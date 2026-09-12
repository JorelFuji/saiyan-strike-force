# Accessibility

Measurable accessibility requirements for Vulcan. Visual tokens: [design.md](design.md).

---

Replace "WCAG-AA-adjacent" with measurable requirements.

- Normal text: **minimum 4.5:1** against its immediate background.
- Large text: **minimum 3:1**.
- Non-text contrast (UI boundaries, focus, set-complete state, active row): **minimum 3:1** where WCAG non-text contrast applies. Shadows/glows outside the component do not count.
- Interactive targets ≥ 48×48dp.
- Layouts must not clip/overflow at:
  - largest iOS Dynamic Type sizes
  - largest Android font scaling
- Semantics on icon-only controls for VoiceOver and TalkBack.
- Test: Reduce Motion, bold text, OS high-contrast / increase-contrast where supported, landscape (must not crash or lose the session; need not be a primary layout), and a very small phone.
- Neumorphism is a known contrast risk: text and numerals use `text.*` on `bg.*`; interactive states add a real accent border, not only a shadow shift.
