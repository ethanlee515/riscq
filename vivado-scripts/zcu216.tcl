global DSP_PERIOD
global DSP_FREQ
global PROJ_NAME
global BOARD
global TOP_MODULE
set BOARD zcu216
set DSP_PERIOD 2.000
set DSP_FREQ 500000000
set TOP_MODULE QubicSoc

proc create {SUFFIX} {
    puts ${SUFFIX}
    global PROJ_NAME
    global BOARD
    set PROJ_NAME riscq-${BOARD}-${SUFFIX}
    create_project ${PROJ_NAME} ./${PROJ_NAME} -part xczu49dr-ffvf1760-2-e -force

    global TOP_MODULE
    add_files ./rtl/${TOP_MODULE}.v
    add_files ./rtl/ClockInterface.v
    add_files [glob ./rtl/*.bin]
    # set_property file_type {Memory Initialization Files} [get_files [glob ./rtl/*.bin]]
    set_property file_type {Memory File} [get_files [glob ./rtl/*.bin]]

    global BOARD
    source ../vivado-scripts/plip.tcl
    source ../vivado-scripts/bd-${BOARD}.tcl
    create_riscq_bd

    add_files -fileset constrs_1 ../vivado-scripts/constraints-zcu216.xdc
}

proc synth {} {
    #set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
    # set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
    set_property STEPS.SYNTH_DESIGN.ARGS.GLOBAL_RETIMING on [get_runs synth_1]
    # set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
    # set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
    launch_runs synth_1
    wait_on_run synth_1
}

proc impl {} {
    set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
    set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
    set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
    launch_runs impl_1 -to_step write_bitstream
    wait_on_run impl_1
}

proc build {} {
    puts "start synthesis"
    synth

    puts "start implementation"
    impl
}

proc create_and_build {SUFFIX} {
    if {[catch {current_project} result]} {
        puts "no opened project"
    } else {
        close_project
    }
    create ${SUFFIX}
    build
}

proc rebuild {} {
    close_project
    create
    build
}

proc reopen {SUFFIX} {
    global BOARD
    set PROJ_NAME riscq-${BOARD}-${SUFFIX}
    open_project ./${PROJ_NAME}/${PROJ_NAME}.xpr
}

# set_param general.maxThreads 1