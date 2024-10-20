m = Map("qmodem", translate("Slot Configuration"))
m.redirect = luci.dispatcher.build_url("admin", "network", "qmodem","settings")

s = m:section(NamedSection, arg[1], "modem-device", "")

slot_type = s:option(ListValue, "type", translate("Slot Type"))
slot_type:value("usb", translate("USB"))
slot_type:value("pcie", translate("PCIE"))

slot = s:option(Value, "slot", translate("Slot ID"))


local pcie_slots = io.popen("ls /sys/bus/pci/devices/")
for line in pcie_slots:lines() do
    slot:value(line,line.."[pcie]")
end
pcie_slots:close()



sim_led = s:option(Value, "sim_led", translate("SIM LED"))
sim_led.rmempty = true


net_led = s:option(Value, "net_led", translate("NET LED"))
net_led.rmempty = true
local leds = io.popen("ls /sys/class/leds/")
for line in leds:lines() do
    net_led:value(line,line)
    sim_led:value(line,line)
end

ethernet_5g = s:option(Value, "ethernet_5g", translate("Enable 5G Ethernet"))
ethernet_5g.rmempty = true
ethernet_5g.description = translate("For 5G modules using the Ethernet PHY connection, please specify the network interface name. (e.g., eth0, eth1)") 
local net = io.popen("ls /sys/class/net/")
for line in net:lines() do
    ethernet_5g:value(line,line)
end
net:close()

associated_usb = s:option(Value, "associated_usb", translate("Associated USB"))
associated_usb.rmempty = true
associated_usb.description = translate("For M.2 slots with both PCIe and USB support, specify the associated USB port (for ttyUSB access)")
associated_usb:depends("type", "pcie")
local usb_slots = io.popen("ls /sys/bus/usb/devices/")
for line in usb_slots:lines() do
    if not line:match("usb%d+") then
        slot:value(line,line.."[usb]")
        associated_usb:value(line,line)
    end
    
end
usb_slots:close()
return m