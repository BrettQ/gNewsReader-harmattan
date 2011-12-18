/*
    Copyright 2011 - Yogeshwar Padhyegurjar

    This file is part of gNewsReader.

    gNewsReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    gNewsReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with gNewsReader. If not, see <http://www.gnu.org/licenses/>.
*/

function urlChanged(url) {
    flickableLogin.contentX = 0;
    flickableLogin.contentY = 0;
}

function loadComplete(title, url) {
    var code = "";
    var mUrl = url.toString();
    var mTitle = title.toString();

    if (mUrl.indexOf("https://accounts.google.com/o/oauth2/approval") > -1 && mTitle.indexOf("code=") > -1) {
        code = mTitle.split("=")[1];
        if(code.indexOf(" ") > -1) code = code.split(" ")[0];
        console.log("Code obtained:"+ code);
        requestTempToken(code);
    }
}

function doXmlHttpRequest(method, url, params, callback) {
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4) {
            console.log("RESPONSE:"+req.responseText);
            callback(req.responseText);
        }
    }

    req.open(method, url);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    req.setRequestHeader("Content-Length", String(params.length));
    req.send(params);
}

function parseNewToken(data) {
    var result = JSON.parse(data);
    if (result.error == null) {
        var newtoken = result.access_token;
        var newRefreshToken = result.refresh_token;
        console.log("ACCESS TOKEN:"+newtoken);
        Storage.setSetting("token",newtoken);
        Storage.setSetting("refreshtoken", newRefreshToken);

        googleAuthPage.authComplete(newtoken, newRefreshToken);
    }
}

function requestTempToken(code) {
    var  params = "grant_type=authorization_code"+
              "&client_id="+Const.GOOGLE_CLIENT_ID+
              "&client_secret="+Const.GOOGLE_API_CLIENT_SECRET+
              "&code=" + code + "&redirect_uri="+Const.GOOGLE_REDIRECT_URL;

    doXmlHttpRequest("POST", Const.GOOGLE_API_TOKEN_URL, params, parseNewToken);
}




