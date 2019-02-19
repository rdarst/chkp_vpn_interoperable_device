#/bin/bash

# Name of new interoperable device
IDDevice="api_id"

# Name of Encryption Domain
network_name="net1"

# Name of Star VPN Community to add the Interoperable Device to
vpncommunity="vpntest"

# Login to the management server
SESSION=$(mgmt_cli login -u api_user -p vpn123 --format json |jq -r '.sid')
echo "Session is $SESSION"

# Grab the uid of the VPN Encryption Domain
vpn_enc_domain=$(mgmt_cli show-network name "$network_name" --format json --session-id $SESSION |jq '.uid')
echo "$network_name UID is $vpn_enc_domain"

# Create the new Interoperable Device
mgmt_cli add generic-object create "com.checkpoint.objects.classes.dummy.CpmiGatewayPlain" name "$IDDevice" ipaddr "172.16.1.254" thirdPartyEncryption "True" osInfo.osName "Gaia" vpn.create "com.checkpoint.objects.classes.dummy.CpmiVpn" vpn.owned-object.vpnClientsSettingsForGateway.create "com.checkpoint.objects.classes.dummy.CpmiVpnClientsSettingsForGateway" vpn.owned-object.vpnClientsSettingsForGateway.owned-object.endpointVpnClientSettings.create "com.checkpoint.objects.classes.dummy.CpmiEndpointVpnClientSettingsForGateway" vpn.owned-object.vpnClientsSettingsForGateway.owned-object.endpointVpnClientSettings.owned-object.endpointVpnEnable "True" vpn.owned-object.ike.create "com.checkpoint.objects.classes.dummy.CpmiIke" vpn.owned-object.sslNe.create "com.checkpoint.objects.classes.dummy.CpmiSslNetworkExtender" vpn.owned-object.sslNe.owned-object.sslEnable "False" vpn.owned-object.sslNe.owned-object.gwCertificate "defaultCert" vpn.owned-object.isakmpUniversalSupport "True" nat null snmp null dataSourceSettings null manualEncdomain $vpn_enc_domain encdomain "MANUAL" comments "Hello World Comments" --session-id $SESSION

# Publish the changes
mgmt_cli publish --session-id $SESSION

# Grab the UID of the new Interoperable Device
api_id=$(mgmt_cli show-generic-objects name "$IDDevice" --format json --session-id $SESSION | jq '.objects[].uid')
echo "$IDDevice UID is $api_id"

# Run the set on the new Interoperable Device
mgmt_cli set-generic-object uid $api_id color "RED" --session-id $SESSION

# Add the Interoperable Device to the VPN Community
mgmt_cli set vpn-community-star name "$vpncommunity" satellite-gateways "api_id" --session-id $SESSION

# Publish the changes
mgmt_cli publish --session-id $SESSION

# Use the commands below to compare the output of the json for each object where the Interoperable device created in the gui is named "gui_id"
# mgmt_cli show-generic-objects name $IDDevice details-level full --format json --session-id $SESSION > $IDDevice.json
# mgmt_cli show-generic-objects name "gui_id" details-level full --format json --session-id $SESSION > gui_id.json
# diff -y $IDDevice.json gui_id.json

# Logout
mgmt_cli logout --session-id $SESSION
