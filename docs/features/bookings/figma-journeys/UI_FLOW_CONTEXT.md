# Beige booking — UI flow context

Inspected on 2026-10-08. Source: [New Booking Flow V1 — Updated on 07/10/2026](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=7343-65455&m=dev), page `7343:9965`, section `7343:65455`.

The browser fetch could not open the file; the connected Figma tools supplied the frame structure, visible text and original screen exports. This is a design reference and proposed development flow, not a report that the app already implements it. Order is based on the named Figma steps and the user's branch requirement; prototype interactions were not verified.

Pricing alignment added on 2026-10-08: [Mobile Pricing Alignment](MOBILE_PRICING_ALIGNMENT.md) records the supplied [pricing document](https://docs.google.com/document/d/16-hWefO6nCvPSmhnovPhlX00fx25D-8QoY_YdgALYBE/edit?tab=t.0#heading=h.q9s9xsizhwjw). Its catalog and inclusions take precedence over Figma sample values. **Studios are excluded from this mobile scope.** Original screen exports remain unchanged, including any obsolete text or example prices.

## Four journey folders

| Journey | Images and visual index | How to follow it |
| --- | --- | --- |
| 1. With Date | [Open gallery](01-with-date/index.html) | Steps 1–11 show a dated booking with manual partner selection. Step 3 has single-day and multi-day variants. The alternative at step 5 skips partner selection for Beige matching. |
| 2. Choose Date Later | [Open gallery](02-choose-date-later/index.html) | Steps 1–11 show deferred scheduling with manual partner selection. Replace the step-3 date form with location only. The alternative at step 5 skips partner selection for Beige matching. |
| 3. Let Beige Match Me | [Open gallery](03-let-beige-match-me/index.html) | 10 primary steps; skip partner search and selection. Both date options are included as step-3 variants. |
| 4. Choose My Creative Partner | [Open gallery](04-choose-my-creative-partner/index.html) | 11 primary steps; includes partner selection. Both date options are included as step-3 variants. |

These are two independent decisions, not four mutually exclusive options: date now/later × Beige match/manual partner selection. The first two folders illustrate the manual branch as their main sequence and include the matching alternative. The last two illustrate date-now as their main sequence and include date-later alternatives. Shared screens are copied into each folder so each journey is self-contained.

`01-`, `02-`, etc. identify primary steps. Letter suffixes identify alternative states within a step, not additional steps. `state-` files are exception states; `post-` files follow completion. Each gallery separates these groups. [screen-manifest.json](screen-manifest.json) maps every image to its exact Figma node and dimensions. PNGs are original exports; their badges and sample content have not been edited.

## Counting convention and Figma mismatch

The user requested 10 steps for Beige matching and 11 for manual selection. This reference achieves those totals by counting **payment success as the final primary step**. The date-choice bottom sheet is part of step 3. Search loading, profile inspection, errors and the post-payment summary are supporting states.

Figma itself labels the manual journey 1/10 through 10/10, ending at Review & Confirm; it does not number payment success. Removing manual selection therefore gives 9 wizard forms plus success, versus 10 wizard forms plus success for manual selection. Some deferred-date and no-partner frames still show `2/3`.

This counting convention is an interpretation, not an extra form discovered in Figma. If 10/11 must mean input screens before success, another step must be specified. Do not silently invent one. Implement progress from the active route list after deciding whether the denominator includes the success screen; do not copy stale screenshot badges.

## Shared step details

| Step | Screen / action | Figma node | Development context |
| --- | --- | --- | --- |
| 1 | Content Type | `7343:65551` | Choose Videography, Photography or both through Select All. Studios are excluded from mobile scope. Editing Only and Livestreaming remain outside this active flow. Empty state: `7343:65494`. |
| 2 | Shoot Type | `7343:69157` | Select event category: Wedding, Music Video, Conference, Corporate Event, Private Event, Birthday Party, Funeral / Memorial, Real Estate, Product or Others. Others refers to project description. |
| 3 | When & Where | See date branches below | Choose date now/later, then collect the applicable schedule and location. Date variants belong to this one logical step. |
| 4 | How do you want to Beige it? | `7343:65730` | Add inspiration/reference links and additional details. Required-field behavior is not specified in the source. |
| 5 | Who shoots your event? | `7343:69005` / `12820:7282` | Choose Let Beige Match Me or Choose my Creative Partner. Show included package information. This decision controls whether the partner-selection step exists later. |
| 6 | Your Creative Team | `7343:67364` | Photography and videography cost $250/hour each; one-person hybrid coverage costs $375/hour. Show recommendation and coverage explanation in BOTH partner modes. Additional-crew and mixed-crew pricing are not defined by the supplied document. |
| 7 | Want Beige to edit it? | `13348:4100` | Photography includes 25 edited photos/hour; hybrid includes 10/hour. Extra sets of 25 cost $250 and default to zero. Show paid video-edit catalog prices. The Yes/No control must not silently remove free inclusions; its exact semantics need clarification. Separate video-edit options group: `13519:3159`. |

## 1. With Date — step by step

1. Select content type.
2. Select shoot type.
3. Open When & Where → **I have a date** (`12815:5106`) → provide date(s), times and location.
4. Add inspiration and additional details.
5. Choose who shoots the event.
6. Configure the creative team.
7. Choose editing options.
8. **Manual selection only:** search and select creative partners.
9. Choose optional add-ons.
10. Review details, enter contact information and pay.
11. Payment success → optionally view the booking summary.

For **Let Beige Match Me**, omit item 8 entirely; items 9–11 become steps 8–10.

Step-3 variants:

- Single day: date, start time, end time and location. Empty form `7343:65680`; selected form `7343:69081`.
- Multiple days / same time: select dates, choose Yes for shared timing, apply the time range to all dates (`7356:1912`). Show selected-day count and duration per day.
- Multiple days / different times: select dates, choose No, edit start/end time for each date (`7365:4304`). Show per-day durations.
- Location includes a current-location option in the selected designs. Permission-denied and location-search behavior are not specified by this section.

## 2. Choose Date Later — step by step

1. Select content type.
2. Select shoot type.
3. Open When & Where → **I'll confirm later** (`12815:5260`, “Hold my spot for 30 days”) → provide location only (`12815:5353`). The location screen says to finalize date/time later with the Beige team.
4. Add inspiration and additional details.
5. Choose who shoots the event.
6. Configure the creative team.
7. Choose editing options.
8. **Manual selection only:** select creative partners, subject to unresolved availability rules below.
9. Choose optional add-ons.
10. Review and pay, subject to deferred-price and confirmation rules below.
11. Payment success / production secured; final date and time remain pending.

For **Let Beige Match Me**, omit item 8; items 9–11 become steps 8–10.

Only the date-choice and location-only screens have explicit deferred-date designs in this section. Later screens reuse the shared flow as a development interpretation; the exported review, editing and success examples still contain dated-booking data. Do not display those example dates or confirmed-schedule copy for a deferred booking.

## 3. Let Beige Match Me — 10 steps

| Step | Screen | Image |
| --- | --- | --- |
| 1 | Content Type | [Image](03-let-beige-match-me/01-content-type.png) |
| 2 | Shoot Type | [Image](03-let-beige-match-me/02-shoot-type.png) |
| 3 | Date/time/location OR choose date later + location | [Date-now image](03-let-beige-match-me/03-date-time-location.png), [date-later image](03-let-beige-match-me/03b-date-later-location-only.png) |
| 4 | Inspiration and additional details | [Image](03-let-beige-match-me/04-inspiration-and-details.png) |
| 5 | Let Beige Match Me selected | [Image](03-let-beige-match-me/05-let-beige-match-me.png) |
| 6 | Your Creative Team | [Image](03-let-beige-match-me/06-your-creative-team.png) |
| 7 | Editing | [Image](03-let-beige-match-me/07-editing.png) |
| 8 | Optional add-ons | [Image](03-let-beige-match-me/08-optional-add-ons.png) |
| 9 | Review, contact information and pay | [Image](03-let-beige-match-me/09-review-confirm-and-pay.png) |
| 10 | Payment success | [Image](03-let-beige-match-me/10-payment-success.png) |

**Required branch rule:** Continue from editing goes directly to add-ons. Do not show “Finding The Perfect Creative For You,” Select Your Dream Team, partner-profile selection or the no-partner-found screen in this path. Beige handles assignment; no manually selected partner IDs should be required to continue. The creative-team role/quantity step remains.

## 4. Choose My Creative Partner — 11 steps

| Step | Screen | Image |
| --- | --- | --- |
| 1 | Content Type | [Image](04-choose-my-creative-partner/01-content-type.png) |
| 2 | Shoot Type | [Image](04-choose-my-creative-partner/02-shoot-type.png) |
| 3 | Date/time/location OR choose date later + location | [Date-now image](04-choose-my-creative-partner/03-date-time-location.png), [date-later image](04-choose-my-creative-partner/03b-date-later-location-only.png) |
| 4 | Inspiration and additional details | [Image](04-choose-my-creative-partner/04-inspiration-and-details.png) |
| 5 | Choose my Creative Partner selected | [Image](04-choose-my-creative-partner/05-choose-my-creative-partner.png) |
| 6 | Your Creative Team | [Image](04-choose-my-creative-partner/06-your-creative-team.png) |
| 7 | Editing | [Image](04-choose-my-creative-partner/07-editing.png) |
| 8 | Search and select creative partners | [Selected](04-choose-my-creative-partner/08-select-creative-partners.png), [empty selection](04-choose-my-creative-partner/08b-partners-unselected.png) |
| 9 | Optional add-ons | [Image](04-choose-my-creative-partner/09-optional-add-ons.png) |
| 10 | Review, contact information and pay | [Image](04-choose-my-creative-partner/10-review-confirm-and-pay.png) |
| 11 | Payment success | [Image](04-choose-my-creative-partner/11-payment-success.png) |

Step 8 contains a search-loading transition (`7343:69228`), partner list (`7343:69236`), selected-list state (`7343:69483`) and optional profile view (`7343:70002`). Users add/remove crew and see selected-role counts. Profile content includes portfolio, team, reviews and weekly availability. Returning from a profile should preserve the selection. These states do not add numbered steps.

No partners available: `7343:69374` offers browsing other partners or Connect With Sales. Sales acknowledgement: `7343:70202`. A sales request is not a paid booking success.

## Add-ons, review and terminal states

- Optional add-ons (`12820:27140`): Additional Camera, Teleprompter, Drone, Lavalier Microphones, Green Screen, Backdrop, Additional Lights and expedited editing choices. Show quantities and subtotal. “Optional” means zero add-ons is a valid proposed flow.
- Review (`7343:69621`): shoot summary, Full Name, Email ID and Phone Number; package/editing information; pricing and final Pay CTA. Use the [aligned catalog](MOBILE_PRICING_ALIGNMENT.md), itemize included photos at $0 and show paid editing/add-ons separately. Figma's sample pre-production/rush fees and card charge are not validated by the pricing document.
- Payment success (`7343:69800`) → View Summary → Booking Summary Details (`7633:4956`) → Back to Home.
- Payment failure (`13276:2869`) → Back to Home. The design supplies no retry screen.
- Login required (`9085:5251`) is an auxiliary popup with Ok/Cancel. Its exact trigger is not established by this inspection; it is not an extra wizard step.
- The linked section does not contain a separate payment-provider form. Review's Pay action and payment processing are grouped within the review step here.

## Suggested development state and navigation

Keep independent fields for `scheduleMode = dated | deferred` and `partnerMode = beigeMatch | manual`. These are proposed domain names, not verified API parameter names.

Preserve content type, shoot category, inspiration/details, location, date/time entries when applicable, crew role quantities, editing choices, add-ons and contact information in the booking draft. Persist selected partner IDs only for the manual mode. On switching to Beige matching, clear or ignore manual selections in submission and review. On changing schedule, location or required crew, revalidate manual selections before payment.

Build an ordered route list from partner mode:

```text
Common: Content → Shoot type → Schedule/location → Inspiration → Partner mode
        → Team quantities → Editing

Beige match: → Add-ons → Review/pay → Success
Manual:     → Partner selection → Add-ons → Review/pay → Success

Schedule/location:
  dated    → Single day OR Multiple days (same OR individual times) + location
  deferred → Location only
```

Back navigation follows the active list and preserves entered values. A search/profile return must not duplicate wizard steps. Payment failure must not be treated as success. Do not fabricate dates for a deferred booking.

The existing [code-based booking flow reference](../book_a_shoot_flow_reference.md) describes an older consolidated flow and existing route names. Use it for implementation orientation, not to override this Figma reference. The current code reference groups several new screens into ShootDateTime/ShootDetails and describes a search route after crew matching. A future implementation must split these responsibilities and guard the search route by partner mode. No application code was changed for this export task.

## Unresolved source details before implementation

1. **Deferred pricing and editing:** hourly rates and photo allowances are now confirmed, but duration is absent. Neither the pricing document nor deferred-date frames define deposit/package duration, final pricing or payment timing for this branch.
2. **Deferred manual selection:** no date-specific availability can be guaranteed. The design does not define whether selections are preferences, provisional reservations or blocked until scheduling.
3. **30-day hold:** copy mentions a hold, but expiry behavior, reminders, refund rules and the later scheduling journey are not supplied here.
4. **Confirmation copy:** dated success says the shoot is confirmed; the Beige-match choice says the team will ensure everything works before confirming. Payment success, schedule confirmation and partner assignment need separate statuses/copy.
5. **Progress totals:** the 10/11 delivery convention includes success; Figma's form badges do not. Resolve this before coding header counts.
6. **Pricing gaps:** additional-crew charging, mixed-crew photo allowances, fractional-hour rounding, fees/tax and Editing Yes/No semantics remain unspecified. See [Mobile Pricing Alignment](MOBILE_PRICING_ALIGNMENT.md). Setup wording is resolved to **up to 1 hour** by the pricing document; extra photo sets cost **$250 per 25**, default zero. “Expedited Editing (1 Week)” should not use Figma's conflicting 72-hour description.

## Implementation acceptance cases

- Exercise all four combinations: dated + match, deferred + match, dated + manual, deferred + manual.
- Match mode never enters search, partner list or profile selection; after editing it opens add-ons.
- Manual mode supports loading, empty/selected lists, profile return and the sales fallback.
- Single-day, shared-time multi-day and per-day-time multi-day preserve correct date/time state when going Back.
- Deferred mode requires the designed location field and carries no fabricated date/time into review or confirmation.
- Numbered sequence has 10/11 steps under this document's convention; alternative states never increment it.
- Review reflects the chosen mode, crew, editing and add-ons; final amounts come from confirmed backend rules.
- Four photography hours include 100 edited photos at $0; eight hybrid hours include 80. One extra set adds 25 photos and $250. Do not multiply included allowances by crew quantity without an approved rule.
- Exclude Studios and Sales-only custom pricing fields from this mobile flow. Use the one-hour setup allowance consistently.
- Payment success opens summary; failure and sales acknowledgement cannot mark a booking paid.
