# Trusty moderation callback API

Trusty sends pending services to:

`POST https://us-central1-trusty-kzh1sb.cloudfunctions.net/api/moderation`

using `Authorization: Bearer <API_SECRET_TOKEN>`. The Firestore trigger sends
the creator, category, title, description, price, and every image URL whenever
a new or edited service enters `onModerate`.

The Telegram bot returns a service moderation decision to one HTTP endpoint:

`POST https://us-central1-trusty-kzh1sb.cloudfunctions.net/moderationCallback`

## Authorization

Send the shared secret in the HTTP header:

```http
Authorization: Bearer <MODERATION_WEBHOOK_TOKEN>
Content-Type: application/json
```

The token is stored in Google Secret Manager as `MODERATION_WEBHOOK_TOKEN` and
must never be included in the JSON body, source code, or logs.

## Request

Approval:

```json
{
  "serviceId": "firestore-service-document-id",
  "status": "approved",
  "moderatorId": "telegram-user-id"
}
```

Rejection:

```json
{
  "serviceId": "firestore-service-document-id",
  "status": "rejected",
  "reason": "The rejection reason shown to the service owner",
  "moderatorId": "telegram-user-id"
}
```

`reason` is required for `rejected`. `moderatorId` is optional but recommended.

## Responses

- `200` — decision applied, or the exact same decision was already applied.
- `400` — invalid JSON fields.
- `401` — missing or invalid Bearer token.
- `404` — service does not exist.
- `409` — service is no longer awaiting moderation.
- `500` — server configuration or Firestore error.

Successful response:

```json
{
  "ok": true,
  "serviceId": "firestore-service-document-id",
  "status": "approved",
  "idempotent": false
}
```

The bot may safely retry a request after a timeout. A repeated identical
decision returns `200` with `idempotent: true` and does not create a duplicate
notification.

## Deployment setup

Create the shared secret before the first deployment:

```sh
firebase -P trusty-kzh1sb functions:secrets:set MODERATION_WEBHOOK_TOKEN
firebase -P trusty-kzh1sb deploy --only functions:moderationCallback
```

Deploy the rules that prevent clients from self-approving services:

```sh
firebase -P trusty-kzh1sb deploy --only firestore:rules
```
