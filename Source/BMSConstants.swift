/*
*     Copyright 2015 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/

import UIKit

internal var DUMP_TRACE:Bool = true

internal let  HTTP_SCHEME   =   "http"

internal let HTTPS_SCHEME   =   "https"

internal let QUERY_PARAM_SUBZONE = "subzone"

internal let STAGE1         =   "stage1"

internal let BLUEMIX_DOMAIN =   "bluemix.net"

internal let IMFPUSH_GET  = "GET"

internal let IMFPUSH_POST   =  "POST"

internal let IMFPUSH_PUT   =  "PUT"

internal let IMFPUSH_DELETE  = "DELETE"

internal let IMFPUSH_ACTION_DELETE  = "action=delete"

internal let IMFPUSH_CONTENT_TYPE_JSON  = "application/json; charset = UTF-8"

internal let IMFPUSH_CONTENT_TYPE_KEY  = "Content-Type"

internal let IMFPUSH_DEVICE_ID  = "deviceId"

internal let IMFPUSH_DEVICES  = "devices"

internal let IMFPUSH_TOKEN  = "token"

internal let IMFPUSH_USER_ID  = "userId"

internal let IMFPUSH_USER_AGENT  = "userAgent"

internal let IMFPUSH_PLATFORM  = "platform"

internal let IMFPUSH_TAGS  = "tags"

internal let IMFPUSH_TAGNAME  = "tagName"

internal let IMFPUSH_TAGNAMES  = "tagNames"

internal let IMFPUSH_TAGSNOTFOUND  = "tagsNotFound"

internal let IMFPUSH_NAME  = "name"

internal let IMFPUSH_SUBSCRIPTIONS  = "subscriptions"

internal let IMFPUSH_SUBSCRIBED  = "subscribed"

internal let IMFPUSH_SUBSCRIPTIONEXISTS  = "subscriptionExists"

internal let IMFPUSH_UNSUBSCRIBED  = "unsubscribed"

internal let IMFPUSH_UNSUBSCRIPTIONS  = "unsubscriptions"

internal let IMFPUSH_SUBSCRIPTIONNOTEXISTS  = "subscriptionNotExists"

internal let IMFPUSH_AUTHORIZATION  = "authorization"

internal let IMFPUSH_OPEN  = "open"

internal let IMFPUSH_RECEIVED  = "received"

internal let IMFPUSH_SEEN  = "seen"

internal let IMFPUSH_ACKNOWLEDGED  = "acknowledged"

internal let IMFPUSH_APP_MANAGER  = "IMFPushAppManager"

internal let IMFPUSH_UTILS  = "IMFPushUtils"

internal let IMFRESPONSE_IMFPUSHCATEGORY  = "IMFPushResponse+IMFPushCategory"

internal let IMFPUSH_CLIENT  = "IMFPushClient"

internal let IMFPUSH_SANDBOX  = "sandbox"

internal let IMFPUSH_PRODUCTION  = "production"

internal let IMFPUSH_ENVIRONMENT  = "environment"

internal let IMFPUSH_DISPLAYNAME  = "displayName"

internal let IMFPUSH_X_REWRITE_DOMAIN  = "X-REWRITE-DOMAIN"

internal let IMFPUSH_PUSH_WORKS_SERVER_CONTEXT  = "imfpush/v1/apps"

internal let IMFPUSH_HTTP_CONNECTION_TIMEOUT_KEY = 120000

