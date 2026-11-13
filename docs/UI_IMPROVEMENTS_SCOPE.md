# Mobile UI Improvements Scope

**Source:** Figma comparison and mobile UI audit, November 2026  
**Status:** Proposed scope for review; no implementation is authorized by this document.  
**Design reference:** [Beige App Design — Figma](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=7343-57518&m=dev)

## Purpose

Prioritize mobile UI improvements by **impact area** and **priority**. Priority is expressed as **High, Medium, and Low**. High-impact findings should be addressed first because they affect accessibility, key booking and payment journeys, or users' ability to reach important controls. Medium items improve consistency and usability. Low items are polish or scope decisions.

This is a scope proposal, not a record of completed changes. Product behavior and pricing should be confirmed before related UI work begins.

## Priority guide

| Priority | Meaning |
| --- | --- |
| **High** | Accessibility barrier, booking/payment comprehension issue, broken or unreachable action, or substantial Figma gap in a core customer journey. |
| **Medium** | Noticeable visual inconsistency, interaction friction, or missing supporting detail with a usable current flow. |
| **Low** | Cosmetic refinement, deferred feature, or product-scope decision that does not block the core journey. |

## Impact area: accessibility and mobile fundamentals

### High

- **Restore system text scaling.** The app globally disables text scaling. Respect the user's accessibility setting and adjust layouts to wrap and scroll instead of shrinking or clipping text.
- **Increase undersized touch targets.** Give small controls—including booking quantity steppers, wizard navigation, profile back controls, partner profile arrows, and meeting RSVP actions—at least a 48×48 logical-pixel interactive area while preserving their visual size where appropriate.
- **Improve low-contrast secondary text.** Review muted labels, placeholders, inactive navigation, and metadata. The current `#777571` tertiary text measures approximately 3.67:1 against `#1D1D1B` and 3.30:1 against `#262624`.
- **Standardize safe-area handling.** Protect bottom actions and screen content from gesture areas, notches, and keyboards. Prioritize onboarding, authentication, edit profile, booking summaries, and manage/cancel booking screens.

### Medium

- **Raise small text sizes.** Prefer 12–14px for metadata and 14–16px for body text. Review existing 9–10px styles, especially on shoot summaries and file cards.
- **Add clear press feedback.** The app theme suppresses splash and highlight feedback. Provide a subtle visible state for tappable rows, cards, buttons, and icon controls.
- **Set a consistent screen spacing scale.** Use 20px horizontal gutters as the primary screen pattern, with documented exceptions for dense lists and nested cards.

## Impact area: design system and shared components

### High

- **Create consistent accessible button variants.** Standardize primary, secondary, outline, text, destructive, loading, and disabled states. Use a minimum 48px height and the Figma's 56px primary-button treatment where it fits the screen.
- **Make form errors persistent and field-specific.** Keep validation beside the relevant field and direct focus to the first invalid input instead of relying only on transient top messages.

### Medium

- **Unify typography roles.** Use Unbounded for display headings and Outfit for controls, body content, and filenames. Avoid shrinking labels with `FittedBox` to fit a fixed card.
- **Unify card and section spacing.** Use consistent internal padding and section separation; keep shadows and borders restrained so imagery and primary actions remain prominent.
- **Standardize selection states.** Pair color with a checkmark, selected control, or explicit state label.

## Impact area: onboarding and authentication

### High

- **Make onboarding usable at short heights and larger text sizes.** Ensure Skip, Login, Sign Up, and page controls remain visible and easy to tap.
- **Fix fixed-position authentication layouts.** Replace fragile percentage-height headers and translated form cards where they cause overlap or inaccessible content with the keyboard open.
- **Improve OTP entry.** Support system OTP autofill and whole-code paste. Verify focus progression, backspace behavior, and screen-reader labels across password reset and profile verification.

### Medium

- **Align onboarding to Figma.** Use a 20px medium-weight heading, 20px horizontal Login-button margins, and differentiated active/inactive page indicators. Confirm bottom safe-area spacing.
- **Resolve the login Save Password difference.** Figma shows this control; the current screen does not. Decide whether it is an intentional product change before updating UI.
- **Consolidate OTP visuals.** Forgot-password and profile OTP flows currently use different field heights. Adopt one reusable treatment after reviewing both reference states.

## Impact area: home and navigation

### High

- **Make visible header actions work.** The home header shows a notification icon without an action in the inspected implementation. Connect it to a supported screen or remove its tappable appearance until available.
- **Keep key content clear of bottom navigation.** Verify every primary tab can scroll its final content above the overlaid navigation and gradient.

### Medium

- **Align navigation wording with Figma.** Use “Book a Shoot” consistently and remove manual leading spaces used for positioning.
- **Clarify unavailable services.** Editing, Livestream, and Studios appear selectable but show a “Coming Soon” message. Label these as unavailable before tap and show a disabled visual state.
- **Prioritize returning-user tasks.** Place continuing a booking and active shoots where users can reach them quickly on the long home page.

### Low / product scope

- **Decide whether to restore Recent Project.** The Figma page includes it; the implementation marks it as planned and comments it out. Confirm product scope before building it.
- **Review Home service card typography.** Check small labels and card sizing across narrow widths; avoid reducing text below readable sizes to preserve a fixed grid.

## Impact area: booking journey

### High

- **Reconcile editing entitlements and pricing before changing displayed values.** The editing screen calculates included photos as `50 × hours`; the repository's pricing-alignment document describes service-specific allowances, and Figma examples differ. Confirm the source of truth with product/backend, then show the same entitlement and price through review and payment.
- **Restore the Figma review hierarchy with live data.** The current review screen shows a text summary, contact information, and pricing. The reference also includes the booking image and category, a schedule/location panel, package inclusions, selected crew, editing details, and included/total edit counts. Bring back the missing context using authoritative booking data.
- **Improve contact validation.** Show field-level errors for name, email, and phone; focus the first invalid field.
- **Make booking actions safe on compact screens.** Check the partner-selection footer, role counters, and matching controls together at short heights and enlarged text sizes.

### Medium

- **Review the Content Type first-step CTA.** The Figma uses a compact centered Continue button; the shared wizard footer expands it across the screen. Choose one deliberate mobile pattern and use it consistently.
- **Label optional Creative Brief inputs.** Mark additional details and inspiration as optional; explain how to enter multiple links.
- **Clarify multi-day schedules.** Group dates, times, duration, and location. Distinguish shared times from per-day times and display a clear total duration.
- **Place editing totals after edit options.** In the reviewed screen, both Photo and Video sections default open and the photo total appears before Video Edits. Align the default collapsed state and total placement with the chosen Figma state.
- **Clarify add-on cost units.** Keep item price, billing unit, selected quantity, and total easy to scan together.

### Product decisions to preserve until resolved

- **Wizard step count:** the repository documents 10 steps for Beige matching and 11 for manual selection, including payment success. Some Figma frames show a different denominator. Confirm which flow definition governs before changing progress labels.
- **Pricing and included services:** do not copy sample Figma prices, fees, setup promises, or photo counts without confirming the authoritative catalog and backend quote.
- **Deferred date:** do not imply a guaranteed date, duration, included-photo allowance, or payment amount where the booking is not scheduled.

## Impact area: checkout and payment outcomes

### High

- **Make “View Summary” open the paid booking.** The current action routes to My Shoots rather than the specific booking summary. Deep-link to that booking or rename the action to match its behavior.
- **Explain payment state accurately.** Show a clear confirming/pending state while backend verification runs; only show success after verified payment.
- **Provide a safe recovery path after payment failure.** Offer a retry or return-to-review path for the same booking and verify payment status before another attempt.

### Medium

- **Use an authoritative processing-fee label.** The review screen hardcodes “4%” while displaying a server-provided amount. Derive the rate from authoritative data or use a neutral fee label.
- **Make the pay CTA and final amount easy to compare.** Keep the amount visible near the primary payment action and preserve readable itemized pricing.

## Impact area: My Shoots and booking management

### High

- **Protect manage/cancel actions from safe-area and content overflow.** Bottom-aligned panels should handle long project names, larger text, and short screens without hiding actions.
- **Make the affected booking and cancellation consequence clear.** Show enough booking context before a destructive confirmation.

### Medium

- **Improve summary metadata readability.** Increase tiny date/time and status text and allow it to wrap when needed.
- **Keep the card's information hierarchy focused.** Prioritize project name, booking status, date, and Manage Shoot; use imagery as supporting content.
- **Resolve the unused filter clear action before exposing filters.** A Clear All callback is empty in the inspected implementation, but the filter appears hidden; do not treat it as a live broken control until the filter is enabled.

## Impact area: messages and chat

### Medium

- **Improve conversation-list scanning.** Figma uses larger avatars than the current 40px implementation. Review avatar size and move participant/time metadata so it competes less with conversation names.
- **Verify keyboard and long-message behavior.** Check composer, reply preview, search, failed-send feedback, and scrolling at small heights and larger text sizes.

### Low / product scope

- **Resolve Figma media actions.** The reference shows attachment, camera, and microphone controls; the inspected composer supports text and Send. Treat media actions as feature work requiring product approval, not cosmetic UI additions.

## Impact area: meetings

### High

- **Increase RSVP target size.** Accept and Reject visuals are 28px high; provide a touch target of at least 48px.

### Medium

- **Align Create Meeting CTA with the design system.** The Figma shows a 56px Unbounded-label button without a plus icon; the current shared button uses the default 48px Outfit treatment and includes a plus. Confirm the desired standard.
- **Use neutral success feedback for successful rejection.** A completed rejection should not look like an application error.
- **Protect long meeting details.** Keep title, date/time, status, and join action readable as participant information grows.

### Low / product scope

- **Keep the meeting filter hidden until the flow is approved.** Both implementation and Figma indicate the filter is currently hidden.

## Impact area: File Manager

### Medium

- **Use Outfit for folder and file names.** The inspected folder title uses an Unbounded-based style where Figma specifies Outfit semibold at 13px.
- **Increase opened-time metadata.** The implementation uses 12px while Figma specifies 14px.
- **Align tab type and selected color.** Figma uses 12px tab labels and a gold active label; the implementation uses 14px and white for active text. Choose a consistent, accessible treatment while preserving horizontal scrolling.
- **Review small file metadata.** Raise essential labels toward 12–14px and test long filenames, status chips, previews, and multi-select states.

## Impact area: profile, settings, and account deletion

### High

- **Keep profile edit actions reachable.** Add safe-area-aware bottom actions and verify with enlarged text and a keyboard.
- **Separate account-deletion preview from a completed operation.** The inspected success screen includes a placeholder deletion date and success language, while code comments say the backend contract is pending. Keep preview messaging clear until the server confirms request submission and supplies the actual date.

### Medium

- **Enlarge profile back-button targets.** Do not make the 24px icon the entire interactive region.
- **Make App Preferences scroll at larger text sizes.** Verify the page on short screens.

### Low / product scope

- **Confirm profile menu scope against Figma.** Figma shows Payment Methods, Help & Support, and Notification Settings; the inspected menu omits these and includes a timezone row. Confirm intended release scope before adding or removing destinations.

## Impact area: screen coverage and device QA

These areas need a rendered customer-build comparison before they can be considered visually verified:

- Splash and second onboarding page; signup, reset password, and OTP states.
- Location search, permission states, and native map screens.
- Creative profiles, portfolio, reviews, feedback, and notification screens.
- Booking date/time variants, deferred scheduling, matching, empty results, and crew selection.
- Add-ons, review, WebView checkout, pending verification, and payment failure.
- My Shoots summaries, timelines, rescheduling, and cancellation states.
- File browsing, nested folders, previews, sharing, revision, and selection states.
- Meeting create/edit, details, participant selection, and RSVP variants.
- Global loading, empty, error, offline, missing-image, and expired-session states.

Figma contains customer notification, notification-preference, feedback, and review/filter screens whose matching destinations were not identified in the inspected routing. Treat these as scope/mapping questions until route coverage is confirmed.

## Suggested delivery order

1. **High — mobile fundamentals:** text scaling, contrast, touch targets, safe areas, field-level errors, and short-screen layouts.
2. **High — booking and payment confidence:** authoritative edit entitlements, complete booking review, correct summary destination, and verified payment states.
3. **Medium — shared visual consistency:** buttons, type hierarchy, spacing, selected states, and feedback.
4. **Medium — screen-specific refinement:** onboarding, home/navigation, My Shoots, chat, meetings, File Manager, and profile.
5. **Low — product scope:** media messaging, Recent Project, profile destinations, and deferred screens.

## Acceptance criteria

- System text scaling is respected; important text and controls remain visible and actionable.
- Interactive targets are at least 48×48 logical pixels where practical.
- Primary actions respect safe areas and remain reachable with the keyboard open.
- Booking entitlements, fees, and payment status use confirmed authoritative values.
- Core screens are reviewed at 320, 360, 375, 390, and 430 logical-pixel widths, including enlarged text, long content, and loading/error/empty states.
- Figma-alignment work preserves approved product behavior and existing booking-flow decisions.
