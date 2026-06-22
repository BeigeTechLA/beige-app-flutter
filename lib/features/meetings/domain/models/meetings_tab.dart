/// Tabs shown on the meetings list screen.
///
/// Distinct from `MeetingStatus` (which is the server-side status of an
/// individual meeting). The tab is a UI-only grouping:
///
/// - `upcoming` — everything that hasn't completed yet.
/// - `invited` — meetings where the signed-in user is a participant with a
///   pending RSVP. Surfaces the Accept/Decline workflow.
/// - `completed` — meetings that have ended.
enum MeetingsTab { upcoming, invited, completed }

extension MeetingsTabX on MeetingsTab {
  String get label => switch (this) {
        MeetingsTab.upcoming => 'Upcoming',
        MeetingsTab.invited => 'Invited',
        MeetingsTab.completed => 'Completed',
      };
}
