# Sehat Coach Backend (`firebase/`)

Supports deploying the 4 required V1 HTTPS endpoints (`adultEligibility`, `accountDeletion`, `syncUpload`, `syncPull`) to **Render**, **Vercel**, or **Firebase Cloud Functions**, while keeping **Firebase Auth + App Check + Firestore** on Firebase (`blogging-app-2025`).

## 1. Firebase Service Account Credentials (Required for Render / Vercel)

1. Open **Firebase Console -> Project Settings -> Service accounts**.
2. Click **Generate new private key** to download the JSON credential file outside this repository.
3. Never commit that JSON file into Git (`verify_no_secrets.dart` rejects service-account files).
4. Set these environment variables in Render or Vercel:
   - `FIREBASE_PROJECT_ID` = `blogging-app-2025`
   - `FIREBASE_CLIENT_EMAIL` = `<client_email from downloaded JSON>`
   - `FIREBASE_PRIVATE_KEY` = `<private_key value from downloaded JSON>`

*(Alternatively, set `FIREBASE_SERVICE_ACCOUNT_JSON` with the entire JSON content.)*

## 2. Deploy on Render (Free Web Service)

- **Root Directory:** `firebase/functions` *(or deploy via `firebase/render.yaml` Blueprint)*
- **Build Command:** `npm install && npm run build`
- **Start Command:** `npm start`
- **Health Check Path:** `/healthz`

Once live (for example `https://sehat-coach-backend.onrender.com`), your 4 endpoint URLs are:
- `ADULT_ELIGIBILITY_URL`: `https://<your-host>/adultEligibility`
- `ACCOUNT_DELETION_URL`: `https://<your-host>/accountDeletion`
- `SYNC_UPLOAD_URL`: `https://<your-host>/syncUpload`
- `SYNC_PULL_URL`: `https://<your-host>/syncPull`

## 3. Deploy on Vercel

1. Import the GitHub repository into Vercel and set **Root Directory** to `firebase/functions`.
2. Vercel reads [`vercel.json`](functions/vercel.json), runs `npm run build`, and serves [`src/index.ts`](functions/src/index.ts) via its default Web `fetch` entrypoint.
3. Add `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, and `FIREBASE_PRIVATE_KEY` in **Project Settings -> Environment Variables**, then deploy.
4. Use the exact same 4 HTTPS paths on your Vercel domain (`/adultEligibility`, `/accountDeletion`, `/syncUpload`, `/syncPull`).

