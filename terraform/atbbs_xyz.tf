resource "cloudflare_dns_record" "atbbs_xyz_telnet_a" {
  zone_id  = local.zones.atbbs_xyz
  name     = "tel.atbbs.xyz"
  type     = "A"
  content  = local.sunnyshore
  proxied  = false
  ttl      = 1
  tags     = []
  settings = {}
}
