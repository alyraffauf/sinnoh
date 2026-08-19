resource "cloudflare_dns_record" "aly_town_apex_a" {
  zone_id  = local.zones.aly_town
  name     = "aly.town"
  type     = "A"
  content  = "51.81.32.154"
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
