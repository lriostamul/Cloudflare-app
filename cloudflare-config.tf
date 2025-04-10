resource "cloudflare_record" "cloudflare_app_record" {
  zone_id = "0d2ed371903816466b3f21a18459a016"
  name    = "cloudflare-app"              
  type    = "A"
  value   = "52.14.114.68"
  ttl     = 1                
  proxied = true 
}

resource "cloudflare_zone_settings_override" "tls_mode" {
  zone_id = "0d2ed371903816466b3f21a18459a016"

  settings {
    ssl = "strict"
    always_use_https = "on"
  }
}

resource "cloudflare_r2_bucket" "country_flags" {
  account_id = "35c640e2fe604f0b4599ae82a5c92154"
  name       = "country-flags"
  location   = "WNAM"
}

resource "cloudflare_workers_route" "secure_path" {
  zone_id     = "0d2ed371903816466b3f21a18459a016"
  pattern     = "tunnel.tamulsecurity.com/protected"
  script_name = "secure-worker"
}

resource "cloudflare_workers_route" "secure_flags" {
  zone_id     = "0d2ed371903816466b3f21a18459a016"
  pattern     = "tunnel.tamulsecurity.com/protected/*"
  script_name = "secure-worker"
}