// lib_gui offers interactive guis to allow for user input.
// all lib_gui functions are blocking. Meaning they will wait until finished 
// other events may be prevented from occuring if a gui is used.

@lazyglobal off.

// GUI settings

parameter guiX to 860.
parameter guiY to 340.
parameter guiSize to 180.

// yes and no buttons.
function guiUserYesNo {
  parameter gTitle.
  parameter yesInput to "yes". // adjustable button names
  parameter noInput to "no".
  local proceed to false.
  local uGuiClose to false.

  local uGui to GUI(guiSize).
  set uGui:x to guiX.
  set uGui:y to guiY.
  local uGuiTitle to uGui:addlabel(gTitle).
  set uGuiTitle:style:align to "center".
  set uGuiTitle:style:hstretch to true.

  local yesBtn to uGui:addbutton(yesInput).
  local noBtn to uGui:addbutton(noInput).
  set yesBtn:onclick to { set uGuiClose to true. set proceed to true. }.
  set noBtn:onclick to { set uGuiClose to true. }.

  uGui:show().
  wait until uGuiClose.
  uGui:hide().
  return proceed.
}

// text box for user input.
// returns "failed" is input is left blank or cancelled.
function guiUserInput {
  parameter gTitle.
  local inputText to "".
  local uGuiClose to false.

  local uGui to GUI(guiSize).
  set uGui:x to guiX.
  set uGui:y to guiY.
  local uGuiTitle to uGui:addlabel(gTitle).
  set uGuiTitle:style:align to "center".
  set uGuiTitle:style:hstretch to true.   
  local tField to uGui:addtextfield(inputText).
  local acceptBtn to uGui:addbutton("accept").
  set acceptBtn:onclick to { set inputText to tField:text. set uGuiClose to true.}.
  local cancelBtn to uGui:addbutton("cancel").
  set cancelBtn:onclick to { set inputText to "failed". set uGuiClose to true.}.

  uGui:show().
  set tField:onconfirm to {parameter s. set inputText to s. set uGuiClose to true.}.
  wait until uGuiClose.
  uGui:hide().
  if (inputText = "") set inputText to "failed".
  return inputText.
}

// simple launch gui
function guiLaunch {
  local _LAUNCH_NOW to false. 
  local uGui to GUI(guiSize).
  set uGui:x to guiX.
  set uGui:y to guiY.
  local launch_btn is uGui:ADDBUTTON("Launch").
  set launch_btn:ONCLICK to { SET _LAUNCH_NOW TO true. }.
  uGui:show().
  wait until _LAUNCH_NOW.
  uGui:hide().
}

// select menu
// returns value of selection.
function guiUserSelect {
  parameter gTitle.
  parameter opts. // list of options
  parameter cancelOpt to false. // add cancel option to list
  local uGuiClose to false.
  local uGuiSelection to "".

  local uGui to GUI(guiSize).
  set uGui:x to guiX.
  set uGui:y to guiY.
  local uGuiTitle to uGui:addlabel(gTitle).
  set uGuiTitle:style:align to "center".
  set uGuiTitle:style:hstretch to true.   
  local tMenu to uGui:addpopupmenu().

  tMenu:addoption("--select--").
  for opt in opts tMenu:addoption(opt).
  if cancelOpt tMenu:addoption("cancel"). 
  set tMenu:onchange to {parameter sel. set uGuiSelection to sel. set uGuiClose to true.}.

  uGui:show().
  wait until uGuiClose.
  uGui:hide().
  return uGuiSelection.
}

// radio button gui
function guiUserRadioBtn {
  parameter gTitle.
  parameter btns. // list of buttons and their functions.
  local uGuiClose to false.
  local btnDef to true.

  local uGui to GUI(guiSize).
  set uGui:x to guiX.
  set uGui:y to guiY.
  local uGuiTitle to uGui:addlabel(gTitle).
  set uGuiTitle:style:align to "center".
  set uGuiTitle:style:hstretch to true. 

  for btn in btns {
    uGui:addradiobutton(btn, btnDef).
    if btnDef set btnDef to false.
  }
  local doneBtn to uGui:addbutton("done").
  set doneBtn:onclick to {set uGuiClose to true.}.

  uGui:show().
  wait until uGuiClose.
  uGui:hide().
  return uGui:radiovalue.
}