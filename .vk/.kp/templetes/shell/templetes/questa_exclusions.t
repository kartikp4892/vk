coverage exclude -src $env(BASE_DIR)/fpga/dofia24/microsemi/hdl/5_OFIA.vhd -scope /tb_top/ofia_2_i/OFIA_CORE -feccondrow 3634 4
coverage exclude -src $env(BASE_DIR)/fpga/dofia24/microsemi/hdl/5_OFIA.vhd -scope /tb_top/ofia_2_i/OFIA_CORE/ADCIU_enhanced_generate/ADCIU -fecexprrow 1728 1
coverage exclude -src $env(BASE_DIR)/fpga/dofia24/microsemi/hdl/6a_HFL_pkg.vhd -line 705 -code s
coverage exclude -scope /tb_top/ofia_2_i -togglenode iresp_flt
