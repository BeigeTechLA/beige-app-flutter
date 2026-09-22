**Google Meet Link Generation from Mobile App Base URL**

# **Purpose**

This document explains whether the mobile app can generate Google Meet links using the mobile app base URL, and what workaround should be used if the required route is not currently available on the mobile backend.

# **Summary**

| Question | Answer |
| :---- | :---- |
| Can mobile generate the Meet link? | Yes, if the mobile backend exposes the same create-event route used by web. |
| Should the mobile app create the link directly? | No. Google Calendar credentials and OAuth tokens must remain on the backend. |
| Required endpoint | POST /external-meetings/create-event |
| Recommended workaround | Add or proxy the same endpoint on the mobile backend and forward the request to the existing backend service. |

# **Current Web API Flow**

The web app uses the following environment base URL:

NEXT\_PUBLIC\_API\_ENDPOINT

Example production base URL:

https://revure-api.beige.app/v1/

The web app calls the existing backend endpoint below:

POST https://revure-api.beige.app/v1/external-meetings/create-event

This endpoint creates a Google Calendar event with Google Meet conference data enabled. Google returns the generated Meet link, and the backend returns it to the client as meetLink.

# **Endpoint Required for Mobile**

The mobile app should call the same route using the mobile API base URL:

POST {MOBILE\_API\_BASE\_URL}/external-meetings/create-event

If the mobile API base URL points to the same backend used by web, this endpoint should work directly. If the mobile API base URL points to a separate backend or service and this route is not available, the route should be added or proxied on the mobile backend.

# **Request Body**

{  
  "userId": "current\_user\_id",  
  "summary": "Meeting title",  
  "location": "Online",  
  "description": "Meeting description",  
  "startDateTime": "2026-07-03T10:00:00.000Z",  
  "endDateTime": "2026-07-03T11:00:00.000Z",  
  "orderId": "booking\_id"  
}

# **Success Response**

{  
  "meetLink": "https://meet.google.com/xxx-xxxx-xxx"  
}

# **Authorization Response**

If Google Calendar authorization is missing or expired, the backend can return an authorization URL:

{  
  "authUrl": "https://accounts.google.com/..."  
}

In this case, the mobile app should open the authUrl in a browser or webview. After Google authorization is completed, the same create-event API call should be retried.

# **Authentication Requirement**

The API is authenticated. Mobile must pass the logged-in user token in the request headers:

Authorization: Bearer \<token\>  
Content-Type: application/json

| Status Code | Meaning |
| :---- | :---- |
| 401 Unauthorized | The auth token is missing, expired, or invalid. |
| 403 Forbidden | The user is authenticated, but the role may not have permission to create meetings. |

# **Recommended Workaround**

If the mobile base URL does not currently support POST /external-meetings/create-event, add a proxy endpoint on the mobile backend:

POST {MOBILE\_API\_BASE\_URL}/external-meetings/create-event

The mobile backend proxy should forward the request to the existing backend endpoint:

POST https://revure-api.beige.app/v1/external-meetings/create-event

The proxy should forward the following values:

* Request body  
* Authorization header  
* Content-Type header

With this approach, the mobile app continues using only the mobile base URL, while the existing backend handles Google Calendar integration and Meet link generation.

# **Why Backend Proxy Is Preferred**

* Google Calendar credentials should not be exposed in the mobile app.  
* Google OAuth refresh tokens should remain server-side.  
* Meet link generation is already implemented in the backend.  
* Mobile and web can share the same backend logic.  
* This avoids duplicate Google Calendar integration in the mobile app.

