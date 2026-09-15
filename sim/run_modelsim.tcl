# ModelSim / Questa Simulation Script for Pipelined ARM Core
vlib work
vmap work work

# Compile RTL
vlog ../rtl/adder.v
vlog ../rtl/pc.v
vlog ../rtl/mux2to1.v
vlog ../rtl/mux2to1_4.v
vlog ../rtl/mux2to1_9.v
vlog ../rtl/mux3to1_32.v
vlog ../rtl/alu.v
vlog ../rtl/condition_check.v
vlog ../rtl/status_register.v
vlog ../rtl/register_file.v
vlog ../rtl/val2_generator.v
vlog ../rtl/controller.v
vlog ../rtl/hazard_unit.v
vlog ../rtl/forwarding_unit.v
vlog ../rtl/if_id_reg.v
vlog ../rtl/id_ex_reg.v
vlog ../rtl/ex_mem_reg.v
vlog ../rtl/mem_wb_reg.v
vlog ../rtl/if_stage.v
vlog ../rtl/id_stage.v
vlog ../rtl/ex_stage.v
vlog ../rtl/sram_controller.v
vlog ../rtl/sram_model.v
vlog ../rtl/arm_core.v

# Compile Testbench
vlog ../tb/instruction_memory.v
vlog ../tb/tb_arm.v

# Run Simulation
vsim -voptargs=+acc work.tb_arm
add wave -position insertpoint sim:/tb_arm/*
add wave -position insertpoint sim:/tb_arm/uut/*
run 6000ns
