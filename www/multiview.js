cordova.define("cordova-plugin-multiview.multiview", function(require, exports, module) {
/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

/* global cordova */

var exec = require('cordova/exec');


var Multiview = {
    pushView: function(name, title, success, failure) {
        return exec(success, failure, "Multiview", "pushView", [name, title]);
    },
    popView: function(success, failure) {
        return exec(success, failure, "Multiview", "popView");
    },
    hideNavigationBar: function(success, failure) {
        return exec(success, failure, "Multiview", "hideNavigationBar");
    }
};

module.exports = Multiview;

});
