# Client App — Meetings & Messaging Fix Plan

**Scope:** Client App (User) only. Single binary, no CP flavor needed.
**Source of issues:** Audit comparing `docs/features/BOOKING_FEATURES_GUIDELINES.md` against current implementation in `lib/features/meetings` and `lib/features/messages`.
**Resolution of Open Decision #1:** Client CAN add participants on own meetings (matches §6 Open Decision #1 option a).
**Backend assumption:** Endpoints for edit / cancel / accept / decline are available.

---

## Execution Order

```
P0 → P1 → P2 → P3 → P4 → P5 → P6
P7, P8 — independent, can run in parallel batch
P9 — dropped (no longer needed)
P10 — optional cleanup, last
```

---

## Phase 0 — Current-user identity provider

**Problem:** No `currentUserId` / `currentUser` provider exposed to widgets. Required for ownership gating in P3 / P4 / P5 / P6.

### Tasks
- [ ] Add `currentUserIdProvider` (`Provider<String?>`) in `lib/core/providers/auth_state_provider.dart` (or new file `current_user_provider.dart`). Source = SharedPreferences `user_id` written at login.
- [ ] Add `currentUserProvider` exposing minimal profile `{ id, role }` for later role-aware reads.
- [ ] Verify `Meeting` entity (`lib/features/meetings/domain/models/meeting.dart`) carries `createdById` / `ownerId`. If missing — add field, map from DTO (`meeting_dto.dart`), surface from `meetings_remote_source.dart`.
- [ ] Unit test: provider returns id when login persisted, returns null on logout.

---

## Phase 1 — Real shoot dropdown in Create Meeting

**Problem:** `create_meeting_screen.dart:30-46, 201-247` uses hardcoded `_titleOptions` and `_shootOptions` lists. Client should only schedule meetings against their own bookings (spec §3.4).

### Tasks
- [ ] Delete `_titleOptions` and `_shootOptions` static lists.
- [ ] Add `clientShootsProvider` (`AsyncNotifier`) wrapping `ShootRepository.getMyShoots()`.
- [ ] Replace project dropdown with `AsyncValue.when` — populate items from real shoots.
- [ ] Decision: title source = free-text `TextFormField` (drop title dropdown entirely).
- [ ] Change `CreateMeetingState.project` from `String` to typed record `{ id: String, title: String }`.
- [ ] Pass real `shootId` (not display string) into create payload via `create_meeting_notifier.dart`.
- [ ] Verify `CreateMeetingInput` model + remote source accept the shoot id field name expected by backend.

---

## Phase 2 — Participant picker against booking roster

**Problem:** `create_meeting_screen.dart:380-457` uses free-text `_participantCtrl` + Add button — no user search, no booking-roster picker. Risk of garbage data + no real id binding.

### Tasks
- [ ] Build `MeetingParticipantPickerSheet` widget (modal bottom sheet, multi-select).
- [ ] Source = `BookingRepository.getBookingParticipants(shootId)`. Add method on repo + datasource if missing (CP + Admin + team for the selected shoot).
- [ ] Render rows with avatar, name, role badge. Search filter on name.
- [ ] Open sheet on tap of "Invite Participants*" field — replace inline text input.
- [ ] Replace `_participantCtrl` + Add button with chip list rendered from selected `Participant` entities.
- [ ] Change `CreateMeetingState.invitedParticipants` from `List<String>` → `List<MeetingParticipantInput>` (`{ id, name }`).
- [ ] Update `create_meeting_notifier.dart` `addParticipant` / `removeParticipant` signatures.
- [ ] Keep `MeetingsRepositoryImpl.create` two-step participant POST — already wired (`meetings_repository_impl.dart:38-49`).

---

## Phase 3 — Edit meeting (own only)

**Problem:** `meeting_details_sheet.dart:134-138` edit handler is a stub `'Edit meeting — coming soon'`. Edit icon `:169-178` shown unconditionally with no owner check. Spec §3.2 — Client ✅ own only.

### Tasks
- [ ] Build `EditMeetingScreen` reusing create screen layout. Hydrate fields from `meetingDetailsProvider(meetingId)`.
- [ ] Add `EditMeetingNotifier` + state. Wraps `MeetingsRepository.update(id, UpdateMeetingInput)`.
- [ ] Add `RouteNames.meetingEdit` constant + GoRoute in `lib/app/router.dart`.
- [ ] Replace stub `_onEdit` with `context.pushNamed(RouteNames.meetingEdit, extra: meetingId)`.
- [ ] Gate edit icon: `if (meeting.createdById == ref.watch(currentUserIdProvider)) ... IconButton(...)`.
- [ ] On save success → `ref.invalidate(meetingDetailsProvider(id))` + `meetingsListNotifierProvider`.
- [ ] Show snackbar on save error.

---

## Phase 4 — Cancel meeting (own only)

**Problem:** No Cancel affordance on details sheet. Repository has `delete(id)` but no UI wires it. Spec §3.2 — Client ✅ own.

### Tasks
- [ ] Add "Cancel Meeting" outlined button beside "Join Meeting" in `meeting_details_sheet.dart` bottom CTA region (`220-249`).
- [ ] Render only when `meeting.createdById == currentUserId`.
- [ ] Confirm dialog: title "Cancel meeting?", destructive style, "Keep" / "Cancel meeting" actions.
- [ ] On confirm → `MeetingsRepository.delete(id)`.
- [ ] On success → pop sheet + `ref.invalidate(meetingsListNotifierProvider)` + success snackbar.
- [ ] Inline error display on failure.

---

## Phase 5 — Accept / Decline invitation (list + details)

**Problem:** Neither the meeting list cards nor the details sheet expose Accept / Decline. Spec §3.3 requires both surfaces.

### Tasks
- [ ] Add `MeetingsRepository.respond(id, MeetingResponse)` (enum: `accept`, `decline`).
- [ ] Wire remote source method to backend endpoint.
- [ ] Add `meetingResponseProvider` (AutoDisposeFamily Notifier per meeting id) for submission state.
- [ ] Update `MeetingParticipant` entity (`meeting_participant.dart`) with `rsvpStatus` field (`pending` | `accepted` | `declined`). Map from DTO.
- [ ] In `meeting_details_sheet.dart` `_DetailsBody`, compute viewer's RSVP from `meeting.participants` + `currentUserId`. When status == `pending` → render Accept / Decline buttons above "Join Meeting".
- [ ] In `meeting_card.dart` listing tile, expose Accept / Decline CTAs when viewer is invited and RSVP is `pending`. Hide once responded.
- [ ] On submit (from either surface) → invalidate `meetingDetailsProvider` + `meetingsListNotifierProvider` + snackbar.
- [ ] Decision: hide "Join Meeting" / list "Join" until accepted? — confirm with PM. Default: keep visible.

---

## Phase 6 — "Invited / Awaiting Response" tab

**Problem:** Tab bar has only Upcoming / Completed. No surface for accept/decline workflow.

### Tasks
- [ ] Add `MeetingsTab.invited` to tab enum (or extend `MeetingStatus`).
- [ ] Update `meetings_tab_bar.dart` to render new tab. Add badge with pending count.
- [ ] Update `meetings_list_notifier.dart` filter logic: `meeting.participants.any((p) => p.id == currentUserId && p.rsvpStatus == pending)`.
- [ ] Update `_applyClientFilters` in `meetings_repository_impl.dart:92-126`.
- [ ] Tap on invited card → details sheet → Accept/Decline buttons from Phase 5.
- [ ] After response → auto-refresh tab (badge decrements).

---

## Phase 7 — Strip chat details to participants only

**Problem:** Chat details page renders Search + Linked Shoot + Shared Files + Notes. Out of scope for Client app. Only Participants section needed.

### Tasks
- [ ] Remove `_NotesCard` render block from `_Body.build` (`chat_details_screen.dart:155-165`).
- [ ] Remove "Linked Shoot" `DetailsSectionCard` block (`chat_details_screen.dart:135-143`).
- [ ] Remove "Shared Files" `DetailsSectionCard` block (`chat_details_screen.dart:144-154`).
- [ ] Remove `_SearchField` block + `searchCtrl` plumbing (`chat_details_screen.dart:112-126`).
- [ ] Drop unused widgets: `_LinkedShootBody`, `_SharedFilesBody`, `_NotesCard`, `_SearchField`, `_EmptyText`.
- [ ] Drop unused imports: `shared_file_row.dart`, `shared_file.dart` entity if no other consumer.
- [ ] Drop `_notesCtrl`, `_searchCtrl`, `_searchQuery` state from `_ChatDetailsScreenState`.
- [ ] Drop `notes`, `sharedFiles`, `linkedShoot` fields from `ChatDetails` entity if no other consumer. If shared elsewhere — keep entity, just stop rendering.
- [ ] Backend payload changes not required — Client just stops rendering fields.
- [ ] Visual smoke test: details renders Hero header + Participants only.

---

## Phase 8 — Hide attachment menu from chat composer

**Problem:** `attach_action_sheet.dart` exposes File + Link-Shoot kinds. Scope decision: messaging is text-only on Client. Attachment menu not needed.

### Tasks
- [ ] In `chat_thread_screen.dart` — remove `onAttachPressed: () => _openAttach(context)` wiring on `ChatComposer` (`:209`). Pass `null` or drop the prop if composer signature allows.
- [ ] In `widgets/chat_composer.dart` — hide the paperclip / attach `IconButton` when `onAttachPressed == null` (or remove the button outright if attach is permanently dropped).
- [ ] Delete `_openAttach` method from `chat_thread_screen.dart` (`:98-130`).
- [ ] Delete `attach_action_sheet.dart` widget + `AttachKind` enum if no other consumer.
- [ ] Camera and mic buttons in composer — keep (separate scope).
- [ ] Confirm composer still sends text + voice + camera-image cleanly after attach removal.

---

## Phase 9 — Removed

Phase 9 (Linked Shoot row navigation) is **dropped**. Linked Shoot section is removed in Phase 7, so the navigation handler is no longer needed.

---

## Phase 10 — Optional: rename `leaveConversation`

**Problem:** `messages_repository_impl.dart:50-52` + `chat_thread_providers.dart:131-133` name `leaveConversation` for what is actually a socket-room exit on screen dispose. Confusing vs spec "Leave chat" (which is ❌ for all roles).

### Tasks
- [ ] Rename method on `MessagesRepository` interface: `leaveConversation` → `exitRoom`.
- [ ] Rename impl + socket source method.
- [ ] Update all callers.
- [ ] No behavior change.

---

## Test plan per phase
- Each phase: 1 happy-path widget test + 1 owner-gating unit test where applicable (P3, P4, P5, P6).
- Manual: `flutter run --flavor dev -t lib/main_dev.dart` — drive flow on device or simulator.
- `flutter analyze` clean before phase commit.
- `flutter test` green before phase commit.

## Commit convention
One commit per phase using project format:
```
feat(meetings): add edit own meeting flow with owner gating (P3)
fix(messages): hide admin-only notes from client app (P7)
chore(messages): rename leaveConversation to exitRoom (P10)
```