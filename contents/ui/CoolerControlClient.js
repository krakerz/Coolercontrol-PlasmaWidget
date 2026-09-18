.pragma library

function login(baseUrl, username, password, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", baseUrl + "/login");
    xhr.setRequestHeader("Authorization", "Basic " + Qt.btoa(username + ":" + password));
    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            callback(xhr.status === 200, xhr.status);
        }
    };
    xhr.send();
}

function fetchJson(method, url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url);
    xhr.onreadystatechange = function () {
        if (xhr.readyState !== XMLHttpRequest.DONE) {
            return;
        }
        if (xhr.status === 200) {
            try {
                callback(true, JSON.parse(xhr.responseText), xhr.status);
            } catch (e) {
                callback(false, null, xhr.status);
            }
        } else {
            callback(false, null, xhr.status);
        }
    };
    xhr.send();
}

function fetchDevices(baseUrl, callback) {
    fetchJson("GET", baseUrl + "/devices", callback);
}

function fetchStatus(baseUrl, callback) {
    fetchJson("GET", baseUrl + "/status", callback);
}

// Merges static device/channel labels (from /devices) with the latest live
// reading (from /status) into a flat list of display-ready sensor entries.
function buildSensors(deviceInfoByUid, statusJson) {
    var sensors = [];
    if (!statusJson || !statusJson.devices) {
        return sensors;
    }

    statusJson.devices.forEach(function (dev) {
        var info = deviceInfoByUid[dev.uid];
        if (!info) {
            return;
        }
        var hist = dev.status_history;
        if (!hist || hist.length === 0) {
            return;
        }
        var latest = hist[hist.length - 1];
        var deviceName = info.name;
        var deviceType = info.type;
        var tempLabels = (info.info && info.info.temps) || {};
        var chanLabels = (info.info && info.info.channels) || {};

        (latest.temps || []).forEach(function (t) {
            var li = tempLabels[t.name];
            var label = (li && li.label) ? li.label : t.name;
            sensors.push({
                key: dev.uid + ':temp:' + t.name,
                device: deviceName,
                deviceType: deviceType,
                label: label,
                value: t.temp,
                unit: '°C',
                display: t.temp.toFixed(1) + '°C'
            });
        });

        (latest.channels || []).forEach(function (c) {
            var li = chanLabels[c.name];
            var baseLabel = (li && li.label) ? li.label : c.name;

            if (c.rpm !== undefined) {
                sensors.push({
                    key: dev.uid + ':chan:' + c.name + ':rpm',
                    device: deviceName,
                    deviceType: deviceType,
                    label: baseLabel + ' RPM',
                    value: c.rpm,
                    unit: 'RPM',
                    display: c.rpm + ' RPM'
                });
            }
            if (c.duty !== undefined) {
                sensors.push({
                    key: dev.uid + ':chan:' + c.name + ':duty',
                    device: deviceName,
                    deviceType: deviceType,
                    label: baseLabel + ' Duty',
                    value: c.duty,
                    unit: '%',
                    display: c.duty.toFixed(0) + '%'
                });
            }
            if (c.watts !== undefined) {
                sensors.push({
                    key: dev.uid + ':chan:' + c.name + ':watts',
                    device: deviceName,
                    deviceType: deviceType,
                    label: baseLabel,
                    value: c.watts,
                    unit: 'W',
                    display: c.watts.toFixed(1) + ' W'
                });
            }
            if (c.freq !== undefined) {
                sensors.push({
                    key: dev.uid + ':chan:' + c.name + ':freq',
                    device: deviceName,
                    deviceType: deviceType,
                    label: baseLabel,
                    value: c.freq,
                    unit: 'MHz',
                    display: c.freq + ' MHz'
                });
            }
        });
    });

    return sensors;
}
