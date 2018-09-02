@lazyglobal off.

run once lib_ui.
run once lib_gui.

// file names
local landSiteStorage to "landingSites".
local landSiteFile to "landing_sites.json".
local landSitePath to "0:/"+landSiteStorage+"/"+landSiteFile.
// load from KSC
if not(exists(landSiteFile)) { // if there isn't already a copy stored locally.
  if exists(landSitePath) {
    copypath(landSitePath, landSiteFile). // copy from KSC to local.
  }
} 
// adds a Site 
function landSiteAdd {
  parameter name, site.
  parameter lsFile to landSiteFile. // defaults to local storage
  local sites to readjson(lsFile).
  if not(sites:haskey(name)) sites:add(name, site).
  else {
    if guiUserYesNo("Update Existing Site?") set sites[name] to site.
  }
  writejson(sites, lsFile).
}

function landSiteRemove {
  parameter name.
  parameter lsFile to landSiteFile. // defaults to local storage
  local sites to readjson(lsFile).
  if sites:haskey(name) { 
    sites:remove(name).
    writejson(sites, lsFile).
  } else uiDebug("site not found.").
}

function landSiteAddKSC {
  parameter name, site.
  landSiteAdd(name, site, landSitePath).
}

function landSiteRemoveKSC {
  parameter name.
  landSiteRemove(name, landSitePath).
}

function landSiteGet {
  parameter tName.
  local sites to readjson(landSiteFile).
  if sites:haskey(tName) return sites[tName].
  else uiDebug("no site named: " + tName).
}

// returns a list of all the site names for a given body
function landSiteNames {
  parameter siteBody to body:name. // defaults to current body name
  local sites to readjson(landSiteFile).
  local siteList to list().
	for k in sites:keys {
    if sites[k]["body"]:contains(siteBody) siteList:add(k).
  }
  return siteList.
}

// returns a recorded site
function landSiteRecord {
  local takenSite to lexicon().
	takenSite:add("body", body:name).
	takenSite:add("lat", ship:geoposition:lat).
	takenSite:add("lng", ship:geoposition:lng).
	return takenSite.
}

function landSiteNearest {
	local currPos to ship:geoposition.
	local sites to landSiteNames().
	if sites:length > 0 {
		local closestSite to landSiteGet(sites[0]).
		local closestPos to body:geopositionlatlng(closestSite["lat"], closestSite["lng"]).
		local closeDist to calcDistance(currPos, closestPos).
		for site in sites {
			local thisSite to landSiteGet(site).
			local sitePos to body:geopositionlatlng(thisSite["lat"], thisSite["lng"]).
			local siteDist to calcDistance(currPos, sitePos).
			if siteDist<closeDist {
				set closestSite to thisSite.
				set closeDist to siteDist.
			}
		}
    return closestSite.
	}
}