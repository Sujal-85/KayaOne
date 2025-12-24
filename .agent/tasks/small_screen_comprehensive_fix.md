# Task: Optimize All Screens for Small Mobile Devices

The goal is to ensure the application renders correctly and looks good on small mobile devices (e.g., width <= 360px).

## 1. Home Screen (`home_screen.dart`)
- [ ] **Search Bar**: Reduce vertical padding. (Partially done, need to verify).
- [ ] **HealthKarma Card**:
    - Use `LayoutBuilder` to adapt padding (28 -> 16/20).
    - Reduce title font size (22 -> 18/20).
    - ensure text wrapping.
- [ ] **AI Assistant Card**:
    - Use `LayoutBuilder` / `Stack`.
    - Constrain text width so it doesn't overlap with the image.
    - Adjust image size/position for small screens.

## 2. My Bookings / Care Screen (`my_appointments_screen.dart`)
- [ ] **Appointment Cards**:
    - Verify text wrapping for titles and subtitles.
    - Reduce horizontal padding in cards (24 -> 16).
    - Ensure action buttons don't overflow.

## 3. Find Doctor Screen (`doctor_listing_screen.dart`)
- [ ] **Doctor Cards**:
    - Check for RenderFlex overflows in rows (Rating, Experience, Fees).
    - Wrap long text fields (Name, Specialty) in `Flexible`.
    - Adjust image size if necessary.

## 4. HealthKarma Screen (`health_karma_screen.dart`)
- [ ] **General Layout**:
    - Analyze `build` method for fixed height/width constraints.
    - Ensure `SingleChildScrollView` is used where vertical content might exceed screen height.
    - Check charts or grids for overflow.

## Strategy
- Use `MediaQuery.of(context).size.width` or `LayoutBuilder` to make decisions.
- Replace fixed `SizedBox` spacing with smaller values on small screens.
- Use `Flexible` and `Expanded` for text in Rows.
