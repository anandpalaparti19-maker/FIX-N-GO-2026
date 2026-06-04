# Fix-N-Go

Full-stack mobile repair booking platform: **Node.js API**, **Flutter customer app**, and **web admin dashboard**.

## Structure

- `backend/` — Express + MongoDB REST API
- `apps/customer_app/` — Flutter customer booking app
- `apps/technician_app/fixer/fixer/` — Flutter technician (Fixer) app
- `apps/admin_panel/public/` — Admin dashboard (served at `/admin`)

## Prerequisites

- Node.js 18+
- MongoDB (local default: `mongodb://127.0.0.1:27017/fixngo`)
- Flutter 3.12+

## Quick start

### Backend

```powershell
cd fixngo/backend
npm install
npm run seed
npm run dev
```

- API: http://localhost:5000  
- Admin: http://localhost:5000/admin  
- Admin: `admin@fixngo.com` / `password123`

### Customer app

```powershell
cd fixngo/apps/customer_app
flutter pub get
flutter run
```

- Customer: `customer@fixngo.com` / `password123` (after seed)

### Technician app

```powershell
cd fixngo/apps/technician_app/fixer/fixer
flutter pub get
flutter run
```

- Technician: `tech@fixngo.com` / `password123` (after seed)

## API

| Endpoint | Description |
|----------|-------------|
| `GET /api/health` | Health check |
| `GET /api/catalog` | Brands + repair issues |
| `POST /api/auth/register` | Sign up (`role`: customer or technician) |
| `POST /api/auth/login` | Login (JWT) |
| `PATCH /api/auth/profile` | Update profile (auth) |
| `GET/POST /api/orders` | Customer orders (auth) |
| `GET /api/orders/:id` | Order detail + tracking (auth) |
| `GET /api/technician` | Public technician catalog |
| `GET /api/tech/*` | Technician app APIs (technician JWT) |
| `PATCH /api/tech/location` | Captain GPS for map distance |
| `GET /api/admin/*` | Admin (admin JWT) |

See `docs/architecture.md` for details.
