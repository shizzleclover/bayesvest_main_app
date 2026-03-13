# Design System: Editorial Advisory

## 1. Overview & Creative North Star: "The Intelligent Canvas"
This design system moves beyond the utility of standard fintech apps to create an experience of "The Intelligent Canvas." It is a philosophy of editorial restraint where the advisor’s wisdom is the focal point, not the interface itself. 

Unlike the cluttered, data-heavy "trading" dashboards of the past, this system uses intentional asymmetry and expansive white space to cultivate a sense of calm and institutional trust. We break the rigid, boxy grid by treating the UI as a series of floating, layered compositions. Elements are allowed to breathe, and hierarchy is communicated through massive shifts in scale rather than a barrage of icons and lines. This is not just an app; it is a premium digital concierge.

---

## 2. Colors: The Tonal Depth Strategy
We rely on a "High-Couture Blue" palette. While Ribbon Blue (`#0066FF`) is our pulse, it is the sophisticated layering of whites and off-whites that defines the premium feel.

### The Palette
- **Primary Foundation:** `primary` (#0050cb) for core actions; `primary_container` (#0066ff) for high-impact brand moments.
- **Surface & Background:** `surface` (#f9f9ff) acts as our primary stage. 
- **The "No-Line" Rule:** 1px solid borders are strictly prohibited for sectioning. Boundaries must be defined exclusively through background color shifts. For example, a `surface_container_low` card sits on a `surface` background. If you feel the need to draw a line, instead add `16px` (spacing-4) of vertical padding and shift the background hex.
- **Surface Hierarchy & Nesting:** Use the tiers to create a physical stack.
    - *Level 0:* `surface_container_lowest` (#ffffff) for the primary content card.
    - *Level 1:* `surface` (#f9f9ff) for the main application background.
    - *Level 2:* `surface_container` (#e9edff) for secondary contextual sidebars.
- **The Glass & Gradient Rule:** For "advisor-led" moments (like a floating chat bubble or a premium insight), use Glassmorphism. Set the background to `primary_container` at 8% opacity with a `24px` backdrop-blur. Apply a subtle gradient from `primary` to `primary_container` for hero CTAs to give them a "lit from within" glow.

---

## 3. Typography: Editorial Authority
We utilize **Manrope** for high-impact displays and **Inter** for functional reading. This pairing evokes the feeling of a premium financial broadsheet.

- **Display (The Bold Statement):** Use `display-lg` (Manrope, 3.5rem) for portfolio totals. The weight should be heavy, commanding the page and demanding the user’s focus.
- **Headline (The Navigator):** `headline-md` (Manrope, 1.75rem) provides the editorial "hook" for new sections.
- **Body (The Advisor):** `body-lg` (Inter, 1rem) is our workhorse. Use it for all advisor recommendations. The increased line height (approx 1.6) is non-negotiable to maintain a "calm" reading experience.
- **Labels (The Detail):** `label-md` (Inter, 0.75rem) should always be in `on_secondary_container` (#5e6572) to remain present but never distracting.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are too "software-like." We create depth through light and atmospheric layering.

- **The Layering Principle:** Stacking is the new shadowing. Place a `surface_container_lowest` element atop a `surface_dim` background. The 2-3% shift in brightness is enough for the human eye to perceive depth without adding visual noise.
- **Ambient Shadows:** For floating modals, use a shadow with a `40px` blur and `4%` opacity. The shadow color must be a tinted blue (`#141b2b` at 4%) rather than pure black to mimic a natural, lit environment.
- **The Ghost Border Fallback:** If a container absolutely requires a boundary for accessibility, use the `outline_variant` token at **15% opacity**. It should be a whisper of a line, not a wall.

---

## 5. Components: Refined Interaction

- **Buttons (Border Radius: 12px):** 
    - *Primary:* Solid `primary_container`. No border.
    - *Secondary:* `surface_container_high` background with `on_surface` text. This feels "carved" out of the interface rather than pasted on.
- **Inputs (Border Radius: 10px):** 
    - Use a `surface_container_low` background. On focus, transition the background to `surface_container_lowest` and add a `2px` "Ghost Border" of `primary`.
- **Cards (Border Radius: 16px):** 
    - **No dividers.** To separate a header from a body within a card, use a `24px` (spacing-6) gap. 
    - **The Signature Advisor Card:** A `surface_container_highest` card with a `primary` left-accent bar (4px wide) to denote "Expert Advice."
- **Lists:** 
    - Use `surface_container_lowest` for list items. Instead of a divider line between items, use an `8px` (spacing-2) vertical gap to let the background "bleed" through.
- **Investment Chips:** 
    - Use `tertiary_fixed` (#b7eaff) for positive growth indicators. They should be pill-shaped and use `label-md` typography.

---

## 6. Do’s and Don’ts

### Do:
- **Embrace Asymmetry:** Let a chart bleed off the right edge of the grid while keeping text aligned to the left.
- **Use "White Space" as a Tool:** If a screen feels "empty," it’s likely working. Avoid the urge to fill it with "widgets."
- **Nesting Surfaces:** Place a white input inside a light blue container to create a "sunken" interactive feel.

### Don't:
- **Never use pure black (#000000).** Use `on_background` (#141b2b) for a softer, more sophisticated high-contrast look.
- **Avoid 1px Divider Lines.** They create "visual friction." Use color blocks or spacing instead.
- **No Sharp Corners.** All interactive elements must adhere to the 10px/12px/16px radius scale to maintain the "Soft Minimal" personality.
- **Don't Over-Iconize.** If a word describes the action clearly (e.g., "Invest"), an icon is likely unnecessary noise. Let the typography do the work.