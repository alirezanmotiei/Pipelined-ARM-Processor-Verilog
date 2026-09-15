# Vivado Simulation Script (Batch Mode)
create_project -force arm_pipelined_sim ./sim_proj -part xc7z010clg400-1

add_files [glob ../rtl/*.v]
add_files [glob ../tb/*.v]
set_property top tb_arm [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sim_1
launch_simulation -mode behavioral
run 6000ns
exit
