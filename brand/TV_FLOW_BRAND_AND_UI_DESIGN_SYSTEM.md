# TV Flow Brand & UI Design System
**Version:** 1.0  
**Design direction:** Midnight Glass  
**Target:** 10-foot TV interfaces, 16:9, 1920 × 1080 logical canvas  
**Platforms:** Apple TV, Android TV, Fire TV, Smart TV

---

## 1. Brand foundation

### Brand idea
**TV Flow** is a premium, cinematic IPTV experience built around clarity, discovery, and effortless living-room navigation.

**Suggested tagline:** Stream. Discover. Enjoy.

### Brand personality
- Premium, modern, cinematic
- Confident but not visually noisy
- Content-first and easy to scan
- Accessible from a typical living-room viewing distance
- Designed for D-pad and remote-control interaction

### Visual language
- Deep midnight backgrounds
- Translucent teal glass surfaces, used selectively
- Electric yellow as the primary brand and focus accent
- Minimal white outline iconography
- Rounded cards and restrained depth
- Large, legible typography
- Clear, persistent focus indication

### Design principles
1. **Content leads.** Artwork and program information should be the visual priority.
2. **Focus is unmistakable.** Never communicate focus through scale or color alone.
3. **Readability beats density.** EPG and metadata screens should favor contrast over decorative glass effects.
4. **Motion supports orientation.** Animations should reinforce where focus moved, not distract.
5. **Consistency across devices.** Use a shared logical layout and adapt for platform-specific input and performance.

---

## 2. Color system

The palette is derived from the supplied visual reference and extended into a semantic system for product UI.

### Brand and foundation colors

| Token | Hex | RGB | Usage |
|---|---|---:|---|
| `brand.primary` | `#F5C400` | 245, 196, 0 | Logo accent, primary actions, focus ring |
| `brand.secondary` | `#13A6A5` | 19, 166, 165 | Secondary accent, current-time marker |
| `background.primary` | `#080D0F` | 8, 13, 15 | Main app background |
| `background.secondary` | `#101A1D` | 16, 26, 29 | Navigation and screen sections |
| `background.elevated` | `#17272B` | 23, 39, 43 | Elevated panels and modal foundations |
| `surface.default` | `#20383D` | 32, 56, 61 | Default glass/card surface |
| `surface.focused` | `#294D53` | 41, 77, 83 | Focused card and selected surface |
| `surface.highlight` | `#3D7278` | 61, 114, 120 | Highlighted or secondary emphasis |
| `text.primary` | `#FFFFFF` | 255, 255, 255 | Primary text |
| `text.secondary` | `#B8C4C5` | 184, 196, 197 | Supporting text |
| `text.disabled` | `#66777A` | 102, 119, 122 | Disabled labels and controls |
| `border.default` | `#FFFFFF` | 255, 255, 255 | Use at 14% opacity for subtle borders |
| `focus.primary` | `#F5C400` | 245, 196, 0 | High-contrast D-pad focus ring |

### Semantic status colors

| Token | Hex | RGB | Usage |
|---|---|---:|---|
| `status.success` | `#38C98A` | 56, 201, 138 | Successful actions |
| `status.error` | `#F05A5A` | 240, 90, 90 | Errors and destructive feedback |
| `status.warning` | `#FFB547` | 255, 181, 71 | Warnings |
| `status.live` | `#FF4545` | 255, 69, 69 | LIVE badge and on-air indicator |
| `status.recording` | `#E94C66` | 233, 76, 102 | Recording state |

### Color usage rules
- Use yellow for the primary brand accent and the active focus outline. Do not use it as a large background everywhere.
- Use teal for secondary actions, active timeline markers, and selected surfaces.
- Use white for essential information and high-priority labels.
- Use secondary text only for supporting information, not critical instructions.
- Use red exclusively for live/recording/error semantics where possible.
- Do not place small white text over bright yellow. Use `#080D0F` text on yellow.
- Validate contrast on real TV hardware and in both bright and dim rooms. The palette is a starting point, not a substitute for accessibility testing.

### Suggested palette swatches
- Electric Yellow: `#F5C400`
- Brand Teal: `#13A6A5`
- Midnight: `#080D0F`
- Deep Slate: `#101A1D`
- Elevated Slate: `#17272B`
- Glass Teal: `#20383D`
- Focus Teal: `#294D53`
- Teal Highlight: `#3D7278`
- White: `#FFFFFF`
- Mist: `#B8C4C5`

---

## 3. Typography

### Typeface
**Primary:** Inter  
**Fallbacks:** system sans-serif, Roboto (Android TV), SF Pro/system (Apple platforms)

Use the same typographic hierarchy across the app. Platform-native fonts may be substituted only where required by platform conventions.

### Type scale
Sizes below assume a 1920 × 1080 logical canvas.

| Style token | Size | Weight | Line height | Usage |
|---|---:|---:|---:|---|
| `type.hero` | 56 px | Bold 700 | 64 px | Featured title |
| `type.screen-title` | 42 px | Semibold 600 | 52 px | Main screen heading |
| `type.section-title` | 32 px | Semibold 600 | 40 px | Row/section heading |
| `type.media-title` | 28 px | Semibold 600 | 36 px | Movie/show title |
| `type.channel-number` | 26 px | Bold 700 | 32 px | Channel number |
| `type.navigation` | 22 px | Medium 500 | 28 px | Navigation labels |
| `type.channel-name` | 22 px | Medium 500 | 30 px | Channel name |
| `type.epg-title` | 20 px | Medium 500 | 28 px | Program title |
| `type.description` | 20 px | Regular 400 | 30 px | Content description |
| `type.metadata` | 18 px | Regular 400 | 26 px | EPG metadata and details |
| `type.badge` | 16 px | Semibold 600 | 20 px | LIVE, 4K, HD, CC |
| `type.caption` | 16 px | Medium 500 | 22 px | Supporting labels |

**TV readability rule:** Avoid essential information below 16 px on the 1920 × 1080 logical canvas. Test actual viewing distance, screen size, and platform scaling.

### 4K scaling
If the application uses a 1920 × 1080 logical coordinate system and the platform scales it to 4K, keep these logical sizes. If designing natively at 3840 × 2160, use a consistent 2× scale.

---

## 4. Layout and grid

### Canvas and safe area

| Property | Value |
|---|---:|
| Design canvas | 1920 × 1080 |
| Aspect ratio | 16:9 |
| Left safe margin | 80 px |
| Right safe margin | 80 px |
| Top safe margin | 60 px |
| Bottom safe margin | 60 px |
| Grid columns | 12 |
| Column gutter | 24 px |
| Base spacing unit | 8 px |

Keep essential text, logos, and controls within the safe area. Artwork may bleed to the edge when intentional. Confirm overscan behavior on target devices.

### Spacing tokens

| Token | Value |
|---|---:|
| `space.1` | 4 px |
| `space.2` | 8 px |
| `space.3` | 16 px |
| `space.4` | 24 px |
| `space.5` | 32 px |
| `space.6` | 48 px |
| `space.7` | 64 px |
| `space.8` | 80 px |

### Radius tokens

| Token | Value | Usage |
|---|---:|---|
| `radius.xs` | 8 px | Small badges |
| `radius.sm` | 14 px | Buttons |
| `radius.md` | 16 px | Navigation items and posters |
| `radius.lg` | 24 px | Standard cards |
| `radius.xl` | 28 px | Featured cards and modals |
| `radius.2xl` | 32 px | Large overlays |

### General layout rules
- Use a 12-column grid for broad screen composition.
- Use 24 px gutters and an 8 px spacing rhythm.
- Maintain at least 24–32 px between major content groups.
- Align card rows and section headings consistently.
- Avoid placing critical controls close to screen edges.
- Preserve visible context when a focused row scrolls.

---

## 5. Surface, border, and elevation

### Glass surface recipe

Use glassmorphism as a signature treatment for the home dashboard, navigation overlays, and selected hero panels. Avoid heavy transparency behind dense EPG text.

```css
.glass-card {
  background: rgba(32, 56, 61, 0.72);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 24px;
  backdrop-filter: blur(24px);
  box-shadow:
    0 12px 40px rgba(0, 0, 0, 0.30),
    inset 0 1px 0 rgba(255, 255, 255, 0.10);
}
```

### Focused surface recipe

```css
.focused {
  background: #294D53;
  border: 3px solid #F5C400;
  box-shadow: 0 0 22px rgba(245, 196, 0, 0.20);
  transform: scale(1.04);
}
```

### Performance fallback
If `backdrop-filter` is unavailable or too expensive, use a pre-composited opaque surface close to `#20383D` or `#17272B`. Keep focus and text contrast intact.

---

## 6. Component specifications

### 6.1 Main navigation

**Recommended pattern:** Collapsible vertical sidebar.

| Property | Specification |
|---|---|
| Collapsed width | 104 px |
| Expanded width | 300 px |
| Item height | 72 px |
| Icon size | 28–32 px |
| Label size | 22 px |
| Item radius | 16 px |
| Vertical gap | 12 px |
| Default background | Transparent or `#101A1D` |
| Active background | `#294D53` |
| Active indicator | 4 px `#F5C400` |

Suggested items:
1. Home
2. Live TV
3. Movies
4. Series
5. Favorites
6. Recordings
7. Search
8. Settings

When collapsed, retain recognizable icons and provide a clear label on focus. The active screen and focused item are separate states.

### 6.2 Live TV / EPG

| Property | Specification |
|---|---|
| Channel column | 240 px |
| Timeline header | 64 px |
| Channel row height | 88 px |
| Program cell minimum width | 180 px |
| Program cell radius | 10 px |
| Cell gap | 4 px |
| Grid background | `#101A1D` |
| Program surface | `#20383D` |
| Focused program | `#294D53` |
| Focus outline | 3 px `#F5C400` |

EPG behavior:
- Left/right moves between programs.
- Up/down moves between channels.
- OK opens program details or tunes to the channel, depending on context.
- Long-press OK opens contextual actions where supported.
- A vertical current-time indicator uses `#13A6A5` or `#F5C400`.
- Keep channel logos, channel numbers, and names aligned consistently.
- Ensure program titles truncate gracefully without obscuring start/end times.

### 6.3 VOD poster cards

| Property | Specification |
|---|---|
| Portrait ratio | 2:3 |
| Landscape ratio | 16:9 |
| Portrait width | 200–240 px |
| Portrait height | 300–360 px |
| Corner radius | 16 px |
| Focus outline | 3 px `#F5C400` |
| Focus scale | 1.04–1.06 |
| Metadata gap | 12 px |

Poster metadata may include:
- Title
- Release year
- Genre
- Rating
- 4K / HD badge
- Watch-progress indicator

Keep text below artwork where possible. Use gradients only when text must overlay artwork, and ensure sufficient contrast.

### 6.4 Buttons

| Variant | Default | Focused | Disabled |
|---|---|---|---|
| Primary | Yellow fill, dark text | Yellow fill + outer focus ring | Muted dark surface |
| Secondary | Glass surface, white text | Teal surface + yellow outline | Reduced opacity |
| Tertiary | Transparent, white text | Elevated surface + yellow outline | Muted text |

Recommended dimensions:
- Minimum height: 64 px
- Horizontal padding: 24–32 px
- Radius: 14 px
- Label: 20–22 px, medium/semibold

### 6.5 Badges

| Badge | Treatment |
|---|---|
| LIVE | Red dot and red/dark pill |
| REC | Red recording dot and label |
| 4K | Yellow fill, dark text |
| HD | Dark/neutral fill, white text |
| CC | Outlined or dark badge |
| NEW | Teal or yellow accent, used sparingly |

Badge height: 28–32 px. Use 16 px semibold text.

### 6.6 Dialogs and overlays
- Modal radius: 28 px.
- Surface: `#17272B` or opaque `#20383D`.
- Border: 1 px white at 14% opacity.
- Padding: 32–48 px.
- Backdrop: black at approximately 70% opacity.
- Initial focus must land on a predictable control.
- Keep focus within the dialog until dismissed.
- Back closes the topmost dismissible overlay.

---

## 7. Iconography and asset requirements

### Icon style
Use a consistent outline icon family, such as Lucide, with a 2–2.5 px stroke and rounded joins. Do not mix unrelated icon families.

| Icon purpose | Suggested icon concept | Size |
|---|---|---:|
| Home | House | 28–32 px |
| Live TV | TV | 28–32 px |
| Movies | Clapperboard / film | 28–32 px |
| Series | Play in screen | 28–32 px |
| Favorites | Heart | 28–32 px |
| Recordings | Record circle | 28–32 px |
| Subtitles | Captions / CC | 24–28 px |
| Audio track | Audio lines / waveform | 24–28 px |
| Search | Magnifying glass | 28–32 px |
| Settings | Gear | 28–32 px |
| Timeshift | Clock / history | 28–32 px |
| Information | Circle-info | 24–28 px |
| Play | Triangle | 24–28 px |
| Pause | Pause bars | 24–28 px |
| Back | Chevron-left / arrow-left | 28–32 px |

### Icon state rules
- Default: `#FFFFFF`
- Focused: `#F5C400`
- Active: `#F5C400`
- Disabled: `#66777A`
- LIVE: `#FF4545`
- Recording: `#E94C66`

### Brand and product assets to prepare
1. Primary TV Flow logo, horizontal, SVG.
2. Compact logo mark, SVG.
3. App icon, square 1:1.
4. TV app splash artwork, 16:9.
5. Empty-state illustrations for Favorites, Search, and Recordings.
6. Placeholder artwork for missing movie posters and channel logos.
7. Channel logo asset set, preferably SVG or transparent PNG.
8. Content artwork guidelines for portrait posters and landscape backdrops.
9. Focus-state and status icon set.
10. Optional profile avatars and category artwork.

**Logo note:** Preserve the supplied TV Flow wordmark direction, with the lowercase wordmark in white and the “b” accent in electric yellow. Treat this as a visual direction until the official vector logo is supplied or approved.

---

## 8. Interaction and D-pad behavior

### Remote mapping

| Remote input | Expected behavior |
|---|---|
| Up | Move to previous row or navigation item |
| Down | Move to next row or navigation item |
| Left | Move to previous item or previous timeline slot |
| Right | Move to next item or next timeline slot |
| OK / Select | Activate focused element |
| Back | Return to previous screen or dismiss top overlay |
| Play / Pause | Toggle playback when supported |
| Long press OK | Open contextual actions where supported |

### Focus states

| Property | Default | Focused | Active / Playing | Disabled |
|---|---|---|---|---|
| Surface | `#20383D` | `#294D53` | `#F5C400` or active surface | `#17272B` |
| Border | 1 px subtle | 3 px yellow | 2–3 px yellow | None/subtle |
| Text | White | White | `#080D0F` on yellow | `#66777A` |
| Scale | 1.00 | 1.04–1.06 | 1.00–1.03 | 1.00 |
| Shadow | Subtle | Yellow glow | Subtle | None |

Motion:
- Fast feedback: 150 ms.
- Standard focus transition: 180 ms.
- Screen/overlay transition: 240–280 ms.
- Use ease-out for focus movement.
- Do not animate every element independently.
- Respect reduced-motion settings where available.

### Focus management checklist
- Every screen has a predictable initial focus target.
- Focus never disappears during navigation.
- Directional movement follows a logical path.
- Scrolling keeps the focused item fully visible.
- Modals trap focus until dismissed.
- Returning from a detail page restores the previous item and scroll position.
- Focus is communicated through more than scale alone.
- Test with an actual remote, not only a keyboard.

---

## 9. Core screen patterns

### Home dashboard
- Featured hero with backdrop artwork.
- Title, synopsis, genre, year, and rating.
- Primary Watch Now and secondary More Info actions.
- Trending Now poster row.
- Continue Watching row.
- Live TV highlights.
- Recently Added content.
- Profile, search, and settings affordances in the top area.

### Live TV
- Channel category/filter rail.
- Channel list and EPG timeline.
- Current program and next program.
- Live badge and current-time marker.
- Favorite and recording actions.
- Program details overlay.

### Movies
- Featured movie hero.
- Genre collections.
- Trending and popular rows.
- Recently added.
- Search and filter controls.
- Detail view with synopsis, metadata, and playback actions.

### Series
- Featured series.
- Genre collections.
- Continue Watching.
- Season and episode selection.
- Episode detail and progress state.

### Player
- Full-bleed video.
- Controls appear on OK or playback interaction.
- Progress bar and elapsed/remaining time.
- Play/pause, rewind, fast-forward.
- Audio and subtitle selection.
- Quality and playback information where supported.
- Auto-hide controls after inactivity, while preserving remote accessibility.

### Settings
- Account and profiles.
- Playlist/source management.
- Playback preferences.
- Parental controls.
- Display and accessibility.
- App information and diagnostics.

---

## 10. Figma library structure

```text
TV Flow Design System
├── 00 - Cover & Guidelines
├── 01 - Foundations
│   ├── Color
│   ├── Typography
│   ├── Spacing & Grid
│   ├── Radius
│   ├── Borders & Elevation
│   └── Motion
├── 02 - Assets
│   ├── Logos
│   ├── Icons
│   ├── Channel Logos
│   ├── Posters & Backdrops
│   ├── Avatars
│   └── Empty States
├── 03 - Components
│   ├── Buttons
│   ├── Navigation
│   ├── Media Cards
│   ├── EPG
│   ├── Badges
│   ├── Player Controls
│   ├── Dialogs
│   └── Inputs & Filters
├── 04 - Patterns
│   ├── Home Rows
│   ├── Featured Hero
│   ├── Channel Guide
│   ├── Content Details
│   └── Remote Focus Flows
├── 05 - Screens
│   ├── Home
│   ├── Live TV
│   ├── Movies
│   ├── Series
│   ├── Player
│   └── Settings
└── 06 - Prototypes
    ├── D-pad Navigation
    ├── Playback
    └── Screen Transitions
```

### Component naming convention

```text
Button/Primary/Default
Button/Primary/Focused
Button/Primary/Disabled

Navigation/Item/Default
Navigation/Item/Focused
Navigation/Item/Active

Card/Media/Default
Card/Media/Focused
Card/Media/Playing

EPG/Channel/Default
EPG/Channel/Focused
EPG/Program/Default
EPG/Program/Focused

Badge/Live
Badge/Recording
Badge/4K
Badge/HD
Badge/CC
```

Use Figma variables for colors, spacing, radii, and typography. Use component properties and variants for interactive states.

---

## 11. Development tokens

Starter CSS custom properties:

```css
:root {
  /* Brand */
  --brand-primary: #F5C400;
  --brand-secondary: #13A6A5;

  /* Background */
  --bg-primary: #080D0F;
  --bg-secondary: #101A1D;
  --bg-elevated: #17272B;

  /* Surface */
  --surface-default: #20383D;
  --surface-focused: #294D53;
  --surface-highlight: #3D7278;

  /* Text */
  --text-primary: #FFFFFF;
  --text-secondary: #B8C4C5;
  --text-disabled: #66777A;

  /* Status */
  --status-success: #38C98A;
  --status-error: #F05A5A;
  --status-warning: #FFB547;
  --status-live: #FF4545;
  --status-recording: #E94C66;

  /* Focus and borders */
  --focus-color: #F5C400;
  --border-default: rgba(255,255,255,0.14);
  --border-focus: #F5C400;

  /* Radius */
  --radius-xs: 8px;
  --radius-sm: 14px;
  --radius-md: 16px;
  --radius-lg: 24px;
  --radius-xl: 28px;
  --radius-2xl: 32px;

  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 16px;
  --space-4: 24px;
  --space-5: 32px;
  --space-6: 48px;
  --space-7: 64px;
  --space-8: 80px;

  /* Motion */
  --motion-fast: 150ms;
  --motion-normal: 180ms;
  --motion-slow: 280ms;
}
```

---

## 12. Quality and accessibility checklist

### Visual
- [ ] Primary and secondary brand colors are used consistently.
- [ ] Essential text is readable at typical living-room distance.
- [ ] Content artwork has sufficient contrast behind overlaid text.
- [ ] Glass effects do not compromise dense information.
- [ ] Focus ring is visible on every interactive component.
- [ ] Color is not the only way a state is communicated.

### Remote navigation
- [ ] Every interactive element is reachable by D-pad.
- [ ] Focus order is predictable.
- [ ] Focus is restored after modal and detail navigation.
- [ ] Back behavior is consistent.
- [ ] Long-press behavior is discoverable.
- [ ] Scrolling never hides the focused item.

### Platform and performance
- [ ] Test on actual Apple TV, Android TV, Fire TV, and target Smart TV devices.
- [ ] Validate safe areas and overscan.
- [ ] Test 1080p and 4K output.
- [ ] Verify image loading and fallback states.
- [ ] Provide a no-blur fallback for glass surfaces.
- [ ] Respect platform reduced-motion and accessibility settings.
- [ ] Confirm focus behavior with the actual remote-control APIs.

---

## 13. Recommended implementation order

1. Lock brand palette, typography, spacing, and grid foundations.
2. Create logo assets and the core icon family.
3. Build navigation, buttons, badges, cards, and focus-state components.
4. Build the home dashboard and media detail patterns.
5. Build the Live TV EPG with real D-pad navigation.
6. Build the player controls and overlays.
7. Build Movies, Series, Favorites, and Settings screens.
8. Prototype end-to-end remote flows.
9. Test on target hardware and tune contrast, typography, motion, and performance.

---

## 14. Design decisions and open items

This specification is a recommended starting system based on the supplied reference image. Before production, confirm:

- Official TV Flow logo/vector artwork and trademark usage.
- Exact target TV platforms and minimum hardware.
- Whether the app uses a 1920 × 1080 logical canvas or native density scaling.
- Actual IPTV provider capabilities for EPG, catch-up, recording, subtitles, and audio tracks.
- Accessibility and contrast targets for the final implementation.
- Whether the sidebar is always visible, collapsible, or replaced by a top navigation on selected platforms.

**North star:** TV Flow should feel like a premium streaming destination, with the visual richness of cinematic glass surfaces and the clarity and predictability required by a remote-first television interface.
