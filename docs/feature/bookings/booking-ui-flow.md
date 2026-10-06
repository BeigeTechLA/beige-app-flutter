# Booking v4 — UI flow explanation

This document describes the currently implemented booking UI. The flow is a screen-by-screen wizard grouped into three stages, with a back button, a stage progress indicator, and a Continue button on each step.

## Entry points

| Entry point | Current destination |
|---|---|
| Bottom **Book Shoot** tab | New v4 flow |
| Home **Book Shoot** promo | New v4 flow |
| Home Photography/Videography service cards | Legacy booking flow |
| Home **Continue Booking** | Legacy resume screens |

To access v4, start from the bottom **Book Shoot** tab. Its first screen looks similar to the old flow; the scheduling, matching, crew count, editing, and add-on steps follow it.

## Stage 1 — Create Project · 1/3

| Screen | User interaction |
|---|---|
| Content selection | Select Photography, Videography, or both. Editing Only, Studios, and Livestreaming are disabled as “Coming Soon.” |
| Shoot type | Choose a shoot type from the backend catalogue. |
| When & Where | Choose **I have a date** or **I’ll confirm later** in a bottom sheet, then complete the corresponding inputs. |

The scheduling choice changes the inputs:

- **I have a date:** select a date, start time, end time, and location.
- **I’ll confirm later:** select a location without entering a date or time.

Both choices continue to Additional Details. The schedule also carries the resolved timezone.

## Stage 2 — More Details · 2/3

| Screen | User interaction |
|---|---|
| Additional details | Enter shoot notes and reference links. |
| Matching choice | Choose **Let Beige Match Me** or **Choose My Creative Partner**. |
| Crew count | Set the number of creatives required for each role. |
| Editing | Choose whether edits are needed. If yes, select editing options. |
| Creator selection | Manual matching only: browse and select creatives, with an option for Beige to fill remaining roles. |
| Optional add-ons | Select extras and their quantities, or continue without them. |

The matching choice controls whether the creator-selection screen appears:

- **Let Beige Match Me:** Editing → Add-ons.
- **Choose My Creative Partner:** Editing → Creator selection → Add-ons.

Schedule choice and matching choice are independent. A user who selects **I’ll confirm later** can still choose creatives manually. Selecting creatives does not itself reserve their availability.

In the current header implementation, Add-ons remains in **More Details · 2/3**. Stage 3 begins at Review & Contact.

## Stage 3 — Book & Confirm · 3/3

| Screen or sheet | User interaction |
|---|---|
| Review & contact | Review booking details and enter full name, email, and phone. This screen does not display the final pricing receipt. |
| Confirm & Pay | View backend-provided pricing, editing information, fees, and the total amount. |
| Payment method sheet | Choose Stripe or Commas. |
| Payment interface | Complete payment through Stripe’s native sheet or Commas’ embedded checkout. |
| Payment verification | Wait while the app checks payment status with the backend. |
| Confirmation | View the booking summary and tap **Go to My Shoots**. |

Continuing from Review & Contact saves the quote before opening Confirm & Pay. After the user chooses a payment method, the app submits the booking and requests a payment session for that provider.

Payment handling includes these UI states:

- **Processing:** an overlay indicates that payment is being submitted or verified.
- **Pending verification:** the user can check again or go to My Shoots.
- **Failure:** a sheet offers retry or a change of payment method.
- **Cancellation:** dismissing checkout returns to the payment screen.
- **Verified payment:** the normal payment path navigates to booking confirmation.

## Complete screen sequence

1. Content selection
2. Shoot type
3. When & Where — scheduled date/time/location or deferred location
4. Additional details and reference links
5. Matching choice
6. Crew count
7. Editing options
8. Creator selection — manual matching only
9. Optional add-ons
10. Review & contact
11. Confirm & Pay
12. Payment method selection and checkout
13. Payment verification
14. Booking confirmation → My Shoots

These sequence numbers explain the journey; the UI displays the three stage numbers rather than a separate counter for every screen.

## How the UI is connected

- The v4 screens live in `lib/features/booking/presentation/screens/v4/`.
- Routes are registered in `lib/app/router.dart`, with names in `lib/app/route_names.dart`.
- `BookingFlowController` holds the booking ID, schedule, matching branch, crew counts, editing choices, creator selections, add-ons, and contact details across screens.
- Step-specific providers under `lib/features/booking/presentation/providers/v4/` handle saves and backend loading.
- Most Continue buttons save the step successfully before pushing the next screen. Matching choice and creator selections are maintained locally for later submission.
- `BookingStepHeader` maps individual screens to the three visible stages. Its progress indicator represents the stage, not a precise percentage of completed screens.

## Known integration gaps from the implementation review

The sequence above describes the implemented UI, but the following issues remain:

1. **Mixed entry points:** Home service cards and Continue Booking still lead into legacy screens.
2. **Commas navigation:** the gateway passes a URL string as route extras, while the checkout route expects a map containing `checkoutUrl`. This causes a type error when opening checkout.
3. **New-booking reset:** successful payment clears persisted draft data but leaves the shared flow state and booking ID in memory. Starting another booking can reuse the completed booking ID.
4. **Cold-start restoration:** draft hydration and prerequisite guards exist but are not wired into the running flow. A restored v4 route can open with an empty controller.
5. **Confirmation checks:** the confirmation screen clears draft data immediately and can display success without requiring a paid summary, including when summary loading fails. It must verify payment before claiming success or clearing a draft.

These gaps mean the presence of the screens does not yet establish a fully working end-to-end booking journey.
