vlib work

vcom -93 alu.vhd
vcom -93 banc_registr.vhd
vcom -93 multip2v1.vhd
vcom -93 multip4v1.vhd
vcom -93 ext_signe.vhd
vcom -93 memoire.vhd
vcom -93 vic.vhd
vcom -93 registre32.vhd
vcom -93 registre32Ld.vhd
vcom -93 DataPath.vhd
vcom -93 MAE.vhd
vcom -93 arm.vhd
vcom -93 DE0_TOP.vhd

vcom -93 test_arm.vhd

vsim work.test_arm

add wave -position insertpoint  \
sim:/test_arm/clkt \
sim:/test_arm/rstt \
sim:/test_arm/irq0t \
sim:/test_arm/irq1t \
sim:/test_arm/res \
sim:/test_arm/arm_1/DataPath1/BancReg/Banc