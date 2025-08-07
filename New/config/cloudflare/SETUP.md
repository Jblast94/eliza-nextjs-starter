# Cloudflare Zero Trust Configuration

## Step 1: Create Cloudflare Tunnel

1. Go to https://dash.cloudflare.com/ → Zero Trust Dashboard
2. Navigate to Access → Tunnels
3. Click "Create a tunnel"
4. Name it "dev-stack-tunnel"
5. Copy the token and add to .env:
   ```
   CLOUDFLARE_TUNNEL_TOKEN=your-tunnel-token
   ```

## Step 2: DNS Configuration

Add these DNS entries in Cloudflare:
- remote.bbj4u.xyz → CNAME to tunnel
- trae.bbj4u.xyz → CNAME to tunnel

## Step 3: Access Policies

### RustDesk Server (remote.bbj4u.xyz)
- Policy Name: RustDesk Access
- Action: Allow
- Rules:
  - Include your IP addresses
  - Include Tailscale IPs if using
  - Require authentication

### Trae.ai Windows (trae.bbj4u.xyz)
- Policy Name: Trae IDE Access
- Action: Allow
- Rules:
  - Require authentication
  - Device posture check
  - Geo-fencing if needed

## Step 4: Authentication

Set up authentication method:
1. Go to Settings → Authentication
2. Choose methods:
   - One-time pin
   - GitHub
   - Google Workspace
   - Custom header if using Tailscale

## Step 5: Cloudflare Access Groups

Create these groups:
1. Admins
   - Your main account
   - Additional admin users
2. Developers
   - Team members
   - Contractors
3. CI/CD
   - Service accounts
   - Build systems
