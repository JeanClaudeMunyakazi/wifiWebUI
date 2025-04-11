// wifiWebUI main frontend script
// ***************************************************************************


// set some user vars
const notificationDelay = 5500;
const notificationDelayLong = 100000;
const pingIntervall = 10000; // integer (miliseconds)
const pingURL = "/getData";
const pingTime = 100; // default value 100 will be overwritten after first ping
const serverURL = ""; // empty if API host is the same as webserver host
var freezeConfig = 0;


// set some system vars - Do not overwrite them!
var every10thError_getData


//
$(document).ready(function() {
	$("#status").hide();
		if ((freezeConfig === 0) && (!$("#custom, #wifi").is(":visible"))) {
			getConfig();
		}
	$("#status").fadeIn("fast");
});


$("#logoImage").click(function() {
	$("#defaultTab").click();
	$("html, body").animate({ scrollTop: "0px" });
});

$("#defaultTab").click(function() {
	getConfig();
});

$("#scanButton").click(function() {
	scanWifiNets();
});

$("#customButton").click(function() {
	$(this).prop("disabled", true);
	$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'none');
	$("html, body").animate({ scrollTop: "0px" });
	setData("customButton", "Custom", 1);
});

$("#rebootButton").click(function() {
	$(this).prop("disabled", true);
	$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'none');
	$("html, body").animate({ scrollTop: "0px" });
	setData("rebootButton", "Reboot", 1);
});

$("#wifiButton").click(function() {
	$(this).prop("disabled", true);
	$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'none');
	$("html, body").animate({ scrollTop: "0px" });
	setData("wifiButton", "Wifi", 1);
});



$("input, textarea").bind("focusin", function() {
	freezeConfig = 1;
});

$("input, textarea").bind("focusout", function() {
	freezeConfig = 0;
});


function setData(button, form, IntReload) {
	let json = ConvertFormToJSON($("#formFields" + form), form);
	let showInfo = true;
	$("#" + button).prop("disabled", false);

		$.ajax({
			type: "POST",
			url: "/set" + form,
			contentType: "application/json;charset=utf-8",
			dataType: "json",
			data: json,
			async: true,
			cache: false,
			timeout: 5000,

			beforeSend: function() {
				$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'none');
				if ((form == "Reboot") || (form == "Wifi")) {
					$.bootstrapGrowl('Rebooting wifiWebUI. Please wait...',{
						type: 'info',
						delay: notificationDelayLong,
					});
				}
				else {
					$.bootstrapGrowl('Saving changes and reloading wifiWebUI...',{
						type: 'info',
						delay: notificationDelay,
					});
				}
			},

			success: function (response) {
				if ((response._API_response_status === 200) && (form != "Reboot")) {
					setTimeout(function(){ $("#" + button).prop("disabled", false); }, 1000);
					$.bootstrapGrowl('Success: updating <strong>' + form + '<strong>',{
						type: 'success',
						delay: notificationDelay,
					});
					if (IntReload === 1) {
						setTimeout(function(){ location.reload(); }, 1000);
					}
				}
			},

			error: function () {
				if (form == "Wifi") {
					let reloadInterval = setInterval(function() {
					let url  = 'http://' + window.location.hostname;
					clearInterval(reloadInterval);
						if (showInfo) {
							showInfo = false;
							$.bootstrapGrowl('Reloading wifiWebUI on address:<br/>' + url,  {
								type: 'info',
								delay: notificationDelayLong,
							});
						}
					window.location.replace(url);
					}, 3000);
				}
				if ((form == "Reboot") || (form == "Wifi")) {
					setInterval(function() {
						pingAndReboot();
					}, 3000);
				}
				else {
					$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'initial');
					$.bootstrapGrowl('Network status:<br/>ERROR<br/>Cannot read data from API server. Please check if the API service is running on your device (e.g. raspberry pi) and press reload in your browser to try again.', {
						type: 'danger',
						delay: notificationDelayLong,
					});
				}
			}
		});
}


function pingAndReboot() {
	$.ajax({
		type: "GET",
		url: "/getData",
		contentType: "application/json;charset=utf-8",
		dataType: "json",
		async: true,
		cache: false,
		timeout: 3000,
			success: function () {
				let url  = "http://" + window.location.hostname;
				window.location.replace(url);
				return 1;
			},
			error: function () {
				return 0;
		}
	});
}


function ConvertFormToJSON(form, formName) {
	let array = $(form).serializeArray();
	let json = {};

	jQuery.each(array, function() {
		json[this.name] = this.value || '';
	});
/*
	if (formName == "Audio") {
		json.volume = $("#volume").slider('getValue');
	}
*/
	return JSON.stringify(json);
}


function getCurrentDateAndTime() {
	var now = new Date();

	var day = now.getDate();
	var month = now.getMonth() + 1;
	var year = now.getFullYear();
	var hour =  now.getHours();
	var minute =  now.getMinutes();
	var second =  now.getSeconds();

	if (month.toString().length < 2) month = '0' + month;
	if (hour.toString().length < 2) hour = '0' + hour;
	if (minute.toString().length < 2) minute = '0' + minute;
	if (second.toString().length < 2) second = '0' + second;

	return (day + '.' + month + '.' + year + " " + hour + ":" + minute + ":" + second)
}


function getConfig() {

	$.ajax({
		type: "GET",
		url: "/getData",
		contentType: "application/json;charset=utf-8",
		dataType: "json",
		async: true,
		cache: false,
		timeout: 10000, // milliseconds

		beforeSend: function() {
			$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'none');
			$("#statusContent, #statusWifiConnection, #statusLastUpdated, #networkDevices").html('');

			$.bootstrapGrowl('Retrieving<br/>Network status...', {
				type: 'info',
				delay: notificationDelay,
			});
		},

		success: function (getConfig) {
			$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'initial');

			$.bootstrapGrowl('Successfully updated<br/>Network status', {
				type: 'success',
				delay: notificationDelay,
			});
	
			$("#deviceName").val(getConfig.config.custom.deviceName);
			$("#color").val(getConfig.config.custom.color);
			$("#ssid").val(getConfig.config.wifi.ssid);
			$("#psk").val(getConfig.config.wifi.psk);

			$.each(getConfig.status.network.devices, function (key, value) {
				let device = "";
				device +="<tr>";
				device +="<td>"+value.name+"</td>";
				device +="<td>"+value.abilities+"</td>";
				device +="<td>"+value.brd+"</td>";
				device +="<td>"+value.ip+"</td>";
				device +="<td>"+value.mtu+"</td>";
				device +="<td>"+value.netmask+"</td>";
				device +="<td>"+value.qlen+"</td>";
				device +="<td>"+value.state+"</td>";
				device +="</tr>";
				document.getElementById("networkDevices").innerHTML += device;
			});

			if (getConfig.status.network.wifi.connectionStatus == 'online') {
				var dateTime = getCurrentDateAndTime();
				$("#statusLastUpdated").html('Last updated: ' + dateTime);
				$("#statusContent").html('<h3>Current wifi connection</h3><div id="statusWifiConnection"><span class="online">online</span></div><ul id="currentWifiParameter" class="list-unstyled"><li id="statusESSID"></li><li id="statusFrequency"></li><li id="statusRSSI"></li><li id="statusTxBitrate"></li><li id="statusRxBitrate"></li><li id="statusConnectedTime"></li></ul>');
				$("#statusESSID").html('<span>SSID: </span>' + getConfig.status.network.wifi.ESSID);
				$("#statusFrequency").html('<span>Frequency: </span>' + getConfig.status.network.wifi.frequency);
				$("#statusRSSI").html('<span>Signal level (RSSI): </span>' + getConfig.status.network.wifi.RSSI);
				$("#statusTxBitrate").html('<span>Tx bitrate: </span>' + getConfig.status.network.wifi.txBitrate);
				$("#statusRxBitrate").html('<span>Rx bitrate: </span>' + getConfig.status.network.wifi.rxBitrate);
				var date = new Date(null);
				date.setSeconds(parseInt(getConfig.status.network.wifi.connectedTime));
				var result = date.toISOString().substr(11, 8);
				$("#statusConnectedTime").html('<span>Connected time: </span>' + result);
			}

			if (getConfig.status.network.wifi.connectionStatus == 'offline') {
				var dateTime = getCurrentDateAndTime();
				checkSSIDAvailability(getConfig.config.wifi.ssid);
				$("#statusLastUpdated").html('Last updated: ' + dateTime);
				$("#statusContent, #statusESSID, #statusFrequency, #statusRSSI, #statusTxBitrate, #statusRxBitrate, #statusConnectedTime").html('');

				let SSID = checkForWhiteSpace(getConfig.config.wifi.ssid);
				if (SSID[1]) {
					SSID[0] = "<div id='currentESSID'>" + SSID[0] + "</div><br/><p>The SSID contains unnecessary whitespace. Please check your <strong>SSID</strong>. The whitepace is marked red: <span class='showWhiteSpaceExample'>&nbsp;</span></p>";
				}
				else {SSID[0] = "<div id='currentESSID'>" + getConfig.config.wifi.ssid + "</div>";}
				$("#statusContent").html('<h3>Current wifi connection</h3><div id="statusWifiConnection"><span class="offline">offline</span></div><p>Cannot connect to SSID: ' + SSID[0] + '</p><div id="availabilityStatus"></div><p>Please go to <strong>settings</strong> => <strong>wifi</strong> and check your <strong>SSID</strong> and your <strong>pre shared key</strong> (PSK or password)</p>');
			}
		},

		error: function () {
				$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'initial');
				$.bootstrapGrowl('Network status:<br/>ERROR<br/>Cannot read data from API server. Please check if the API service is running on your device (e.g. raspberry pi) and press reload in your browser to try again.', {
					type: 'danger',
						delay: notificationDelayLong,
				});
				console.log("Could not get config.");
		}
	});
}


function checkForWhiteSpace(str) {
	var regex1 = str.replace(/^\s+/i, "<span class='showWhiteSpace'>&nbsp;</span>");
	var regex2 = regex1.replace(/\s+$/i, "<span class='showWhiteSpace'>&nbsp;</span>");

	var results = [];
    results[0] = regex2;
	results[1] = 0;
		if (results[0].match(/showWhiteSpace/i)) {
			results[1] = 1;
		}
		else {
			results[1] = 0;
		}
	return results;
}


function scanWifiNets() {

	$.ajax({
		type: "GET",
		url: "/getWifiNets",
		contentType: "application/json;charset=utf-8",
		dataType: "json",
		async: true,
		cache: false,
		timeout: 10000, // milliseconds

		beforeSend: function() {
			$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'none');
			$("#statusContent, #statusWifiConnection, #scanLastUpdated, #availableWifiNetworks").html('');

			$.bootstrapGrowl('Scanning<br/>Available wifi networks...', {
				type: 'info',
				delay: notificationDelay,
			});
		},

		success: function (scanWifiNets) {
			var dateTime = getCurrentDateAndTime();
			$("#scanLastUpdated").html('Last updated: ' + dateTime + '<hr />');
			$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'initial');

			$.bootstrapGrowl('Scan finished<br/>successfully', {
				type: 'success',
				delay: notificationDelay,
			});

			var availableWifiNetworks = scanWifiNets.availableWifiNetworks;
			availableWifiNetworks.sort();
			var hiddenESSIDs = scanWifiNets.hiddenESSIDs;
			var list = '<ol>'

				availableWifiNetworks.forEach(function(network) {
					list += '<li>'+ network + '</li>';
				});
				list += '</ol>';

			if (hiddenESSIDs === 0)	{ hiddenESSIDMessage = "<br/><p>There are <strong>no</strong> hidden ESSIDs in your area.";}
			if (hiddenESSIDs === 1)	{ hiddenESSIDMessage = "<br/><p>There is <strong>" + hiddenESSIDs + "</strong> hidden ESSID in your area.";}
			if (hiddenESSIDs > 1)	{ hiddenESSIDMessage = "<br/><p>There are <strong>" + hiddenESSIDs + "</strong> hidden ESSIDs in your area.";}
			$("#availableWifiNetworks").html("<h3>Available SSIDs</h3><p>Click on a SSID to connect.</p><br/>" + list + hiddenESSIDMessage);

			$("#availableWifiNetworks ol li").click(function() {
				$(".dropdown-item[href*='wifi']").click();
				$("#ssid").val($(this).text());
				$("#psk").val('');
				setTimeout(function(){ $("input#psk").focus(); }, 500);
		 	});
		},

		error: function () {
			var dateTime = getCurrentDateAndTime();
			$("#scanLastUpdated").html('Last updated: ' + dateTime);
			$("#logoImage, .nav-link, .dropdown, .nav-item, button").css('pointer-events', 'initial');

			$.bootstrapGrowl('Network status:<br/>ERROR<br/>Cannot read data from API server. Please check if the API service is running on your device (e.g. raspberry pi) and press reload in your browser to try again.', {
				type: 'danger',
					delay: notificationDelayLong,
			});
			console.log("Could not get scan results.");
		}
	});
}


function checkSSIDAvailability(SSID) {

	$.ajax({
		type: "GET",
		url: "/checkSSIDAvailability",
		contentType: "application/json;charset=utf-8",
		dataType: "json",
		async: true,
		cache: false,
		timeout: 10000, // milliseconds

		beforeSend: function() {
			$("#availabilityStatus").html('');
			$.bootstrapGrowl('Scanning<br/>Checking if SSID <strong>' + SSID + '</strong> is available...', {
				type: 'info',
				delay: notificationDelay,
			});
		},

		success: function (testResult) {
			$("#availabilityStatus").html('<p>SSID <strong>' + SSID + '</strong> is ' + testResult.availability + ' in your area.</p>');
		},

		error: function () {
			$.bootstrapGrowl('Network status:<br/>ERROR<br/>Cannot read data from API server. Please check if the API service is running on your device (e.g. raspberry pi) and press reload in your browser to try again.', {
				type: 'danger',
					delay: notificationDelayLong,
			});
			console.log("Could not get scan results.");
		}
	});
}


async function getData(HTTPmethod,serverURL,endpoint) {
	let result;
	let API_URL = serverURL + endpoint;

	try {
		result = await $.ajax({
			type: HTTPmethod,
			url: API_URL,
			contentType: "application/json;charset=utf-8",
			dataType: "json",
			async: true,
			cache: false,
			timeout: 3000, // milliseconds

			success: function () {
				if (every10thError_getData === 2) {
					$.bootstrapGrowl('Network status:<br/><strong>OK</strong>', {
						type: 'success',
						delay: notificationDelay,
					});
					every10thError_getData = 0;
				}
				if (every10thError_getData > 10) {
					$.bootstrapGrowl('Network status:<br/><strong>RECONNECTED</strong>', {
						type: 'success',
						delay: notificationDelay,
					});
					every10thError_getData = 0;
				}
			}
		});
		every10thError_getData = 0;
		return result;
	}
	catch (error) {
		every10thError_getData++;
		if (every10thError_getData % 40 == 0 && every10thError_getData != 0) {
			$.bootstrapGrowl('Network status:<br/>ERROR<br/>Cannot read data from API server. Please check if the API service is running on your device (e.g. raspberry pi).', {
				type: 'warning',
					delay: notificationDelay,
			});
		}
	}
}


// EOF