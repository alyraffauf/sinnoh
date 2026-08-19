resource "cloudflare_dns_record" "aly_town_apex_a" {
  zone_id  = local.zones.aly_town
  name     = "aly.town"
  type     = "A"
  # The apex remains on Johto; Vaultwarden below is served from Sinnoh.
  content  = local.olivine
  proxied  = true
  ttl      = 1
  tags     = []
  settings = {}
}

resource "cloudflare_dns_record" "aly_town_vault_a" {
  zone_id  = local.zones.aly_town
  name     = "vault.aly.town"
  type     = "A"
  content  = local.sunnyshore
  proxied  = true
  ttl      = 1
  tags     = []
  settings = {}
}
