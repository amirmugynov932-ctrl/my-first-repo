TANDAU ONLINE — setup guide
============================

WHAT THIS VERSION DOES
- Public product catalogue reads active products from Supabase.
- Admin signs in with Supabase Auth (email + password).
- Admin can add/edit/delete products.
- Product photos upload to Supabase Storage.
- Products and photos are shared between devices after deployment.
- Public visitors can browse products; only the admin user can change them.

IMPORTANT
This is a starter storefront, not yet a complete production checkout.
Cart is a browser-side demo. Payment processing, order creation, shipping integrations,
tax/legal pages, customer accounts, and marketplace vendor onboarding are NOT connected.
Do not accept payments until those pieces are implemented and tested.

STEP 1 — Create Supabase project
1. Go to https://supabase.com and create a project.
2. Save the database password somewhere safe.
3. Open Project Settings → API (or Data API / API Keys, depending on dashboard version).
4. Copy the Project URL and anon/publishable key.
   The anon/publishable key is designed to be used in browser code with RLS enabled.
   NEVER use the service_role or secret key in config.js or frontend code.

STEP 2 — Create database and image storage
1. In Supabase open SQL Editor → New query.
2. Open supabase_setup.sql from this package.
3. Paste the complete SQL and run it.
This creates the products table, admin allow-list, row-level security policies,
and a public product-images bucket with admin-only uploads.

STEP 3 — Create your admin login
1. In Supabase open Authentication → Users → Add user.
2. Create an email and a strong password that only you control.
3. Confirm the user if the dashboard asks.
4. Copy the new user's UUID from the Users table.
5. In SQL Editor run this command, replacing THE_USER_UUID with that UUID:

   insert into public.store_admins (user_id)
   values ('THE_USER_UUID');

Only that user will be able to manage products. Do not add ordinary customers to store_admins.

STEP 4 — Connect this website
1. Make a copy of config.example.js named config.js.
2. Put your Supabase Project URL in the url field.
3. Put your anon/publishable key in anonKey.
4. Save config.js next to index.html.
5. Do not publish config.example.js as your live config, and never put a service_role key in it.

STEP 5 — Test locally
For a simple local test, open the folder with a local static web server.
If you have Python installed, run this command inside the project folder:

   python -m http.server 8000

Then open http://localhost:8000
(Some browsers restrict module/CDN behavior from file://, so use the local server.)

STEP 6 — Publish
Deploy the folder to a static hosting provider such as Netlify, Vercel, or Cloudflare Pages.
Upload index.html and config.js (plus any other required files).
Use the deployed HTTPS URL to test:
- public catalogue;
- admin login;
- adding a product;
- uploading several images;
- editing and deleting a product;
- opening the site on another device.

SECURITY CHECKLIST
- Use a unique, strong admin password.
- Enable email confirmation / secure account settings as appropriate.
- Keep Supabase RLS enabled.
- Never expose service_role / secret keys.
- Only add your own user UUID to store_admins.
- Use HTTPS hosting.
- Back up product data and keep original product photos.

NEXT DEVELOPMENT PHASE
Before real sales, implement:
- checkout that creates an orders row in the database;
- customer contact/address validation;
- an admin order-management screen;
- a real payment provider available to your business and country;
- delivery pricing and shipping workflow;
- returns, privacy, terms, and required legal/tax information.
