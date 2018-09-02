@lazyglobal off.
parameter legH to 0.5. // put landed craft and get alt:radar reading
//parameter controlPartName is ship:controlpart:name.

run once lib_sites.
run once lib_gui.
run once lib_circle_nav.
run once lib_ui.
run once lib_hover.

local site to lexicon().
local selectedName to "".

// init potential targets, if any.
local targetSiteList to list().
local targetSites to list().
list targets in targetSites.
for tar in targetSites {
  if (  tar:body:name:contains(ship:body:name) and  // same body as us
        not(tar:type:contains("Flag")) and          // not a flag
        not(tar:type:contains("Debris")) and        // not debris
        not(tar:type:contains("Space")) and         // not a space object
        tar:status:contains("LANDED")               // on the ground.
      ) targetSiteList:add(tar:name).   // add it to the list.
}

// gui input logic
local siteOpts to lexicon().
siteOpts:add("Landing Sites", selectFromSites@).
siteOpts:add("Distance", selectFromDistance@).
if targetSiteList:length>0 siteOpts:add("Targets", selectFromTargets@).
local userSelect to guiUserRadioBtn("Target Selection Methods", siteOpts:keys).
siteOpts[userSelect]().


// check if ready and launch!
if guiUserYesNo("Launch to: " + selectedName, "Launch!", "Cancel") {
  //local geoSite to body:geopositionlatlng(site["lat"], site["lng"]).
  //local distToSite to calcDistance(geoSite, ship:geoposition).
  //if distToSite > 1000 {
  //  if guiUserYesNo("Site, " + selectedName + " is over 1 km away. Care to try jumping?", "Jump!", "Hover!") {
  //    run jumpto(site["lat"], site["lng"], legH).
  //  } else run hoverto(site["lat"], site["lng"], legH).
  //} else run hoverto(site["lat"], site["lng"], legH).

  //ship:partsdubbedpattern(controlPartName)[0]:controlfrom.
  run hoverto(site["lat"], site["lng"], legH).
}

// ------------
// functions
//
// select from saved site list 
function selectFromSites {
  local siteList to landSiteNames().
  set selectedName to guiUserSelect("Please select site", siteList).
  set site to landSiteGet(selectedName).
}

// select from targets.
function selectFromTargets {
  if ( not(HASTARGET) or not(target:body:name:contains(ship:body:name)) ) { // no preset target or curr target is not on this body
    set selectedName to guiUserSelect("Please select site", targetSiteList).
    set target to vessel(selectedName).      
  }
  local tSite to body:geopositionlatlng(target:geoposition:lat,target:geoposition:lng).
  local lSite to circle_destination(tSite, 90, 5, body:radius). // 5m east...I think.
  site:add("lat", lSite:lat).
  site:add("lng", lSite:lng).
}

function selectFromDistance {
  local distance to 0.
  until (distance > 0 and distance <= 100 ) set distance to guiUserInput("Enter Distance in km (1-100)"):tonumber.
  local siteLoc to circle_destination(ship:geoposition, -ship:bearing, distance*1000 ,body:radius).
  site:add("lat", siteLoc:lat).
  site:add("lng", siteLoc:lng).
}