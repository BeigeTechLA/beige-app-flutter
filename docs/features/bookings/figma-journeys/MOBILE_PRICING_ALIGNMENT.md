# Beige mobile booking — pricing alignment

Checked on 2026-10-08 against the [pricing document](https://docs.google.com/document/d/16-hWefO6nCvPSmhnovPhlX00fx25D-8QoY_YdgALYBE/edit?tab=t.0#heading=h.q9s9xsizhwjw), retrieved through Google Docs' text export. Applies to the [UI flow summary](UI_FLOW_SUMMARY.md) and [detailed context](UI_FLOW_CONTEXT.md).

Use the supplied pricing document for catalog prices and inclusions instead of sample Figma values. Use Figma for screen structure and the user's instructions for branch behavior. This alignment documents the mobile booking flow; it does not change app code, backend prices, Figma images or the Google document.

## Mobile scope

- Active booking services: Photography, Videography and combined photo/video coverage.
- **Studios are excluded**, per the user's instruction. Do not add a studio route or studio pricing to this mobile flow.
- Selecting both content types does not automatically mean one hybrid partner. The $375/hour option is specifically one person covering both, described as a special low-budget case. Separate dedicated roles must remain distinguishable.
- The document also lists livestream coverage, consultation and a separate Editing Only flow. This alignment does not activate them: the inspected booking designs mark livestreaming and Editing Only as Coming Soon and do not establish a consultation journey.
- Custom line items belong to the Sales Proposal Builder for exceptional cases. Do not expose a customer-entered custom-price field in mobile checkout.

## Service rates

| Service | Document rate | Included edited photos |
| --- | --- | --- |
| Photography | $250/hour | 25 per photography hour, at no extra charge |
| Videography | $250/hour | No photo allowance specified |
| Videography + Photography, one hybrid partner | $375/hour | 10 per hybrid booking hour, at no extra charge |

For a single service with billable duration `H`: photography or videography service cost is `250 × H`; hybrid service cost is `375 × H`.

For multiple dates, the proposed mobile calculation sums each day's duration before applying hourly pricing; this is an interpretation of hourly rates and the multi-day UI. Minimum duration, rounding, breaks, overtime and date-specific adjustments are not specified. Additional-crew pricing and whether photo allowances multiply by crew count are also not specified. Do not silently multiply by crew quantity or treat every additional person as free.

The document defines no price difference between Beige matching and manual partner selection. Use the same catalog in both branches unless another approved pricing rule applies. Profile teaser rates in Figma do not establish a partner-specific pricing rule.

## Editing catalog

| Deliverable | Price |
| --- | --- |
| Highlight Video, 4–7 minutes | $350 |
| Feature Video, 10–20 minutes | $500 |
| Full Feature Video, 30–40 minutes | $500 |
| Reel, 10–60 seconds | $250 |
| Interview Video, 1–5 minutes | $350 |
| Music Video Edit | $500 |
| Extra edited photos, set of 25 | $250 per set |

Feature and Full Feature intentionally retain the same $500 price from the document. Do not infer a higher price for the longer deliverable.

For supported deliverable quantities, calculate `quantity × catalog price`. The UI can filter photo/video options by selected service; the document does not specify every compatibility or quantity limit.

### Included and extra photos

```text
Photography included photos = photography hours × 25
Hybrid included photos      = hybrid hours × 10
Extra photos                = extra sets × 25
Extra-photo charge          = extra sets × $250
Total edited photos         = included photos + extra photos
```

Apply the included-photo formula for the chosen service; do not add both allowances to a single hybrid booking. Mixed crews and fractional-hour photo rounding require clarification.

Default extra sets to **0**. Display the included count, the duration it comes from, the $250 price beside the stepper, the resulting total photo count and the editing charge. Do not treat the free included allowance as a paid add-on. The source automatically grants included photos; the Figma Editing Yes/No control must not silently remove that entitlement. Exact toggle semantics remain unresolved.

An aligned hybrid example:

```text
Photo edits
Included: 80 edited photos
Included with your 8-hour booking

Want more edited photos?
[ − ]  0 extra sets  [ + ]    $250 per set of 25

You'll receive 80 edited photos
Extra-photo charge: $0

After adding one set:
You'll receive 105 edited photos
Extra edits: 1 set × 25 photos — $250
```

The source's 80-photo / 8-hour example matches the hybrid rule. Standard photography for 8 hours includes **200**, not 80. Suggested quick-select options can offer Included, +25 ($250), +50 ($500), or the custom quantity stepper. These are optional UI suggestions, not required new steps.

## Included package items

The document lists the same inclusions for photography, videography and combined coverage:

- $1M liability insurance.
- Beige's content satisfaction guarantee.
- A vetted Creative Partner.
- Professional lighting and essential production equipment.
- Digital delivery of raw files through Beige.
- Up to **1 hour** of setup time.
- Two complimentary revision rounds.

Use the one-hour setup allowance throughout the mobile UI. The 45-minute wording in a Figma package card conflicts with the document. Whether setup time changes billable shoot duration is not specified; do not subtract it automatically.

## Optional add-ons

| Add-on | Document price |
| --- | --- |
| Additional Camera | $350 |
| Teleprompter | $250 |
| Drone | $500 |
| Additional Lavalier Microphones | $250 |
| Green Screen | $500 |
| Backdrop | $500 |
| Additional Lights | $350 |
| Next-Day Editing | $750 per video |
| Expedited Editing, 1 Week | $500 |

These are fixed catalog prices, not hourly prices. Next-Day Editing is explicitly per video. Per-day charging for multi-day equipment, multiple-unit rules and the unit for one-week expedited editing are not defined. Keep those assumptions out of the final quote until confirmed. Do not carry over the Figma “72-hour turnaround” description for the item named “1 Week”; the source identifies it as one week.

## Where pricing belongs in the mobile flow

| UI step | Pricing responsibility |
| --- | --- |
| 1. Content Type | Establish eligible service options; distinguish combined coverage from one-person hybrid coverage. |
| 2. Shoot Type | Select the category. No category surcharge is specified by this pricing document. It also lists Brand / Promotional, which is absent from the inspected Figma list; reconcile the mobile category catalog. |
| 3. When & Where | For dated bookings, derive duration from selected date/time ranges. Deferred mode has no duration in the supplied design. |
| 5. Partner Preference | Choose assignment mode; no matching/manual price modifier is supplied. |
| 6. Your Creative Team | Show $250/hour photography/video and $375/hour hybrid rates. Additional-crew rules need confirmation. |
| 7. Editing | Calculate included photos, default extras to zero, show item prices and editing subtotal. Source wording says hours are selected on the “first page”; in this mobile flow they originate at step 3. |
| 8 manual only. Select Partners | Preserve the chosen service/crew context; no partner-specific surcharge is established here. Beige matching skips this screen. |
| 8 match / 9 manual. Add-ons | Show applicable catalog prices and add-on subtotal. |
| 9 match / 10 manual. Review & Pay | Itemize service, included photo allowance at $0, paid editing, and add-ons; reconcile against the backend quote before payment. |
| 10 match / 11 manual. Success | Show confirmed payment outcome, with summary reflecting the actual paid quote. |

Known catalog subtotal is service cost + paid editing + optional add-ons. It is **not necessarily the final payable amount**. The document does not define tax, pre-production fees, rush-order fees, card-processing percentage, discounts or deposits. Figma's $250 fees and 4% card charge are not validated by this source. Existing backend rules, if any, need reconciliation; do not remove or invent fees based only on this document.

## Calculation examples

These examples use one partner, whole hours, no fees/tax and no unspecified crew or multi-day rules. They demonstrate catalog subtotals, not complete checkout quotes.

| Example | Service | Included photos | Paid editing | Add-ons | Catalog subtotal |
| --- | --- | --- | --- | --- | --- |
| 4-hour photography, no extras | 4 × $250 = $1,000 | 100 | $0 | $0 | $1,000 |
| 4-hour photography, 1 extra photo set | $1,000 | 100; 125 total | $250 | $0 | $1,250 |
| 8-hour hybrid, 1 extra photo set | 8 × $375 = $3,000 | 80; 105 total | $250 | $0 | $3,250 |
| 4-hour video, highlight edit, additional camera | 4 × $250 = $1,000 | Not specified | $350 | $350 | $1,700 |

## Rules still missing from the source

1. **Choose Date Later:** no booking duration, hold/deposit price, payment timing or included-photo calculation is defined. Do not assume a four-hour package, zero-dollar service or a fixed payment merely to complete the flow.
2. **Additional and mixed crews:** per-person charging, included crew allocation and photo allowance aggregation are not defined. Selecting two content types is not enough to identify the correct service configuration.
3. **Billing precision:** minimum hours, fractional rounding, breaks, overtime and multi-day charging details are unspecified.
4. **Fees and tax:** final quote rules beyond the catalog are missing.
5. **Editing toggle:** included photos are automatic, but the relation between Figma's Yes/No and paid editing needs definition.
6. **Deferred partner selection:** date-dependent availability and reservation guarantees remain undefined.

The existing 10/11 counting convention and partner-selection branching are unchanged. These unresolved rules should be settled before implementing production checkout, but do not prevent using the confirmed catalog and inclusion rules in development references.
