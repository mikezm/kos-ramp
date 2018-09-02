// Library for managing mission goals. 
// Check/Set completion of goals.
// Stored in JSON file on local core.
// Goals can be set on any core on the current ship.
@lazyglobal off.

local mission_persist to "mission_goals.json".

// if you need to initialize mission goals beforehand.
function initMissionGoals {
    parameter _goals to list().
    LOCAL _mgs TO LEXICON().
    for _g in _goals _mgs:ADD(_g, false).
    if NOT(EXISTS(mission_persist)) WRITEJSON(_mgs, mission_persist).
}

// sets a mission goal
function setMissionGoal {
    parameter _g, _v.  // Goal :: Value (bool)
    parameter _core is 1.  // KOS core.
    local mission_goals to lexicon().
    switch to _core.
    IF EXISTS(mission_persist) SET mission_goals TO READJSON(mission_persist).
    if mission_goals:haskey(_g) set mission_goals[_g] to _v.
    else mission_goals:add(_g, _v).
    WRITEJSON(mission_goals, mission_persist).
}

// checks for mission goal safely. 
function checkMissionGoal {
    parameter _goal.
    if EXISTS(mission_persist) { 
        local mission_goals to READJSON(mission_persist).
        if mission_goals:haskey(_goal) return mission_goals[_goal].
    } else return false.
}

// purge the mission from local storage.
function missionAccomplished {
    deletepath(mission_persist).
}
