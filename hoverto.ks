parameter siteLat, siteLng, legHeight.
parameter landingSiteAccuracy to 25. // how accurate do we have to be at landing.

run once lib_hover.
run once lib_parts.
run once lib_ui.

local rcsState to rcs.
local sasState to sas.
sas off.
rcs on.

local altRadarAdj to legHeight.
global landingSite to body:geopositionlatlng(siteLat, siteLng).
global thrott to 0.
local steerDir to 90.
local shipPitch to 90.
local hoverDone to false.
local shipDist to 0.
local impactDist to 0.
local maxHorizSpdLmt to 0.
global landingSiteHeight to latlng(landingSite:lat, landingSite:lng):terrainheight.// hieght at landing site
global altAdj to 30. // set this to -1 to land, else height in m.
global safeAlt to 0.0. 
global terrainAdj to 0. // used to avoid terrain in front.
global dSpd to -30.
global hSpd to 20.
global sAng to 15.
lock throttle to thrott.
lock steering to heading(steerDir,shipPitch).
lock safeAlt to altRadarAdj + altAdj + landingSiteHeight + terrainAdj. // alt above terrain at which to hover.

setHoverPIDLOOPS().
setHoverAltitude(ship:altitude+40).
setHoverTarget(landingSite:LAT,landingSite:LNG). 
setHoverMaxSteerAngle(sAng).
setHoverMaxHorizSpeed(10).

global runmode to "start".
if not(ship:status:contains("LANDED") or ship:status:contains("PRELAUNCH")) set runmode to "hover-to".
until hoverDone {
    wait 0.01.
    set shipDist to calcDistance(landingSite, ship:geoposition).
    set maxHorizSpdLmt to min(150, 40*availtwr()).

    if runmode:contains("start") {
        if alt:radar > 20 {
            set sAng to 30.
            set hSpd to 45.
                        
            gear off.
            setMode("hover-to").           
        }
    }

    if runmode:contains("hover-to") {        
        // momentum/100 factor for speed. min 10. helps larger craft slow down at site.
        local momAdj to min(25, max(10, ship:mass*ship:groundspeed/100)). 
        // horizontal speed is relative to site distance adjusted for craft momentum.
        set hSpd to min(maxHorizSpdLmt, max(10, shipDist/momAdj)).  

        // set vertical vel speed.
        local altToTgtHt to min(10, abs(ship:altitude-safeAlt)).
        if (ship:altitude<safeAlt)  set dSpd to min(-altToTgtHt, max(-10, (ship:altitude-safeAlt)/10)).
        else set dSpd to min(altToTgtHt, max(0, (ship:altitude-safeAlt)/10)).

        // don't lean too far foward if we're close to the ground and 
        // far enough from the site to be picking up too much speed.
        // basically make sure we don't hit the ground by mistake....
        if (alt:radar<altAdj) and shipDist>450 set sAng to 10.
        else set sAng to 30.
     
        // lib_hover:watchInFront 
        // adjusts 'terrainAdj' based on terrain readings ahead.
        // flies over obstacles ahead.
        watchInFront(landingSiteHeight).  // lib_hover
        if (
            shipDist <= 40 and
            ship:altitude > safeAlt and
            alt:radar >= altAdj
        ) {
            setMode("land"). 
            gear on.           
        }
    }

    if runmode:contains("land") {
        if (ship:groundspeed<=10) set altAdj to 10.
        else set altAdj to 20. // 50
        if (safeAlt<ship:altitude) set dSpd to min(5, max(10, alt:radar/10)). //10
        else set dSpd to 0.
        set hSpd to min(10,max(5, shipDist)).
        if shipDist<=10 and ship:groundspeed<=5 { // (ship:verticalspeed >= -20)  and errDist<=10
            set dSpd to 5. 
            set altAdj to 5.
            setMode("touch-down").
            //gear on.
        }  
        
    }

    if runmode:contains("touch-down") {
        //setHoverTarget(ship:geoposition:lat,ship:geoposition:lng).
        set dSpd to max(5, min(10, alt:radar/2)).
        if shipDist<=max(2, landingSiteAccuracy) {
            set altAdj to -10.
            set dSpd to max(1, min(5, alt:radar/2)).
        }
    }

    set hoverDone to (
        (ship:status:contains("LANDED") or ship:status:contains("SPLASHED")) and
        calcDistance(landingSite, ship:geoposition) < 50
    ).

    
        
    setHoverAltitude(safeAlt).
    setHoverMaxSteerAngle(sAng).
    setHoverDescendSpeed(dSpd).
    setHoverMaxHorizSpeed(hSpd).
    updateHoverSteering().
    
    print "momentum%   : " + max(10, ship:mass*ship:groundspeed/100) at (5,24).
    print "Angle       : " + sAng at (5,25).
    print "TWR         : " + availtwr() at (5,26).
    print "max H       : " + maxHorizSpdLmt at (5,27).
    print "shipDist    : " + shipDist at (5,28).
    print "target alt  : " + safeAlt at (5,29).
    print "site height : " + landingSiteHeight at (5,30).
    print "curr alt    : " + ship:altitude at (5,31).
    print "h-speed     :                 " at (5,32).
    print "d-speed     :                 " at (5,33).
    print "h-speed     : " + round(hSpd) at (5,32).
    print "d-speed     : " + round(dSpd) at (5,33).
    
}

set thrott to 0.
unlock throttle.
unlock steering.
unlock momentum.
unlock safeAlt.
set ship:control:neutralize to true.
set ship:control:PILOTMAINTHROTTLE to 0.
brakes on.

set rcs to rcsState.
set sas to sasState.

function setMode {
	parameter mode.
	set runmode to mode.
	uiDebug(mode).
}
