/// Tabs shown on the meetings list screen.
///
/// Distinct from `MeetingStatus` (which is the server-side status of an
/// individual meeting). The tab is a UI-only grouping:
///
/// - `upcoming` — everything that hasn't completed yet.
/// - `completed` — meetings that have ended.
enum MeetingsTab { upcoming, completed }

extension MeetingsTabX on MeetingsTab {
  String get label => switch (this) {
        MeetingsTab.upcoming => 'Upcoming',
        MeetingsTab.completed => 'Completed',
      };
}
