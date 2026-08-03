# Product images

Drop real photos in here with these EXACT filenames - the site already
looks for them and falls back to an icon automatically if one's missing,
so you can add these one at a time without ever breaking the page.

| Filename     | Product            | Suggested search terms          |
| ------------ | ------------------- | -------------------------------- |
| hero.jpg     | Homepage banner photo | "hardware store shelf", "tools flat lay", "trade counter workshop" |
| hose.jpg     | Garden Hose 20m      | "garden hose", "hose reel"       |
| drill.jpg    | Cordless Drill 18V   | "cordless drill", "power drill"  |
| paint.jpg    | Paint Roller Set     | "paint roller", "paint tray"     |
| hammer.jpg   | Claw Hammer 450g     | "claw hammer", "hammer tool"     |
| level.jpg    | Spirit Level 600mm   | "spirit level", "bubble level"   |
| gloves.jpg   | Work Gloves - Pair   | "work gloves", "safety gloves"   |

## Where to get free, legally-safe photos

- **Unsplash** — https://unsplash.com (Unsplash License: free for commercial
  use, no attribution required)
- **Pexels** — https://pexels.com (same terms, huge tool/hardware category)

Search each term above, download the photo (there's a free download button
on both sites, no account needed on Pexels), and save it into this folder
with the exact filename from the table.

## Recommended image specs

- Roughly square or 4:3 aspect ratio (the site crops to fill either way)
- At least 600x450px so it doesn't look blurry
- JPG is fine; if you save a PNG or WEBP instead, just update the `image`
  field for that product in both:
  - `services/product-service/app.py` (the `PRODUCTS` list)
  - `frontend/app.js` (the `FALLBACK_PRODUCTS` list)

## Re-deploying after adding images

Run `./scripts/deploy-frontend.sh` again - it syncs this whole `frontend/`
folder (including this `images/` directory) to S3.
