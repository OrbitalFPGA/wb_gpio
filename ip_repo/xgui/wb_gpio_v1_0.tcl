
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/wb_gpio_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DEFAULT_GPIO_DIRECTION_FULL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DEFAULT_GPIO_OUTPUT_FULL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IP_DEVICE_ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IP_VERSION" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WB_ADDRESS_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "WB_BASE_ADDRESS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WB_DATA_GRANULARITY" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "WB_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "WB_REGISTER_ADDRESS_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.WB_SEL_WIDTH { PARAM_VALUE.WB_SEL_WIDTH PARAM_VALUE.WB_DATA_WIDTH PARAM_VALUE.WB_DATA_GRANULARITY } {
	# Procedure called to update WB_SEL_WIDTH when any of the dependent parameters in the arguments change
	
	set WB_SEL_WIDTH ${PARAM_VALUE.WB_SEL_WIDTH}
	set WB_DATA_WIDTH ${PARAM_VALUE.WB_DATA_WIDTH}
	set WB_DATA_GRANULARITY ${PARAM_VALUE.WB_DATA_GRANULARITY}
	set values(WB_DATA_WIDTH) [get_property value $WB_DATA_WIDTH]
	set values(WB_DATA_GRANULARITY) [get_property value $WB_DATA_GRANULARITY]
	set_property value [gen_USERPARAMETER_WB_SEL_WIDTH_VALUE $values(WB_DATA_WIDTH) $values(WB_DATA_GRANULARITY)] $WB_SEL_WIDTH
}

proc validate_PARAM_VALUE.WB_SEL_WIDTH { PARAM_VALUE.WB_SEL_WIDTH } {
	# Procedure called to validate WB_SEL_WIDTH
	return true
}

proc update_PARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL { PARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL } {
	# Procedure called to update DEFAULT_GPIO_DIRECTION_FULL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL { PARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL } {
	# Procedure called to validate DEFAULT_GPIO_DIRECTION_FULL
	return true
}

proc update_PARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL { PARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL } {
	# Procedure called to update DEFAULT_GPIO_OUTPUT_FULL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL { PARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL } {
	# Procedure called to validate DEFAULT_GPIO_OUTPUT_FULL
	return true
}

proc update_PARAM_VALUE.IP_DEVICE_ID { PARAM_VALUE.IP_DEVICE_ID } {
	# Procedure called to update IP_DEVICE_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IP_DEVICE_ID { PARAM_VALUE.IP_DEVICE_ID } {
	# Procedure called to validate IP_DEVICE_ID
	return true
}

proc update_PARAM_VALUE.IP_VERSION { PARAM_VALUE.IP_VERSION } {
	# Procedure called to update IP_VERSION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IP_VERSION { PARAM_VALUE.IP_VERSION } {
	# Procedure called to validate IP_VERSION
	return true
}

proc update_PARAM_VALUE.WB_ADDRESS_WIDTH { PARAM_VALUE.WB_ADDRESS_WIDTH } {
	# Procedure called to update WB_ADDRESS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WB_ADDRESS_WIDTH { PARAM_VALUE.WB_ADDRESS_WIDTH } {
	# Procedure called to validate WB_ADDRESS_WIDTH
	return true
}

proc update_PARAM_VALUE.WB_BASE_ADDRESS { PARAM_VALUE.WB_BASE_ADDRESS } {
	# Procedure called to update WB_BASE_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WB_BASE_ADDRESS { PARAM_VALUE.WB_BASE_ADDRESS } {
	# Procedure called to validate WB_BASE_ADDRESS
	return true
}

proc update_PARAM_VALUE.WB_DATA_GRANULARITY { PARAM_VALUE.WB_DATA_GRANULARITY } {
	# Procedure called to update WB_DATA_GRANULARITY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WB_DATA_GRANULARITY { PARAM_VALUE.WB_DATA_GRANULARITY } {
	# Procedure called to validate WB_DATA_GRANULARITY
	return true
}

proc update_PARAM_VALUE.WB_DATA_WIDTH { PARAM_VALUE.WB_DATA_WIDTH } {
	# Procedure called to update WB_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WB_DATA_WIDTH { PARAM_VALUE.WB_DATA_WIDTH } {
	# Procedure called to validate WB_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH { PARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH } {
	# Procedure called to update WB_REGISTER_ADDRESS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH { PARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH } {
	# Procedure called to validate WB_REGISTER_ADDRESS_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.WB_ADDRESS_WIDTH { MODELPARAM_VALUE.WB_ADDRESS_WIDTH PARAM_VALUE.WB_ADDRESS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WB_ADDRESS_WIDTH}] ${MODELPARAM_VALUE.WB_ADDRESS_WIDTH}
}

proc update_MODELPARAM_VALUE.WB_BASE_ADDRESS { MODELPARAM_VALUE.WB_BASE_ADDRESS PARAM_VALUE.WB_BASE_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WB_BASE_ADDRESS}] ${MODELPARAM_VALUE.WB_BASE_ADDRESS}
}

proc update_MODELPARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH { MODELPARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH PARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH}] ${MODELPARAM_VALUE.WB_REGISTER_ADDRESS_WIDTH}
}

proc update_MODELPARAM_VALUE.WB_DATA_WIDTH { MODELPARAM_VALUE.WB_DATA_WIDTH PARAM_VALUE.WB_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WB_DATA_WIDTH}] ${MODELPARAM_VALUE.WB_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.WB_DATA_GRANULARITY { MODELPARAM_VALUE.WB_DATA_GRANULARITY PARAM_VALUE.WB_DATA_GRANULARITY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WB_DATA_GRANULARITY}] ${MODELPARAM_VALUE.WB_DATA_GRANULARITY}
}

proc update_MODELPARAM_VALUE.IP_VERSION { MODELPARAM_VALUE.IP_VERSION PARAM_VALUE.IP_VERSION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IP_VERSION}] ${MODELPARAM_VALUE.IP_VERSION}
}

proc update_MODELPARAM_VALUE.IP_DEVICE_ID { MODELPARAM_VALUE.IP_DEVICE_ID PARAM_VALUE.IP_DEVICE_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IP_DEVICE_ID}] ${MODELPARAM_VALUE.IP_DEVICE_ID}
}

proc update_MODELPARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL { MODELPARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL PARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL}] ${MODELPARAM_VALUE.DEFAULT_GPIO_DIRECTION_FULL}
}

proc update_MODELPARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL { MODELPARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL PARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL}] ${MODELPARAM_VALUE.DEFAULT_GPIO_OUTPUT_FULL}
}

proc update_MODELPARAM_VALUE.WB_SEL_WIDTH { MODELPARAM_VALUE.WB_SEL_WIDTH PARAM_VALUE.WB_SEL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WB_SEL_WIDTH}] ${MODELPARAM_VALUE.WB_SEL_WIDTH}
}

