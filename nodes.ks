// Executes one or more nodes. 
// Promtes for decision. 
parameter _exec_all_nodes TO false.
parameter _exec_wait_time to 3.
run once lib_ui.
run once lib_util.

IF ALLNODES:LENGTH > 1 {
    // if more than one node.
    // prompt for decision    
    LOCAL _startTime to time.
    lock _timeExp to ( (time - _startTime) > _exec_wait_time ).  
    LOCAL nodesGui TO GUI(200).
    LOCAL nodes_label TO nodesGui:ADDLABEL("Which node(s) to execute?").
    LOCAL nodesGuiClose TO false.
    SET nodes_label:STYLE:ALIGN TO "CENTER".
    SET nodes_label:STYLE:HSTRETCH TO True. // Fill horizontally
    LOCAL _nodesExecAllBtn TO nodesGui:ADDBUTTON("All").
    SET _nodesExecAllBtn:ONCLICK TO { SET nodesGuiClose TO True. SET _exec_all_nodes TO true. }.
    LOCAL _nodesExecNextBtn TO nodesGui:ADDBUTTON("Next").
    SET _nodesExecNextBtn:ONCLICK TO { SET nodesGuiClose TO True. SET _exec_all_nodes TO false. }.
    nodesGui:Show().
    wait until (nodesGuiClose OR _timeExp).
    nodesGui:Hide().
    if _exec_all_nodes {
        LOCAL nodesDone TO false.
        until nodesDone {
            uiBanner("node exec", "Next node execution in 2 seconds."). wait 2.
            run node.
            SET nodesDone TO ( NOT(HASNODE) OR utilNodeFault ).
        }
    } else {
        run node.
    }
} ELSE IF ALLNODES:LENGTH = 1 {
   run node.
}
