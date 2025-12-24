# Task: Optimize Home Screen for Small Mobile Devices

The specific areas of focus are the Search Bar, HealthKarma Card, and AI Assistant Card layout compatibility for small screens (e.g., width <= 360px).

## 1. Search Bar
- **Goal**: Ensure the SliverAppBar and search bar don't take up too much vertical space or break layout.
- **Action**:
    - Reduce `expandedHeight` of `SliverAppBar` based on screen height/width.
    - Confirm the search bar padding is optimized (already reduced to 12, check if other adjustments are needed).

## 2. HealthKarma Card (`_buildHealthKarmaSection`)
- **Goal**: Prevent overflow and squashed text.
- **Action**:
    - Wrap the main content `Row` in a `LayoutBuilder`.
    - If width is narrow, consider stacking elements or reducing the size of the score circle (currently 80px).
    - Reduce padding from `28` to `20` or `16` on small screens.

## 3. AI Assistant Card (`_buildAIAssistantPromo`)
- **Goal**: Prevent text from overlapping with the background image or shrinking to zero width.
- **Action**:
    - Adjust the `Positioned` image. If the screen width is small, move the image further right (e.g., `right: -60`) or shrink its width.
    - Ensure the text `Column` has a width constraint (e.g., `SizedBox(width: width * 0.6)`) so it doesn't try to occupy space already taken conceptually by the image, but also doesn't get pushed out.
    - Reduce `height` from fixed `210` to something dynamic or `auto` if needed, but `210` is fine if content fits.

## 4. General
- Use `MediaQuery` to detect screen width (e.g., `< 380` is "small").
