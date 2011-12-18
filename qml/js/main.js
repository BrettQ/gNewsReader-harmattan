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

var token = "";
var refreshToken = "";

function busyIndicatorStart() {
    window.busyInd = true
}

function busyIndicatorStop() {
    window.busyInd = false
}

function sendWebRequest(useToken, method, url, params, callback, caller, nextFunc, nextParams) {
    busyIndicatorStart()
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200 && status!=201) {
                console.log("Google API returned " + status + " " + doc.statusText);
                if(status == 401 && useToken) {
                    refreshTempToken(caller, nextFunc);
                } else {
                    pageInfoBanner.text = qsTr("Error Ocurred in Connection. Error Code:")+status
                    pageInfoBanner.open()
                    if(params.method !== undefined) {
                        if(params.method === "Instapaper") clearReadForLaterAuth("insta")
                        if(params.method === "ReadItLater") clearReadForLaterAuth("ril")
                    }
                }
            }
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if(doc.status == 200 || doc.status == 201) {
                if(nextFunc) {
                    callback(doc.responseText, nextFunc, nextParams);
                    busyIndicatorStop()
                } else {
                    callback(doc.responseText, params);
                    busyIndicatorStop()
                }
            } else {
                busyIndicatorStop()
            }
        }
    }

    doc.open(method, url);

    if(useToken && token == "") token = Storage.getSetting("token");

    if(useToken && token.length>0 && token != "Unknown") {
        doc.setRequestHeader("Authorization", "OAuth "+ token);
    }

    if(params != null) {
        var paramStr = params.param[0].name+"="+params.param[0].val;
        for(var i=1; i < params.param.length; i++) {
            paramStr = paramStr + "&" + params.param[i].name+"="+params.param[i].val;
        }

        doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        doc.setRequestHeader("Content-Length", String(paramStr.length));
        doc.send(paramStr);
    } else {
        doc.send();
    }
}

function refreshTempToken(caller, callerarg) {
    var  params = "grant_type=refresh_token"+
              "&client_id="+Const.GOOGLE_CLIENT_ID+
              "&client_secret="+Const.GOOGLE_API_CLIENT_SECRET+
            "&refresh_token="+Storage.getSetting("refreshtoken");

    doXmlHttpRequest("POST", Const.GOOGLE_API_TOKEN_URL, params, parseRefreshToken, caller, callerarg);
}

function doXmlHttpRequest(method, url, params, callback, caller, callerarg) {
    var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState == 4) {
            callback(req.responseText, caller, callerarg);
        }
    }

    req.open(method, url);
    req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    req.setRequestHeader("Content-Length", String(params.length));
    req.send(params);
}

function parseRefreshToken(data, caller, callerArg) {
    var result = null;
    try {
        console.log(data)
        result = JSON.parse(data);
    } catch(err) {
        console.log("Error while refreshing token"+err)
        infoMessage.text = qsTr("Error in connection to Google")
        busyIndicatorStop()

    }

    if (result != null && result.access_token) {
        console.log("Token Refreshed...")
        var newtoken = result.access_token;

        Storage.setSetting("token",newtoken);
        token = newtoken;
        //Retry caller function
        caller(callerArg)
    } //else clearAuthData() //Start fresh
}

function clearAuthData() {
    Storage.setSetting("token","Unknown");
    clearReadForLaterAuth("all")
    startApp(false)
}

function startApp(firstrun) {
    Storage.initialize();
    //Try to read already existing tokens
    token = Storage.getSetting("token");
    window.autoResizeImg = Storage.getSettingVal("autoResizeImg","true")
    window.showFullHtml = Storage.getSettingVal("showFullHtml","false")
    window.globalUnreadFilter = Storage.getSettingVal("globalUnreadFilter","false")
    window.useLightTheme = Storage.getSettingVal("useLightTheme","false")
    window.useBiggerFonts = Storage.getSettingVal("useBiggerFonts","false")
    window.autoLoadImages = Storage.getSettingVal("autoLoadImages","true")
    window.swipeGestureEnabled = Storage.getSettingVal("swipeGestureEnabled","true")
    console.log("Token:"+token);
    refreshToken = Storage.getSetting("refreshtoken");
    pageStack.clear()

    if (token === null || token === "Unknown") {
        //console.log("Going for Auth Page..");
        pageStack.replace(googleAuthPage); topMsgText.text = qsTr("Google Sign-In")
        googleAuthPage.urlString = "https://accounts.google.com/o/oauth2/auth?client_id="+Const.GOOGLE_CLIENT_ID+"&redirect_uri="+Const.GOOGLE_REDIRECT_URL+"&scope="+Const.GOOGLE_API_SCOPE+"&response_type=code"
    } else {
        // Token present, go for subsription page
        if(firstrun) gotoSubPage(true)//refreshTempToken(gotoSubPage, null)
        else gotoSubPage(false)
    }
}

function oAuthComplete(newtoken, newRefreshToken) {
    token = newtoken;
    refreshToken = newRefreshToken;
    googleAuthPage.urlString = "";
    gotoSubPage(false)
}

function gotoSubPage(isFirstRun) {
    if( subListModel != undefined && subListModel.count > 0 ) subListModel.clear()
    infoMessage.text = qsTr("Updating Subscriptions..")
//    pageStack.replace(subscrListPage)
    busyIndicatorStart()
    if(isFirstRun) refreshTempToken(getUnreadCounts, loadTags)
    else getUnreadCounts(loadTags)
    pageStack.replace(subscrListPage)
}

function refreshSubList(mode) {
    infoMessage.text = qsTr("Updating Subscriptions..")
    busyIndicatorStart()
    if(mode == "full") {
        //if( subListModel.count > 0 ) subListModel.clear()
        //Storage.clearTagSub()
        getUnreadCounts(loadTags)
    } else if(mode == "count") {
        getUnreadCounts(updateSubscriptions);
    }
}

function loadTags() {
    var url = "https://www.google.com/reader/api/0/tag/list?output=json&client=gNewsReader"
    sendWebRequest(true, "GET", url, null, parseTags, loadTags, loadSubscriptions, null)
}

function loadSubscriptions() {
    var url = "https://www.google.com/reader/api/0/subscription/list?output=json&client=gNewsReader";
    sendWebRequest(true, "GET", url, null, parseSubsriptions, loadSubscriptions, null, null);
}

function getUnreadCounts(nextFunction) {
    var url = "https://www.google.com/reader/api/0/unread-count?output=json&all=true&client=gNewsReader";
    sendWebRequest(true, "GET", url, null, parseUnreadCounts, getUnreadCounts, nextFunction, null);
}

function getCount(id) {
    if(Const.unreadCounts[id] != undefined && Const.unreadCounts[id] != null) return Const.unreadCounts[id].count;
    else return "";
}

function reduceCount(id, count) {
    if(Const.unreadCounts[id] != undefined && Const.unreadCounts[id] != null && Const.unreadCounts[id].count > 0) {
        Const.unreadCounts[id].count =  Const.unreadCounts[id].count - count;
        subscrListPage.isCountDirty = true
    }
}

function increaseCount(id, count) {
    if(Const.unreadCounts[id] != undefined && Const.unreadCounts[id] != null) {
        Const.unreadCounts[id].count =  Const.unreadCounts[id].count - count
    } else {Const.unreadCounts[id] = { "count": -count, "listIndex": -1 } }
    subscrListPage.isCountDirty = true
}

function parseUnreadCounts(unreadData, nextFunc, params) {
//    Const.unreadCounts = JSON.parse(unreadData)
    Const.unreadCounts = new Object;

    var unreadCountData = JSON.parse(unreadData);
    for(var i=0, il=unreadCountData.unreadcounts.length; i<il; i++) {
        var unreadTag = unreadCountData.unreadcounts[i];
        var id = unreadTag.id;
        var count = unreadTag.count;

        Const.unreadCounts[id] = { "count": count }
        //Storage.setTagSubCount(id, count)
    }
    if(nextFunc) nextFunc();
}

function parseTags(tagsData, nextFunc, params) {
    var tagList = JSON.parse(tagsData)
    Const.Tags = new Object()
    var title = null
    for(var i=0, il=tagList.tags.length; i<il; i++) {
        title = tagList.tags[i].id.substring(tagList.tags[i].id.lastIndexOf("/")+1);
        if(title == "starred") Const.updateUserPrefix(tagList.tags[i].id.substring(0, tagList.tags[i].id.indexOf("/state/com.google/starred")))
        Const.Tags[tagList.tags[i].id] = {"id":tagList.tags[i].id, "label":title, "subscriptions":null,"count":"", "cat":"tag"}
        //Storage.setTagSub(tagList.tags[i].id, title, tagList.tags[i].id, title, true, false)
    }
    Const.Tags["zzunknown"] = {"id":"zzunknown", "label":"Uncategorized", "subscriptions":null, "count":"", "cat":"tag"}
    //Storage.setTagSub("zzunknown", "Uncategorized", "zzunknown", "zzzzUncategorized", true, false)
    if(nextFunc) nextFunc();
}

function parseSubsriptions(subscriptionData, params) {
    var subList = JSON.parse(subscriptionData);
    var catid = null, cattitle = null
    for(var i=0, il=subList.subscriptions.length; i<il; i++) {
        var sub = subList.subscriptions[i];
        if(sub.categories && sub.categories[0]) {
            var strCats = JSON.stringify(sub.categories)
            for(var j = 0, ij=sub.categories.length; j < ij; j++) insertSubEntry(sub, sub.categories[j].id, sub.categories[j].label, strCats)
        } else {
            insertSubEntry(sub, "zzunknown", "zzzzUncategorized", "zzunknown")
        }
        //Storage.setTagSub(sub.id, sub.title, catid, cattitle+"-", false, true)
    }
    //updateAllUnreadCounts()
    filterSubList(subscrListPage.filtermode)
}

function insertSubEntry(sub, catid, cattitle, strCats) {
    var currCount = getCount(sub.id)
    var currObj = {"title": sub.title, "itemId":sub.id, "count":currCount, "cat":"sub", "sub":true, "catid":catid, "allcategories": strCats}
    if(Const.Tags[catid].subscriptions === null) {
        Const.Tags[catid].subscriptions = new Array()
    }
    console.log()
    Const.Tags[catid].subscriptions.push(currObj);
    Const.Tags[catid].cat = "folder"
}

//function updateAllUnreadCounts() {
//    for(var i=0, il=Const.unreadCounts.unreadcounts.length; i<il; i++) {
//        var unreadTag = Const.unreadCounts.unreadcounts[i];
//        var id = unreadTag.id;
//        var count = unreadTag.count;
//        Storage.setTagSubCount(id, count)
//    }
//}

//function refreshSubscriptions() {
//    //updateAllUnreadCounts()
//    filterSubList(subscrListPage.filtermode)
//}

function updateSubscriptions() {
    //updateAllUnreadCounts()
    //console.log("Calling updateSubscriptions")
    filterSubList(subscrListPage.filtermode)
}

//function loadSharedByYou() {
//    reloadNewsUrl("user/-/state/com.google/broadcast", null, true, "Shared(You)")
//}

//function loadSharedByFriends() {
//    reloadNewsUrl("user/-/state/com.google/broadcast-friends", null, true, "Shared (Friends)")
//}

function loadAllNews() {
    reloadNewsUrl("user/-/state/com.google/reading-list", null, true, qsTr("All News"));
}

function loadUnreadNews() {
    reloadNewsUrl("user/-/state/com.google/reading-list", "user/-/state/com.google/read", true, qsTr("All Unread"));
}

function loadStarred() {
    reloadNewsUrl("user/-/state/com.google/starred", null, true, qsTr("All Starred"));
}

function loadById(itemId, title) {
    var filter = (subscrListPage.filtermode == "unread" && window.globalUnreadFilter) ? "user/-/state/com.google/read" : ""
    reloadNewsUrl(encodeURIComponent(itemId), filter, true, title);
}

function reloadNewsUrl(param, filter, loadPage, title) {
    infoMessage.text = qsTr("Loading Feed..")
    feedListModel.clear()
    loadNews(param, loadPage, filter, null, title);
}

function loadMore(param, filter, contId) {
    loadNews(param, false, filter, contId, null);
}

function loadNews(param, loadPage, filter, contId, title) {
    var newurl = "https://www.google.com/reader/api/0/stream/contents/"
    newurl += param
    newurl += "?n=30&client=gNewsReader"
    if(filter != null && filter != "") { newurl += "&xt="; newurl += filter }
    if(contId != null && contId != "") { newurl += "&c="; newurl += contId }
    //newurl += "&trans=true"

    feedListPage.feedUrl = param
    if(title != null) feedListPage.feedTitle = title
    if(loadPage) pageStack.replace(feedListPage);
    (filter != null && filter != "") ? feedListPage.feedExclude = filter : feedListPage.feedExclude = "";
    topMsgText.text = (feedListPage.filterActive? "!" : "")+feedListPage.feedTitle
    sendWebRequest(true, "GET", newurl, null, parseNews, loadNews, null, null)
}

function loadFeedDetails(index, replacePage) {
    if(replacePage) {
        feedItemPage.model = feedListModel
    }
    feedItemPage.startIndex = index
    topMsgText.text = (feedItemPage.mainIndex+1) + qsTr(" of ") + feedListModel.count
    if(replacePage) pageStack.replace(feedItemPage);
    markAsRead(index, feedItemPage.replacePage)
}

function markAsRead(index, replacePage) {
    var feedEntry = feedItemPage.model.get(index);
    if(!feedEntry.readstatus) {
        feedItemPage.model.setProperty(index, "readstatus", true)
        editTag("a", Const.READ_ACT, feedEntry.feedId, feedEntry.feedUrl)
        if(feedEntry.keptUnread) {
            feedItemPage.model.setProperty(index, "keptUnread", false)
            editTag("r", Const.KEEP_UNREAD_ACT, feedEntry.feedId, feedEntry.feedUrl)
        }
        // Reduce header and feed id unread count
        updateCount(feedEntry.feedUrl, feedEntry.categories, 1)
        //feedItemPage.read = true; feedItemPage.keptUnread = false
    }
}

function updateCount(feedUrl, categories, count) {
    (count > 0) ? reduceCount(feedUrl, count): increaseCount(feedUrl, count)
    var cats = JSON.parse(categories);
    for(var i=0, il=cats.length; i<il; i++) (count > 0) ? reduceCount(cats[i], count): increaseCount(cats[i], count)
}

//function updateCount(feedUrl, categories, count) {
//    Storage.updateTagSubCount(feedUrl, count)
//    var cats = JSON.parse(categories);
//    for(var i=0, il=cats.length; i<il; i++) Storage.updateTagSubCount(cats[i], count)
//    subscrListPage.isCountDirty = true
//}

function parseNews(data, params) {
    var doc = JSON.parse(data);

    if(doc.continuation != undefined)  { feedListPage.continueId = doc.continuation }
    else {feedListPage.continueId = "ALLLOADED"} ;

    if(doc.items == null || doc.items == "") infoMessage.text = qsTr("You have no matching Feed Items")
    else infoMessage.text = ""

    for(var i=0, il=doc.items.length; i<il; i++) {
        var item = doc.items[i];
        parseEntry(item);
    }
}

function parseEntry(feedItem) {
    var content = ""
    if(feedItem.content!= undefined && feedItem.content!= null) {
        content = feedItem.content.content;
    } else if(feedItem.summary != undefined && feedItem.summary != null) {
        content = feedItem.summary.content;
    }

    var articleLink = "";
    if(feedItem.alternate!=undefined && feedItem.alternate!=null) {
        articleLink = feedItem.alternate[0].href;
    }
    var stringCats = JSON.stringify(feedItem.categories);

    feedListModel.append({
        "feedId": feedItem.id,
        "title": Const.Encoder.htmlDecode(feedItem.title),
        "source": Const.Encoder.htmlDecode(feedItem.origin.title),
        "author": feedItem.author,
        "feedTime": feedItem.crawlTimeMsec,//feedItem.published
        "content": Const.sanitizeContent(content, window.showFullHtml),
        "feedUrl": feedItem.origin.streamId,
        "articleUrl": articleLink,
        "readstatus": Const.REGX_READ.test(stringCats),
        "starred": Const.REGX_STAR.test(stringCats),
        "shared": Const.REGX_SHARE.test(stringCats),
        "liked": Const.REGX_LIKE.test(stringCats),
        "keptUnread": Const.REGX_KEPT_UNREAD.test(stringCats),
        "categories": stringCats,
        "categoriesStr": getCurrTags(stringCats)
    });
}

function getToken(nextFunc, nextFuncParams) {
    var url = "https://www.google.com/reader/api/0/token";
    sendWebRequest(true, "GET", url, null, parseAccessToken, getToken, nextFunc, nextFuncParams);
}

function parseAccessToken(data, nextFunc, params) {
    params.param[0].val = data;
    if(nextFunc) nextFunc(params);
}

function editTag(act, type, actTagId, actFeedUrl) {
    var newParams = Const.getEditTagParams(act, type, actTagId, actFeedUrl, null)
    getToken(updateTag, newParams)
}

function toggleTagStatus(action, flag, propName, feedId, feedUrl, index) {
    editTag( flag ? "r" : "a", action, feedId, feedUrl );
    flag = !flag
    //console.log("Updating property ("+propName+") at index:"+feedItemPage.index+" with value:" + flag)
    feedListModel.setProperty(index, propName, flag);
}

function updateTag(newParams) {
    var url = "https://www.google.com/reader/api/0/edit-tag";
    sendWebRequest(true, "POST", url, newParams, tagEditCallback, updateTag, null, null);
}

function deleteTag(newParams) {
    var url = "https://www.google.com/reader/api/0/disable-tag";
    sendWebRequest(true, "POST", url, newParams, tagDelRenameCallback, deleteTag, null, null);
}

function renameTag(newParams) {
    var url = "https://www.google.com/reader/api/0/rename-tag";
    sendWebRequest(true, "POST", url, newParams, tagDelRenameCallback, renameTag, null, null);
}

function tagEditCallback(data, params) {
    if(data == "OK" &&(params.method !== undefined && params.method === "EditTags")) {
        for(var i=0; i < params.param.length; i++) {
            if(params.param[i].name == "a") {
                var addedTag = decodeURIComponent(params.param[i].val)
                addedTag = addedTag.replace("user/-", Const.USER_PREFIX)
                var addedTitle = addedTag.substring(addedTag.lastIndexOf("/")+1)
                if(Const.Tags[addedTag] === undefined || Const.Tags[addedTag] === null) {
                    Const.Tags[addedTag] = {"id":addedTag, "label":addedTitle, "subscriptions":null,"count":"", "cat":"tag"}
                    subListModel.append({"title": addedTitle, "itemId":addedTag, "count": getCount(addedTag), "cat":"tag", "sub":false, "catid":addedTag})
                }
            }
        }
        //feedItemPage.categoriesStr = params.intags
        feedItemPage.setCurrentFeedProperty("categoriesStr", params.intags)
    }
}

function tagDelRenameCallback(data, params) {
    if(data == "OK") {
        refreshSubList("full")
    }
}

//For sub/unsub and rename
function editSub(index, feedId, act, title) {
    var newParams = null;
    if(act == "markAll") {
        newParams = Const.getMarkAsReadParams(index, feedId, title, null)
        getToken(markAllAsRead, newParams)
    } else if(act == "delete") {
        newParams = Const.getDisableTagParams(feedId, title, null)
        getToken(deleteTag, newParams)
    }else if(act == "rename") {
        newParams = Const.getRenameTagParams(feedId, title, null)
        getToken(renameTag, newParams)
    } else {
        newParams = Const.getEditSubParams(index, act, feedId, title, null)
        getToken(updateSub, newParams)
    }
}

function updateSub(newParams) {
    var url = "https://www.google.com/reader/api/0/subscription/edit";
    sendWebRequest(true, "POST", url, newParams, subEditCallback, updateSub, null, null);
}

function markAllAsRead(newParams) {
    var url = "https://www.google.com/reader/api/0/mark-all-as-read"
    sendWebRequest(true, "POST", url, newParams, subEditCallback, markAllAsRead, null, null);
}

function subEditCallback(data, params) {
    if(data == "OK") {
        refreshSubList("full")
        if(params.method != null && params.method == "markAllAsRead") {
            for( var i=0, ij=feedListModel.count; i < ij ; i++ ) {feedListModel.setProperty(i, "readstatus", true);feedListModel.setProperty(i, "keptUnread", false)}
        }
    }
}

function filterSubList(filterMode) {
    if(subListModel.count > 0) subListModel.clear()
    var tmpSub = null; var tmpTag = null
    for(var prop in Const.Tags) {
        tmpTag = Const.Tags[prop]
        if(filterMode == "all") subListModel.append({"title": tmpTag.label, "itemId":prop, "count": getCount(prop), "cat":tmpTag.cat, "sub":false, "catid": null, "allcategories":null});
        else if( getCount(prop) > 0 ) subListModel.append({"title": tmpTag.label, "itemId":prop, "count": getCount(prop), "cat":tmpTag.cat, "sub":false, "catid": null,  "allcategories":null});
        if(Const.Tags[prop].subscriptions != null) for(var i=0; i < Const.Tags[prop].subscriptions.length; i++) {
            tmpSub = Const.Tags[prop].subscriptions[i];
            if(filterMode == "all") {subListModel.append({"title": tmpSub.title, "itemId":tmpSub.itemId, "count": getCount(tmpSub.itemId), "cat":tmpSub.cat, "sub":true, "catid":tmpSub.catid, "allcategories":tmpSub.allcategories})}
            else if( getCount(tmpSub.itemId) > 0 ) {subListModel.append({"title": tmpSub.title, "itemId":tmpSub.itemId, "count": getCount(tmpSub.itemId), "cat":tmpSub.cat, "sub":true, "catid":tmpSub.catid, "allcategories":tmpSub.allcategories })};
        }
    }
    //Storage.getTagSub(subListModel, filterMode == "all"?false:true)
    if(subListModel.count == 0) {
        filterMode == "all" ? infoMessage.text = qsTr("You have no subscribed feeds") : infoMessage.text = qsTr("No Feeds with Unread Items")
    }
}

function sendToReadLaterService(serviceName, shareTitle, shareUrl) {
    var savedUserName = Storage.getSetting("READLATER_USEARNAME_"+serviceName);
    var savedPassword = "";
    if(savedUserName != undefined && savedUserName != "" && savedUserName != "Unknown") {
        savedPassword = Storage.getSetting("READLATER_PASSWORD_"+serviceName);
        if(savedPassword == undefined || savedPassword == "Unknown") savedPassword = ""
        invokeReadItLaterAddService(serviceName, savedUserName, savedPassword, shareTitle, shareUrl)
    } else {
        feedItemPage.showReadItLaterSignIn(serviceName, shareTitle, shareUrl)
    }
}

function invokeReadItLaterAddService(servName, servUName, servPwd, sendTitle, sendUrl) {
    if(servName == Const.SERVICE_READ_IT_LATER) {
        sendWebRequest(false, "POST", Const.READ_IT_LATER_ADD_URL, Const.getReadItLaterParams(servUName, servPwd, sendTitle, sendUrl), parseReadLaterServiceResult, invokeReadItLaterAddService, null, null);
    }  else if(servName == Const.SERVICE_INSTAPAPER) {
        sendWebRequest(false, "POST", Const.INSTAPAPER_ADD_URL, Const.getInstapaperParams(servUName, servPwd, sendTitle, sendUrl), parseReadLaterServiceResult, invokeReadItLaterAddService, null, null);
    }
}

function parseReadLaterServiceResult(data, params) {
    if(data == "200 OK" || data == "201") {
        pageInfoBanner.text = qsTr("Successfully sent the link to Service ("+params.method+")")
        pageInfoBanner.open();
    } else if ( data.indexOf("403") ||  data.indexOf("401") ) {
        pageInfoBanner.text = qsTr("Unable to Login to Service, Username or Password could be Wrong")
        pageInfoBanner.open();
        params.method === "ReadItLater" ? clearReadForLaterAuth("ril") : clearReadForLaterAuth("insta")
    } else {
        pageInfoBanner.text = qsTr("Unknown error while sending. Please try again after some time")
        pageInfoBanner.open();
    }
}

function saveReadForLaterAuth(inServ, inUsr, inPwd) {
    Storage.setSetting("READLATER_USEARNAME_"+inServ, inUsr)
    Storage.setSetting("READLATER_PASSWORD_"+inServ, inPwd)
}

function clearReadForLaterAuth(serviceName) {
    console.log("Clearing Auth Info...........")
    if(serviceName === "all" || serviceName == "ril") {
        Storage.setSetting("READLATER_USEARNAME_"+Const.SERVICE_READ_IT_LATER, "")
        Storage.setSetting("READLATER_PASSWORD_"+Const.SERVICE_READ_IT_LATER, "")
    } else if(serviceName === "all" || serviceName == "insta"){
        Storage.setSetting("READLATER_USEARNAME_"+Const.SERVICE_INSTAPAPER, "")
        Storage.setSetting("READLATER_PASSWORD_"+Const.SERVICE_INSTAPAPER, "")
    }
}

function getCurrTags(categories) {
    var catStr = "";
    var cats = JSON.parse(categories)
    if(cats != undefined && cats != null) {
        var currCat = null
        for(var i in cats) {
            currCat = cats[i]
            if(currCat.indexOf("/label/") > 0) {
                if(catStr.length == 0) catStr = currCat.substring(currCat.lastIndexOf("/")+1)
                else catStr = catStr + ", " + currCat.substring(currCat.lastIndexOf("/")+1)
            }
        }
    }
    return catStr.toString()
}

function saveTags(inTags, origTags, tagId, feedUrl) {
    var tagsSaver = new Array()

    var currentTagTokens = inTags.split( "," )
    var origTagTokens = origTags.split( "," )
    currentTagTokens.sort(); origTagTokens.sort()
    var origTagIndex = 0;
    for ( var i = 0; i < currentTagTokens.length; i++ )
    {
        currentTagTokens[i] = currentTagTokens[i].replace(/^\s+|\s+$/g, '')
        origTagTokens[origTagIndex] = origTagTokens[origTagIndex].replace(/^\s+|\s+$/g, '')
        if(currentTagTokens[i] == origTagTokens[origTagIndex]) origTagIndex++
        else if(currentTagTokens[i] != origTagTokens[origTagIndex] && currentTagTokens[i] != "") tagsSaver.push({"name":"a", "val":"user/-/label/"+encodeURIComponent(currentTagTokens[i])})
    }
    while (origTagIndex < origTagTokens.length) {
        origTagTokens[origTagIndex] = origTagTokens[origTagIndex].replace(/^\s+|\s+$/g, '')
        if(origTagTokens[origTagIndex] != "") tagsSaver.push({"name":"r", "val":"user/-/label/"+encodeURIComponent(origTagTokens[origTagIndex])}); origTagIndex++
    }
    getToken(updateTag, Const.getTagEditParamsM(tagsSaver, tagId, feedUrl, null, inTags))
}

function folderClicked(index, id, expanded) {
    if(expanded) {
        for(var i=index+1; i<subListModel.count; i++) {
            if(id == subListModel.get(i).catid) { subListModel.remove(i); i--}
            else break
        }
    } else {
        if(Const.Tags[id].subscriptions != null) for(var i=0; i < Const.Tags[id].subscriptions.length; i++) {
            var tmpSub = Const.Tags[id].subscriptions[i];
            if(subscrListPage.filtermode == "all") {subListModel.insert(index+1,{"title": tmpSub.title, "itemId":tmpSub.itemId, "count": getCount(tmpSub.itemId), "cat":tmpSub.cat, "sub":true, "catid":tmpSub.catid});index++}
            else if( getCount(tmpSub.itemId) > 0 ) {subListModel.insert(index+1,{"title": tmpSub.title, "itemId":tmpSub.itemId, "count": getCount(tmpSub.itemId), "cat":tmpSub.cat, "sub":true, "catid":tmpSub.catid }); index++};
        }
    }
}

function searchForFeed(query) {
    sendWebRequest(false, "GET", Const.getSearchForFeedUrl(query), null, parseSearchForFeedResult, searchForFeed, null, null);
}

function parseSearchForFeedResult(data, params) {
    pageStack.push(Qt.resolvedUrl("../qml/components/FeedSearchResultPage.qml"))
    var result = JSON.parse(data)
    pageStack.currentPage.clearResults()
    for(var i=0, il=result.responseData.entries.length; i<il; i++) {
        var resultItem = result.responseData.entries[i];
        pageStack.currentPage.addToList(Const.stripHtmlTags(resultItem.title), Const.stripHtmlTags(resultItem.contentSnippet), resultItem.url)
    }
}
