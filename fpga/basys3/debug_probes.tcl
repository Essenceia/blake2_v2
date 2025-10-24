# connect it to the internal net (hierarchical path must match netlist naming)
#connect_net -hierarchical -net [get_nets -hierarchical m_top/m_io/loopback_mode_q[0]] -objects [get_ports led_o[14]]
#connect_net -hierarchical -net [get_nets -hierarchical m_top/m_io/loopback_mode_q[1]] -objects [get_ports led_o[15]]

