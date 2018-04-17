// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.package tests;

import ballerina/io;
import ballerina/log;
import ballerina/test;
import ballerina/config;

// This user-id is initialized after the testAuthyUserAdd() function call and will be used for testAuthyUserDelete()
string userId;

endpoint Client twilioClient {
    accountSid:config:getAsString(ACCOUNT_SID),
    authToken:config:getAsString(AUTH_TOKEN),
    xAuthyKey:config:getAsString(AUTHY_API_KEY)
};

@test:Config {
    groups:["basic"]
}
function testAccountDetails() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> getAccountDetails()");

    var details = twilioClient -> getAccountDetails();
    match details {
        Account account => {
            io:println(account);
            test:assertNotEquals(account.sid, EMPTY_STRING, msg = "Failed to get account details");
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}

@test:Config {
    groups:["basic"]
}
function testSendSms() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> sendSms()");

    string fromMobile = config:getAsString("SAMPLE_FROM_MOBILE");
    string toMobile = config:getAsString("SAMPLE_TO_MOBILE");
    string message = config:getAsString("SAMPLE_MESSAGE");

    var details = twilioClient -> sendSms(fromMobile, toMobile, message);
    match details {
        SmsResponse smsResponse => {
            io:println(smsResponse);
            test:assertNotEquals(smsResponse.sid, EMPTY_STRING, msg = "Failed to get sms response details");
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}

@test:Config {
    groups:["basic"]
}
function testMakeVoiceCall() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> makeVoiceCall()");

    string fromMobile = config:getAsString("SAMPLE_FROM_MOBILE");
    string toMobile = config:getAsString("SAMPLE_TO_MOBILE");
    string twimlUrl = config:getAsString("SAMPLE_TWIML_URL");

    var details = twilioClient -> makeVoiceCall(fromMobile, toMobile, twimlUrl);
    match details {
        VoiceCallResponse voiceCallResponse => {
            io:println(voiceCallResponse);
            test:assertNotEquals(voiceCallResponse.sid, EMPTY_STRING, msg = "Failed to get voice call response details");
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}

@test:Config {
    groups:["authy"]
}
function testAuthyAppDetails() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> getAuthyAppDetails()");

    var details = twilioClient -> getAuthyAppDetails();
    match details {
        AuthyApp authyApp => {
            io:println(authyApp);
            test:assertTrue(authyApp.authyResponse.isSuccess, msg = "Failed to get authy app details");
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}

@test:Config {
    groups:["authy"]
}
function testAuthyUserAdd() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> addAuthyUser()");

    string email = config:getAsString("SAMPLE_USER_EMAIL");
    string phone = config:getAsString("SAMPLE_USER_PHONE");
    string countryCode = config:getAsString("SAMPLE_USER_COUNTRY_CODE");

    var details = twilioClient -> addAuthyUser(email, phone, countryCode);
    match details {
        AuthyNewUser authyNewUser => {
            io:println(authyNewUser);
            test:assertTrue(authyNewUser.authyResponse.isSuccess, msg = "Failed to get authy user details");
            userId = authyNewUser.userId;
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}

@test:Config {
    groups:["authy"],
    dependsOn:["testAuthyUserAdd"]
}
function testAuthyUserStatus() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> getAuthyUserStatus()");

    string userId = config:getAsString("SAMPLE_USER_ID");

    var details = twilioClient -> getAuthyUserStatus(userId);
    match details {
        AuthyUser authyUser => {
            io:println(authyUser);
            test:assertTrue(authyUser.authyResponse.isSuccess, msg = "Failed to get authy user details");
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}

@test:Config {
    groups:["authy"],
    dependsOn:["testAuthyUserStatus"]
}
function testAuthyUserDelete() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("twilioClient -> deleteAuthyUser()");

    var details = twilioClient -> deleteAuthyUser(userId);
    match details {
        AuthyResponse authyResponse => {
            io:println(authyResponse);
            test:assertTrue(authyResponse.isSuccess, msg = "Failed to delete authy user");
        }
        TwilioError twilioError => test:assertFail(msg = twilioError.message);
    }
}
