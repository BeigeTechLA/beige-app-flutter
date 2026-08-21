#     **Push Notification Documentation**

---

## **1\. Overview**

\- Push notifications are controlled from the **Third Party backend**.  
\- **App Backend does not send Firebase notifications directly.** The mobile app calls App Backend to save/remove FCM tokens and notification preferences. App Backend forwards these requests to Third Party's internal push APIs.  
\- **Third Party** checks session-wise preferences before sending a push:  
> > > \- `push_enabled = true`  
> > > \- `topic preference = true`  
> > > \- If a user has disabled a topic for a session/device, push is skipped for that device.

### **Standard payload shape**

Every notification send includes at minimum:  
   
{   
   
  "topic": "shoots | payments | messages | meetings | proposals | files | system",  
   
  "category": "same\_as\_topic",  
   
  "type": "specific\_event\_type"  
   
}

### **Implementation status by topic**

| Topic | Status |
| :---- | :---- |
| Shoots | ✅ Implemented |
| Messages | ✅ Implemented |
| Meetings | ✅ Implemented |
| Files | ✅ Implemented (Client app & CP app) |
| Payments | ❌ Not implemented |
| Proposals | ❌ Not implemented |
| System | ❌ Not implemented |

   
---

## **2\. Token & Preference Flow**

### **2.1 Save FCM token**

Call after login **and** whenever the FCM token refreshes.

**`POST /push-notifications/tokens`**

**Headers**

Authorization: {{TOKEN}}  
device\_type: android  
Content-Type: application/json

**Body**

json  
{  
  "fcm\_token": "FCM\_TOKEN",  
  "session\_id": "APP\_SESSION\_ID"  
}

**Note:** `device_type` can be sent **either** as a header **or** in the body.

**Alternative: device\_type in body**

Authorization: {{TOKEN}}

Content-Type: application/json

{

  "fcm\_token": "FCM\_TOKEN",

  "session\_id": "APP\_SESSION\_ID",

  "device\_type": "android"

}

### **2.3 Remove token (logout)**

**`DELETE /push-notifications/tokens`**  
   
{  
   
  "session\_id": "APP\_SESSION\_ID"  
   
}  
   
 **2.2 Update notification preferences**  
Call whenever the user changes their notification settings.  
   
**`PATCH /push-notifications/preferences`**  
   
{  
   
  "session\_id": "APP\_SESSION\_ID",  
   
  "notification\_preferences": {  
   
    "push\_enabled": true,  
   
    "topics": {  
   
      "shoots": true,  
   
      "payments": false,  
   
      "messages": true,  
   
      "meetings": true,  
   
      "proposals": false,  
   
      "files": true,  
   
      "system": true  
   
    }  
   
  }  
   
}  
 "session\_id": "APP\_SESSION\_ID"  
   
}  
   
---

## **3\. Shoots**

| Field | Value |
| :---- | :---- |
| Trigger | Booking payment successfully confirmed |
| Backend event | Stripe payment finalization succeeds |
| Recipient | Client/user who owns the booking |
| Topic | `shoots` |
| Type | `booking_confirmed` |

   
**Example notification**  
   
\- Title: `Booking confirmed`  
\- Body: `Your Wedding shoot booking for 2026-06-14 is confirmed.`  
   
**Payload**  
   
{  
   
  "topic": "shoots",  
   
  "category": "shoots",  
   
  "type": "booking\_confirmed",  
   
  "booking\_id": "2599",  
   
  "payment\_status": "paid"  
   
}  
   
**Frontend handling**  
   
\- On tap → open booking details/summary screen using `booking_id`.  
\- If app is already open, optionally refresh booking/payment status.  
   
---

## **4\. Payments — ⚠️ Skipped for now**

**Reason:** Payment success already sends "Booking confirmed" under Shoots. A separate Payments push may duplicate the same user action.  
   
**Future triggers (not yet implemented):**  
   
\- Payment failed  
\- Refund processed  
\- Invoice/receipt available  
\- Payment reminder  
\- Card/payment issue  
   
**Frontend handling:** No payment push handling needed yet — just keep the Payments preference toggle saved for future use.  
   
---

## **5\. Messages**

### **5.1 Trigger 1 — Messaging initiated / participant added**

| Field | Value |
| :---- | :---- |
| Backend event | Chat room created or participants added |
| Recipient | Chat recipients except sender |
| Topic | `messages` |
| Type | `messaging_initiated` |

   
**Example notification**  
   
\- Title: `New message thread started`  
\- Body: `Harsh started a conversation.`  
   
**Payload**  
   
{  
   
  "topic": "messages",  
   
  "category": "messages",  
   
  "type": "messaging\_initiated",  
   
  "event\_type": "participant\_added",  
   
  "room\_id": "ROOM\_ID",  
   
  "chat\_room\_id": "ROOM\_ID",  
   
  "booking\_id": "2599",  
   
  "sender\_id": "123",  
   
  "sender\_name": "Harsh"  
   
}  
   
**Required for navigation:** `room_id` / `chat_room_id` (same value, duplicated — pick one, `chat_room_id` recommended) **Extra context (not needed for routing):** `event_type`, `booking_id`, `sender_id`, `sender_name` — useful for the message preview UI, but not required to open the chat room  
   
   
**Frontend handling**  
   
\- On tap → open chat room using `room_id`/`chat_room_id`.  
\- If `booking_id` exists, relate the chat to that booking.

### **5.2 Trigger 2 — Direct message sent**

| Field | Value |
| :---- | :---- |
| Backend event | Message successfully created in chat |
| Recipient | All room participants except sender |
| Type | `direct_message` |

   
**Example notification**  
   
\- Title: `New message`  
\- Body: `Harsh: Can you confirm the shoot time?`  
   
**Payload**  
   
{  
   
  "topic": "messages",  
   
  "category": "messages",  
   
  "type": "direct\_message",  
   
  "room\_id": "ROOM\_ID",  
   
  "chat\_room\_id": "ROOM\_ID",  
   
  "booking\_id": "2599",  
   
  "sender\_id": "123",  
   
  "sender\_name": "Harsh"  
   
}  
   
**Required for navigation:** `room_id` / `chat_room_id` (same value, duplicated — pick one, `chat_room_id` recommended) **Extra context (not needed for routing):** `booking_id`, `sender_id`, `sender_name` — useful for the message preview UI, but not required to open the chat room  
   
**Frontend handling**  
   
\- On tap → open chat room.  
\- If the user is already inside that room, suppress duplicate in-app banner if needed.  
\- Refresh message list after opening.

### **5.3 Trigger 3 — Mention**

| Field | Value |
| :---- | :---- |
| Backend event | Message payload includes `mentioned_user_ids`, `mentionedUserIds`, `mentions`, or `mentionedUsers` |
| Recipient | Mentioned users only |
| Type | `mention` |

   
**Example notification**  
   
\- Title: `You were mentioned`  
\- Body: `Harsh: Please check this update`  
   
**Payload**  
   
{  
  "topic": "messages",  
  "category": "messages",  
  "type": "mention",  
  "room\_id": "ROOM\_ID",  
  "chat\_room\_id": "ROOM\_ID",  
  "booking\_id": "2599",  
  "message\_id": "MESSAGE\_ID",  
  "sender\_id": "123",  
  "sender\_name": "Harsh"  
}  
   
**Frontend handling**  
   
\- On tap → open chat room, and optionally scroll/highlight the mentioned message if `message_id` is added later.  
   
---

## **6\. Meetings**

### **6.1 Trigger 1 — Meeting scheduled**

| Field | Value |
| :---- | :---- |
| Backend event | Meeting created and `send_notification` is not `false` |
| Recipient | Client app users and CP app users only |
| Topic | `meetings` |
| Type | `meeting_scheduled` |

   
**Example notification**  
   
\- Title: `Meeting scheduled`  
\- Body: `Project kickoff is scheduled for Jul 21, 4:00 PM.`  
   
**Payload**  
   
{  
   
  "topic": "meetings",  
   
  "category": "meetings",  
   
  "type": "meeting\_scheduled",  
   
  "meeting\_id": "12",  
   
  "booking\_id": "2599",  
   
  "meeting\_status": "pending"  
   
}  
   
**Required for navigation:** `meeting_id` (fallback: `booking_id` if no meeting details screen exists) **Extra context (not needed for routing):** `meeting_status`  
   
**Frontend handling**  
   
\- On tap → open meeting details screen using `meeting_id`.  
\- If a meeting details screen isn't available, open booking/project details using `booking_id`.

### **6.2 Trigger 2 — Participant added**

| Field | Value |
| :---- | :---- |
| Backend event | CP participant added to meeting |
| Recipient | Newly added CP only |
| Type | `meeting_participant_added` |

   
**Example notification**  
   
\- Title:  `Added to meeting`  
\- Body: `You were added to a meeting for Project #2599.`  
   
**Payload**  
   
{  
  "topic": "meetings",  
  "category": "meetings",  
  "type": "meeting\_participant\_added",  
  "meeting\_id": "12",  
  "booking\_id": "2599",  
  "meeting\_status": "pending"  
}  
   
**Frontend handling**  
   
\- On tap → open meeting details and refresh participant list.

### **6.3 Trigger 3 — Meeting updated**

| Field | Value |
| :---- | :---- |
| Backend event | Meeting title, description, link, status, or type updated |
| Recipient | Client/user app users and CP app users only |
| Type | `meeting_updated` |

   
**Example notification**  
   
\- Title:  `Meeting updated`  
\- Body: `Project kickoff meeting details were updated.`  
   
**Payload**  
   
{  
  "topic": "meetings",  
  "category": "meetings",  
  "type": "meeting\_updated",  
  "meeting\_id": "12",  
  "booking\_id": "2599",  
  "meeting\_status": "pending"  
}  
   
   
**Frontend handling**  
   
\- On tap → open meeting details and refresh latest meeting data.

### **6.4 Trigger 4 — Meeting rescheduled**

| Field | Value |
| :---- | :---- |
| Backend event | Meeting date/time changed, or a schedule change request is approved |
| Recipient | Client/user app users and CP app users only |
| Type | `meeting_rescheduled` |

   
   
   
**Example notification**  
   
\- Title:  `Meeting rescheduled`  
\- Body: `Project kickoff has been rescheduled to Jul 21, 4:00 PM.`  
   
**Payload**  
   
{  
  "topic": "meetings",  
  "category": "meetings",  
  "type": "meeting\_rescheduled",  
  "meeting\_id": "12",  
  "booking\_id": "2599",  
  "meeting\_status": "scheduled"  
}  
   
   
**Frontend handling**  
   
\- On tap → open meeting details and show updated date/time.  
\- Refresh calendar/meeting list.

### **6.5 Trigger 5 — Meeting cancelled**

| Field | Value |
| :---- | :---- |
| Backend event | Meeting cancelled or deleted |
| Recipient | Client/user app users and CP app users only |
| Type | `meeting_cancelled` |

   
   
   
**Example notification**  
   
\- Title:  `Meeting cancelled`  
\- Body: `Project kickoff meeting has been cancelled.`  
   
**Payload**  
   
{  
  "topic": "meetings",  
  "category": "meetings",  
  "type": "meeting\_cancelled",  
  "meeting\_id": "12",  
  "booking\_id": "2599",  
  "meeting\_status": "cancelled"  
}  
   
**Frontend handling**  
   
\- On tap → open meeting list or booking details.  
\- Remove/cross out the cancelled meeting from local UI if cached.  
   
---

## **7\. Proposals — ⚠️ Skipped for now**

**Reason:** Proposal flow/events are not confirmed yet.  
   
**Future triggers (not yet implemented):**  
   
\- Proposal shared  
\- Proposal approved  
\- Proposal rejected  
\- Proposal revised  
\- Proposal feedback requested  
   
**Frontend handling:** No proposal push handling needed yet — just keep the Proposals preference toggle saved for future use.  
   
---

## **8\. Files — Client App**

### **8.1 Trigger 1 — Raw files uploaded**

| Field | Value |
| :---- | :---- |
| Backend event | CP uploads a file under Post-Production/Raw Footage |
| Recipient | Client/user app user |
| Topic | `files` |
| Type | `raw_files_uploaded` |

   
**Example notification**  
   
\- Title: `Raw files uploaded`  
\- Body: `Raw files are available for your project.`  
   
**Payload**  
   
{  
   
  "topic": "files",  
   
  "category": "files",  
   
  "type": "raw\_files\_uploaded",  
   
  "booking\_id": "2599",  
   
  "filepath": "project\_\#2599/Post-Production/Raw Footage/file.mp4"  
   
}  
   
**Frontend handling**  
   
\- On tap → open file manager for `booking_id`.  
\- Optionally navigate to the Raw Footage folder if `filepath`/path routing is supported.

### **8.2 Trigger 2 — Edited files delivered**

| Field | Value |
| :---- | :---- |
| Backend event | CP uploads a file under Post-Production/Edited Footage |
| Recipient | Client/user app user |
| Type | `edited_files_delivered` |

   
**Example notification**  
   
\- Title:  `Edited files delivered`  
\- Body:  `Edited files are ready for your review.`  
   
**Payload**  
   
{  
  "topic": "files",  
  "category": "files",  
  "type": "edited\_files\_delivered",  
  "booking\_id": "2599",  
  "project\_id": "2599"  
}  
   
   
**Frontend handling**  
   
\- On tap → open file manager for `booking_id`.  
\- Show the Edited Footage or review screen if available.

### **8.3 Trigger 3 — New version uploaded**

| Field | Value |
| :---- | :---- |
| Backend event | CP uploads a file under Post-Production/Final Deliverables |
| Recipient | Client/user app user |
| Type | `new_version_uploaded` |

   
   
**Example notification**  
   
\- Title: `New files uploaded`  
\- Body: `New files are available for your project.`  
   
**Payload**  
   
{  
  "topic": "files",  
  "category": "files",  
  "type": "new\_version\_uploaded",  
  "booking\_id": "2599",  
  "project\_id": "2599"  
}  
   
**Frontend handling**  
   
\- On tap → open file manager/final deliverables section for `booking_id`.  
   
---

## **9\. Files — CP App Notifications**

### **9.1 Trigger 1 — Client selects files for editing**

| Field | Value |
| :---- | :---- |
| Backend event | Client selects raw files and submits them for editing |
| Recipient | Assigned CP/internal editor app user. Use `crew_members.user_id` if present; otherwise fall back to matching `crew_members.email` to `active users.email` where `user_type = 2`. Admin/internal web users remain email-only. |
| Topic | `files` |
| Type | `files_selected_for_editing` |

   
**Example notification**  
   
\- Title: `Files selected for editing`  
\- Body: `Client selected files for editing on Project #2599.`  
   
   
   
   
**Payload**  
   
{  
   
  "topic": "files",  
   
  "category": "files",  
   
  "type": "files\_selected\_for\_editing",  
   
  "booking\_id": "2599",  
   
  "project\_id": "2599"  
   
}  
   
**Required for navigation:** `booking_id` / `project_id` (same value, duplicated — pick one, `booking_id` recommended for consistency with other topics)  
   
**Frontend handling**  
   
\- On tap → open the project/file manager screen for `booking_id`.  
\- If possible, open the selected files or editing queue view.

### **9.2 Trigger 2 — Client requests revisions on edits**

| Field | Value |
| :---- | :---- |
| Backend event | Client submits a revision request for delivered edited files |
| Recipient | Assigned CP/editor app user (Admin remains email-only) |
| Type | `revision_requested_on_edit` |

   
**Example notification**  
   
\- Title: `Revision requested`  
\- Body: `Client requested revisions on delivered edits.`  
   
**Payload**  
   
{  
   
  "topic": "files",  
   
  "category": "files",  
   
  "type": "revision\_requested\_on\_edit",  
   
  "booking\_id": "2599",  
   
  "project\_id": "2599"  
   
}  
   
**Required for navigation:** `booking_id` / `project_id` (same value, duplicated)  
   
**Frontend handling**  
   
\- On tap → open file manager or revision details screen for `booking_id`.

### **9.3 Trigger 3 — Client adds comment on revision**

| Field | Value |
| :---- | :---- |
| Backend event | Client adds a comment on an existing revision |
| Recipient | Relevant assigned CP/editor app user (Admin remains email-only) |
| Type | `revision_comment_added` |

   
**Example notification**  
   
\- Title: `New revision comment`  
\- Body: `Client added a comment on the revision.`  
   
**Payload**  
   
{  
   
  "topic": "files",  
   
  "category": "files",  
   
  "type": "revision\_comment\_added",  
   
  "booking\_id": "2599",  
   
  "project\_id": "2599",  
   
  "revision\_id": "123"  
   
}  
   
**Required for navigation:** `booking_id` / `project_id` (same value, duplicated) **Extra context (not needed for routing):** `revision_id` — needed only if scrolling directly to the comment thread  
   
   
**Frontend handling**  
   
\- On tap → open revision details.  
\- If `revision_id` is available, scroll to that revision/comment thread.

### **9.4 Trigger 4 — Client approves final files**

| Field | Value |
| :---- | :---- |
| Backend event | Client approves final delivered files |
| Recipient | Assigned CP/editor app user (Admin remains email-only) |
| Type | `final_files_approved` |

   
**Example notification**  
   
\- Title: `Files approved`  
\- Body: `Client approved the final files.`  
   
**Payload**  
   
{  
   
  "topic": "files",  
   
  "category": "files",  
   
  "type": "final\_files\_approved",  
   
  "booking\_id": "2599",  
   
  "project\_id": "2599"  
   
}  
   
**Required for navigation:** `booking_id` / `project_id` (same value, duplicated)  
   
**Frontend handling**  
   
\- On tap → open project/file manager screen and refresh final delivery status.  
   
---

## **10\. System — ⚠️ Skipped for now**

**Reason:** No confirmed system-level events yet.  
   
**Future triggers (not yet implemented):**  
   
\- Account security alert  
\- Email/password changed  
\- Login from new device  
\- Maintenance/downtime notice  
\- Critical account update  
   
**Frontend handling:** No system push handling needed yet — just keep the System preference toggle saved for future use.  
   
---

## **11\. General Frontend Handling**

Frontend should route notifications by `topic` and `type`:  
 

| Topic | Type(s) | Route to |
| :---- | :---- | :---- |
| `shoots` | `booking_confirmed` | Booking details/summary |
| `messages` | `direct_message`, `messaging_initiated`, `mention` | Chat room |
| `meetings` | `meeting_*` | Meeting details or booking details |
| `files` | any file event | File manager for booking |
| `payments` / `proposals` / `system` | — | No active push triggers yet |

   
**Note:** Always treat push data values as **strings**.

### **Recommended common tap handler**

function handlePushTap(data) {  
   
  switch (data.topic) {  
   
    case 'shoots':  
   
      openBooking(data.booking\_id);  
   
      break;  
   
    case 'messages':  
   
      openChatRoom(data.room\_id || data.chat\_room\_id);  
   
      break;  
   
    case 'meetings':  
   
      openMeeting(data.meeting\_id, data.booking\_id);  
   
      break;  
   
    case 'files':  
   
      openFileManager(data.booking\_id, data.filepath);  
   
      break;  
   
    default:  
   
      openNotificationsCenter();  
   
      break;  
   
  }  
   
}

### **Frontend checklist**

* ### Save FCM token after login

* ###  Update token whenever Firebase refreshes it

* ### Send a stable `session_id` with token/preference API calls

* ### Remove/deactivate token on logout

* ### Update preferences whenever the user changes toggles

* ### Avoid showing a duplicate in-app banner if the user is already on the relevant screen

* ### Refresh relevant data after a notification tap

###  

### ---

## **12\. Important Backend Behavior**

* ### **Push sending is non-blocking:** If the Third Party/Firebase push fails, the booking/chat/meeting/file API still succeeds. The failure is only logged on the backend — the core action is never blocked by a push failure.


* ### **Preference handling happens in Third Party:** App Backend sends the topic/type payload; Third Party checks session-wise `push_enabled` and topic preference before actually sending the push.

### 

—------------------------------------------------------------------------------------------------------------------------

## **Notification Screen APIs:**

![][image1]

**1). Notification list:**

GET {{URL}}app-notifications?category=projects HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

**2).** **Notification counts:**

GET {{URL}}app-notifications/counts HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

**3). Notification Detail:**

GET {{URL}}app-notifications/1 HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

**4). Read All notifications:**

PATCH {{URL}}app-notifications/read-all HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

**5). Read a notification:**

PATCH {{URL}}app-notifications/1/read HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

**6). Unread a notification:**

PATCH {{URL}}app-notifications/1/unread HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

**7). Delete notification:**

DELETE {{URL}}app-notifications/1 HTTP/1.1  
Content-Type: application/json  
Authorization: {{TOKEN}}  
device\_type: android  
user\_type\_name: client  
user\_type: 3

![][image2]

**8). get push notification preferences:**

GET {{URL}}push-notifications/preferences?session\_id=app-session-001  
Authorization: {{TOKEN}}

**9). get email notification preferences:**

GET {{URL}}notification-preferences/email  
Authorization: {{TOKEN}}

**10). update email notification preferences:**

PATCH {{URL}}notification-preferences/email  
Authorization: {{TOKEN}}  
Content-Type: application/json

{  
  "email\_enabled": true,  
  "email\_topics": {  
    "shoots": true,  
    "payments": false,  
    "messages": true,  
    "meetings": true,  
    "proposals": false,  
    "files": true,  
    "system": true  
  }  
}

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAloAAAFTCAYAAADhvKK/AACAAElEQVR4Xuy9Z7QcxblAy7o/3npvXdtkoZxz1lE4yjknJKxkgiwQAgWShEQOEhhEEjkYJHIWmBwtERwAkwy2yQ5ghDEYDBY4Xvveer2r55upru6ZM3Nm5pyZo6/X2qu7q6urU033nq9qenY779xzjaIoiqIoilJ6dvMTFEVRFEVRlNKgoqUoiqIoilImVLQURVEURVHKhIqWoiiKoihKmdjtsMMOM4pSjRx99NHmxBNOiFVqYPkBBxxgJk6cqJSImTNnmmWHHx4714qiKEp2VLSUqsev1DB58uSYKCjFM3XqVDN/3rzY+VYURVGSUdFSqp6z1q+PVGqiXL4gKKVj7ty5sRuJoiiKkoyKllL1rD/zzEilXn3ccRExaHHJ3LzxpUKJM2vWrNiNRFEURUnGitbS5cvMEVeeZA5/9SKz9BcXmUNvPNkctmKZWbp0aeyh5qcdfvjhsTxJrFq1yo6POOIIc9RRR9nx8uXLY+XVBflXrFgRS88Xtrls2bJYekPjHjfT+ZyHfPPlIlsZ/nXkPPnL5XrBkUceGVmHacEtX647sI5/3NSDutKS9scll2h1P3FmTKaElz9+O5bmCsWkSZNsEyQw7QtHvuSzLk1yc+bMySuvD+vUZ736oqKlKIqSP7stO2q5Wffy983Br24y3/3gKrP0k+vMyr/ebFYE42V3nxF7qL388svmqquuSj/4/vCHP1hx8vPBxRdfbPPxgP3ggw9sGuPf/e535vzzzzcvvviiWb9+fWy9JK6++mqbd/Xq1eYXv/hFbHld8OBmu1988YX5y1/+Ysvz8zQUyMfPf/7z9Py1115rz4efzwU5vPLKK81dd90VWwY33nijOeaYY2LpPj/60Y/Mr371q/T8cYGU3HrrrebPf/6zvU5nBtKyY8cOO//WW2+ZdevW2XybNm0yN9xwg5WgX//61/Y8fvbZZ/Z6nHTSSeZf//qXPa+wYcMGuw5C/Mwzz5izzjrLlsU6r7/+elrauB5ffvml+eSTT8yxxx5rTjjhBLtd8rFMxIx6Qtrvf/97u3/+MdVHtFpecoB58rcvxdJdoTjllFPM3/72N7tPQD0vVGimT59ur7Wf7sL5eOqpp8yjjz5acPnAft19992x9HKhoqUoipI/ux111jpz9CtXm3mvXmQWf3iNOfyzLebof91qjv33bWbVr6+KPdQQrffeey/9wHNFC4HgYS/RDh6QJ598sn04r1271j5ceYjzwEYceMgz5mHKNA9miZhQJmmUBTzc77nnHpufhzvbIx8PaLYr61EG65HuRkVI//jjj+1+8UBnP2Qdtwz2lbwiLWyb7bllsYz8Er0h/8qVK2PbzEY20SJd9p/tynLOBdtEDhEttsE8+dgH1vn888/Neeedlz4GlrsCTHnsny9aDzzwgJUaJIY8XLNPP/3ULvvrX/9qHn74YTt98803W2FCPshPWTzc4YwzzjDPP/+8Oe2008zxxx9vt886XHuu9U9+8hPzm9/8xpb/xz/+0e7b2Wefbd58801bLx555BErijfddJO9xuz3q6++ausYZSFvXHckne345zNf0Zpw2+r0dLerDzLf+8ktZuXjF5sLn78zq2jdeeedZtGiRVY0t2/fbubNm2emTJlixzNmzEiLEdGo+fPn2zTmiVDRl+nb3/62vdakk4dlrO9Grzhv5DnooIPSy92ymOcXf5RFubJ/s2fPtvnkWsh2SZs2bZotnzwS8UKQKMs9xvqgoqUoipI/u62760Jz0E82mbkvXWgO+eBqc9gnm81Rf78lEK3bzdH/vC32UEO0nnzySSstyAWixYOTKBcPYB6ePEx5eDB+/PHHzbnBhsh/6aWXmp07d9oH/emnn25+9rOf2YcpD3cg/09/+lNb1i9/+Uv7kEcALrjgAhvRePfdd225LONh/Oyzz9r9oWwewggRD+XnnnvOfPjhh+aKK65I7zcSQwSGCI0IEfuNeFAGcsGy73//+1ZaeHBt27bNysaDDz5oy1+zZo2NOrz00kt2vySNbRKx4VzwQPbPmU820UJG/vSnP1kxoUzyyblDPBgjWuzDj3/8Y7tfbPf66683f//73+05RGY5FiJHlLdx40Z7LESNOC9EZt55553YPlEOIkSZrI8wcc43b95szxXXivOFEEk0kPONAF944YU2yvj000+bH/zgB+kmRa4f0S7ZBuX89re/tWkI1SWXXGLTmX/ttdci+YjwEBlD4sjLsUmE1N/3fESrZvPh5oWP3kwL1bFPXm5aXXqAZfljm8xlL96bKFqIIk2Hhx56qN1HztErr7xizxPHghyy/1zP22+/3X4GiGK9/fbbtr6y34w5d9Q/BIhzynWWX0Zynrg+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/qpFURRFURRFSSYiWuvWri3Jf/gpiqIoiqIoKdHip/L+AkVRFEVRFKU4diOK5ScqiqIoiqIoxaNvhlcURVEURSkTKlqKoiiKoihlQkVLURRFURSlTKhoKYqiKIqilAkVLUVRFEVRlDKhoqUoiqIoilImVLQURVEURVHKhIqWoiiKoihKmVDRUhRFURRFKRMqWoqiKIqiKGVCRUtRFEVRFKVMqGgpiqIoiqKUCRUtRVEURVGUMqGipSiKoiiKUiZUtBRFURRFUcpERYjW4YcfbpYtWxaZBz+fy9KlS83atWttvlWrVpmzzz7bnHjiieb444+P5a0Lyjj66KNj6UrlklRnli9fHsvnI3WGaakzxx13nDniiCNieXMhdaauelpfODbqtYufx4fjL/Q4/HPGdinj5JNPtp8xP3++sO6RRx6ZLoPztGLFCjvvXreGhn2Q88k0xw+NvV9K5eJ/Rpiv63NPfTr22GPtNHVt06ZN9brPwAknnFDn9vJB6v7KlStjy/KF41q9erX9rPjnRclORYjWKaecYh577LHI/GmnnRbLB1Q6HgJcaKSK8bXXXmu+//3v2wtfiGht2bLFPnip/HwI/OVK5SJ1ZuPGjen5O+64I5YPqDPUEW4SUme4WUid4YaY702DuufWmVLcAJPghnjqqaeap556ylx00UV22s/jw/Ffc801sfRcnHXWWWbdunV2mvNz++23W0HinBUjWqeffrrZunWrueCCC9Lbuffee80xxxxjzjnnnFj+hoDj+cEPfmDPJSDZPHQ410cddZQ5//zz7XFz7ynXdVWqC+rMo48+mr7PMM/nLNvzifuMPJ+4xwBp3GMKvc/wfHIDCn6eQqCc++67L133b7jhBluunw/4LFx22WWxdGA/1qxZY84991xzzz33xJYryVSMaF133XW2YnHjc0XrrrvuMldeeaWtGFSAq666yk4TTWB80kkn2Rv43XffbSuOlHHppZfaCs6DgwcVN3ry33zzzXZb5OUDtHnzZlsW3zi4ybKMbZCPBw7r3XTTTXZdtlFshVdKQ1KdEdGSOnPbbbel68zDDz+cvsFQZy655JJ0nbn44outgEmdAbfOcNOROsMyt87wLVHqzPXXX282bNiQrjNXX3213QY33RtvvNGmsb/5Sj03xx/+8If2pss822JfKZdjk2/H1H+Ol/qMaJ1xxhl2W+w3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>

[image2]: <data:image/png;base64,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>