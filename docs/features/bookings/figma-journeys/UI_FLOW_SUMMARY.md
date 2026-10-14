# Beige Booking — UI Flow Summary

This is one booking journey with two independent choices:

- **Scheduling:** I have a date or I'll confirm later.
- **Partner selection:** Let Beige Match Me or Choose My Creative Partner.

Either scheduling option can work with either partner-selection option. This gives four combinations: date now + Beige matching, date later + Beige matching, date now + manual selection, and date later + manual selection.

Pricing was aligned on 2026-10-08 with the supplied [pricing document](https://docs.google.com/document/d/16-hWefO6nCvPSmhnovPhlX00fx25D-8QoY_YdgALYBE/edit?tab=t.0#heading=h.q9s9xsizhwjw). Scope is the mobile booking app; **Studios are excluded**. See [Mobile Pricing Alignment](MOBILE_PRICING_ALIGNMENT.md) for the full catalog and calculation boundaries.

## Shared journey

| Step | Screen | User action |
| --- | --- | --- |
| 1 | Content Type | Select Photography, Videography or both. |
| 2 | Shoot Type | Select Wedding, Corporate Event, Product or another shoot category. |
| 3 | When & Where | Provide dates, times and location, or choose date later and provide location only. |
| 4 | Creative Brief | Add inspiration links and additional details. |
| 5 | Partner Preference | Choose Let Beige Match Me or Choose My Creative Partner. |
| 6 | Your Creative Team | Configure photography/video coverage ($250/hour each service) or one hybrid partner ($375/hour). Additional-crew pricing needs confirmation. |
| 7 | Editing | Show free included photos, choose paid editing and optionally add extra photo sets at $250 per 25. Default extras to zero. |

## UI flow

```text
Book a Shoot
    ↓
1. Content Type
    ↓
2. Shoot Type
    ↓
3. When & Where
    ├── I have a date
    │     ├── Single day → Date + start/end time
    │     └── Multiple days
    │           ├── Same timing for all dates
    │           └── Individual timing for each date
    │     → Location
    │
    └── I'll confirm later
          → Location only; date/time remain pending
    ↓
4. Creative Brief
    ↓
5. Partner Preference
    → Save Beige matching or manual selection
    ↓
6. Your Creative Team
    ↓
7. Editing
    ↓
    ├── Let Beige Match Me
    │     → Skip partner search and selection
    │     → 8. Optional Add-ons
    │     → 9. Review & Pay
    │     → 10. Payment Success
    │
    └── Choose My Creative Partner
          → 8. Search & Select Creative Partners
               → Browse profiles, add/remove partners
          → 9. Optional Add-ons
          → 10. Review & Pay
          → 11. Payment Success
    ↓
View Booking Summary
    ↓
Back to Home
```

## Scheduling options

### With Date

Users provide the shoot location and either:

- One date with start and end times.
- Multiple dates with the same time range for every day.
- Multiple dates with individual start and end times for each day.

### Choose Date Later

Users provide only the location. The Beige team helps finalize the date and time later. The design mentions holding the spot for 30 days.

The later shared screens are interpreted as continuing the same journey; dedicated deferred-date review and success variants are not supplied in the inspected section.

## Partner-selection options

| Let Beige Match Me — 10 steps | Choose My Creative Partner — 11 steps |
| --- | --- |
| Shared steps 1–7 | Shared steps 1–7 |
| Skip partner search and selection | 8. Search, inspect profiles and select partners |
| 8. Optional Add-ons | 9. Optional Add-ons |
| 9. Review & Pay | 10. Review & Pay |
| 10. Payment Success | 11. Payment Success |

**Beige matching still includes creative-team quantities and editing.** It removes the manual partner-search loader, partner list and profile-selection experience. After editing, users go directly to optional add-ons.

Manual selection includes loading, browsing profiles, adding/removing partners and confirming the selected team. These are states within the partner-selection step, not additional numbered steps.

## Supporting outcomes

- **Payment success:** Users can open their booking summary and return home.
- **Payment failure:** Show the failure screen with Back to Home.
- **No partners available:** The manual-selection journey offers a sales-contact fallback.
- **Sales request received:** Acknowledge the request; this is not a paid booking confirmation.

## Details still needing clarification

1. **Deferred pricing and editing:** How are price and included edits calculated when the shoot date and duration are unknown?
2. **Deferred partner availability:** Are manually selected partners provisional preferences until the date is confirmed?
3. **Step counts:** The 10/11 totals in this summary include payment success. Figma currently numbers the manual forms through Review & Confirm as 10/10 and leaves success unnumbered. If 10/11 must count only forms before success, an additional step needs to be specified.
4. **Quote details:** Additional-crew pricing, mixed-crew photo allowances, duration rounding, fees/tax and the Editing Yes/No behavior are not fully defined by the pricing document.

## Pricing understanding

- Photography and Videography are each **$250/hour**. One person doing both is **$375/hour**, a special hybrid option; selecting both content types does not automatically select it.
- Photography includes **25 edited photos per hour**. Hybrid coverage includes **10 edited photos per hour**. These are free inclusions.
- Extra photo edits cost **$250 per set of 25**, defaulting to **0 extra sets**. Show the unit price, included count, extra count and total clearly.
- Paid video edits have fixed catalog prices; equipment and expedited-editing add-ons have their own listed prices. See the [complete pricing tables](MOBILE_PRICING_ALIGNMENT.md).
- Packages include **up to 1 hour of setup**, replacing the conflicting 45-minute Figma wording.
- Both partner-selection branches use the same documented catalog. No matching/manual price difference is specified.
- Review should itemize service cost, included photos at $0, paid editing and add-ons. The document does not validate Figma's extra fees or establish the final tax/payment calculation.
- Sales Proposal Builder custom line items are not part of mobile self-service checkout.

## Related references

- [Detailed UI flow context](UI_FLOW_CONTEXT.md)
- [Mobile pricing alignment](MOBILE_PRICING_ALIGNMENT.md)
- [With Date — image gallery](01-with-date/index.html)
- [Choose Date Later — image gallery](02-choose-date-later/index.html)
- [Let Beige Match Me — image gallery](03-let-beige-match-me/index.html)
- [Choose My Creative Partner — image gallery](04-choose-my-creative-partner/index.html)
- [Source Figma section](https://www.figma.com/design/P0Loe0Kc4jWEIUBrXGQ6wp/Beige-App-Design?node-id=7343-65455&m=dev)
