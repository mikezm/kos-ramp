@lazyglobal off.

run once lib_sites.
run once lib_gui.
run once lib_parts.

partsOpenTerminal().

if guiUserYesNo("record site?") {
  local siteName to guiUserInput("Site Name").
  if not(siteName:contains("failed")) {
    local site to landSiteRecord().
    landSiteAdd(siteName, site).
    if guiUserYesNo("update KSC storage?") {
      landSiteAddKSC(siteName, site).
    }
  }
} else if guiUserYesNo("select existing site?") {
  local siteList to landSiteNames().
  local selectedName to guiUserSelect("Please select site", siteList).
  local site to landSiteGet(selectedName).
  print "site name: " + selectedName.
  for key in site:keys print key + " : " + site[key].
}




