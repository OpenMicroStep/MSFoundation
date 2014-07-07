/**
 * Created with WebStorm.
 * User: municipol
 * Date: 24/10/13
 * Time: 09:19
 */
//TODO: escape data?
//TODO: multipage array
//TODO: jquery xhr

//TODO: ordering in table: if comparator says elements are equal, order by name.


// TODO: more universal date to String system (toLocaleString?), that takes into account the language we want to display
// TODO: support format
Date.prototype.toFrenchString = function ()
{
    var months = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
    var date = this.getDate();
    var hours = this.getHours();
    var minutes = this.getMinutes();

    if (date < 10)
    {
        date = "0" + date;
    }
    if (hours < 10)
    {
        hours = "0" + hours;
    }
    if (minutes < 10)
    {
        minutes = "0" + minutes;
    }
    var output = date + " " + months[this.getMonth()] + " " + this.getFullYear() + " " + hours + ":" + minutes;
    return output;
}


String.prototype.localize = function(){  // todo: better name, maybe override number.toString() ?
    return this.replace('.',',');
};







function getXhr(){
    var xhr = null;
    if(window.XMLHttpRequest) // Firefox et autres
        xhr = new XMLHttpRequest();
    else if(window.ActiveXObject){ // Internet Explorer
        try {
            xhr = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
            xhr = new ActiveXObject("Microsoft.XMLHTTP");
        }
    }
    else { // XMLHttpRequest non supporté par le navigateur
        alert("Votre navigateur ne supporte pas les objets XMLHTTPRequest...");
        xhr = false;
    }
    return xhr
}


function handleRequestStateChange(){
    var urlSplit = window.location.toString().split("/resources");
    var url = urlSplit[0];
    var response;
    var mygetrequest=new getXhr();

    mygetrequest.onreadystatechange = function(){
        if (mygetrequest.readyState==4){
            if (mygetrequest.status==200 || window.location.href.indexOf("http")==-1){
                var msteData, responseObject, uploadId;
                response = mygetrequest.responseText;
                msteData = MSTE.parse(response);
                responseObject = msteData.root;
                uploadId = responseObject.id ;


                // iFrame file upload
                var myForm = document.getElementById('file_upload_form');
                var myComponent = $('#result_component');
                myComponent.width("0%");
                $(".progress").show();
                var fileName = $('#file_upload_form .fileupload-preview').html();

                myForm.action = url+"/upload?id="+uploadId+"&type=storable";
                myForm.method = "POST";
                myForm.enctype = "multipart/form-data";
                myForm.target = 'upload_target';

                // TODO: detect when submit fails immediately
                myForm.submit();

                // Status Request
                var mycontrolrequest=new getXhr();
                var controlCount = 0 ;
                mycontrolrequest.onreadystatechange = function(){
                    if (mycontrolrequest.readyState==4){
                        response = mycontrolrequest.responseText;
                        msteData = MSTE.parse(response);
                        responseObject = msteData.root;
                        if (responseObject.upload_status === 1) {
                            myComponent.width((responseObject.received_size / responseObject.expected_size) *100 + "%");
                        } else {
                            if (responseObject.upload_status === 3) {
                                myComponent.width("0%");
                                $(".progress").hide();

                                // message error
                                $("#core .messages").prepend((_.template($("#template-alert").html()))({fileName: fileName}));

                                $(".fileupload .btn.add").show();
                                $(".fileupload .btn.upload").addClass('fileupload-exists').removeClass('fileupload-new');

                                clearInterval(interval);
                            }
                            if (responseObject.upload_status === 4) {
                                myComponent.width("0%");
                                $(".progress").hide();

                                //message success
                                $("#core .messages").prepend((_.template($("#template-success").html()))({fileName: fileName}));

                                //Reset the field
                                $(".fileupload").fileupload("reset");

                                $(".fileupload .btn.add").show();
                                $(".fileupload .btn.upload").addClass('fileupload-exists').removeClass('fileupload-new');

                                clearInterval(interval);

                                location.reload();          //TODO: remove and reload file list
                            }
                        }
                    }
                }

                mycontrolrequest.open("GET", url+"/getUploadStatus?id="+uploadId+"&cachebusting="+Math.floor(Math.random()*99999999999999999999999), true);
                mycontrolrequest.send(null);

                // Status request loop
                var interval = setInterval( function () {
                    mycontrolrequest.open("GET", url+"/getUploadStatus?id="+uploadId+"&cachebusting="+Math.floor(Math.random()*99999999999999999999999), true);
                    mycontrolrequest.send(null);
                }, 1000);



            }
            else{
                alert("An error has occured making the request");
            }
        }
    }

    mygetrequest.open("GET", url+"/getUploadID", true);
    mygetrequest.send(null);
}




$(function () {

////////
// Models + Collections
var Page = Backbone.Model.extend({});

var Ticket = Backbone.Model.extend({
    parse: function (data) {
        var http = window.location.protocol;
        var slashes = http.concat("//");
        var host = slashes.concat(window.location.host);

        console.log(new Date(data.expiration * 1000 + (new Date("01/01/01")).getTime() + 60*60*1000))
        data.expiration = (new Date(data.expiration * 1000 + (new Date("01/01/01")).getTime() + 60*60*1000)).toFrenchString();
        data.url = host + basePath + "?ticket=" + data.ticket;

        return data;
    }
});

var Tickets = Backbone.Collection.extend({
    model: Ticket,
    comparator: "creationDate"
});

    //////////DRY/////////////
    var PublicLink = Backbone.Model.extend({
        parse: function (data) {
            var http = window.location.protocol;
            var slashes = http.concat("//");
            var host = slashes.concat(window.location.host);

            data.expiration = (new Date(data.expiration * 1000 + (new Date("01/01/01")).getTime() + 60*60*1000)).toFrenchString();
            data.url = host + basePath + "publicResources/" + data.publicLink;

            return data;
        }
    });

    var PublicLinks = Backbone.Collection.extend({
        model: PublicLink,
        comparator: "creationDate"
    });
    ///////////////////////

var Breadcrumbs = Backbone.Collection.extend({
    model: Backbone.Model.extend({
        parse: function (data) {
            //data.isLast = false;
            return data;
        }
    })
});


    //////// TODO: clean up: getssharinglink and other not in use anymore
var Item = Backbone.Model.extend({
    initialize: function (options) {
        this.tickets = new Tickets(options.tickets, {parse: true});
        this.publicLinks = new PublicLinks(options.publicLinks, {parse: true});
    },

    getSharingLink: function () {
        var data = $("<form>")
            .append('<input type="hidden" name="manage_file" value="ShareFiles" />')
            .append('<input type="hidden" name="' + this.get("fileName") + '" value="' + this.get("fileName") + '" />')
            .serialize();
        app.doShareFiles(data);
    },

    parse: function (data) {
        var tempSize = parseInt(data.fileSize);     // I am given a string, not a number
        data.fileSizeText = parseFloat(tempSize.toFixed(1)) + " bytes";         // TODO: localisation "octet" + localisation pour 0.0 et 0,0
        tempSize = tempSize/1000;
        if (tempSize >= 1) {
            data.fileSizeText = parseFloat(tempSize.toFixed(1)) + " KB";            // OR do this in template?
            tempSize = tempSize/1000;
            if (tempSize >= 1) {
                data.fileSizeText = parseFloat(tempSize.toFixed(1)) + " MB";
                tempSize = tempSize/1000;
                if (tempSize >= 1) {
                    data.fileSizeText = parseFloat(tempSize.toFixed(1)) + " GB";
                }
            }
        }

        data.fileSizeText = data.fileSizeText.localize();

        return data;
    }
});

var Items = Backbone.Collection.extend({
    model: Item,

    toggleSort: function (sortBy) {
        var oldSortBy = App.page.get("sortBy");

        if (oldSortBy !== sortBy) {
            App.page.set("ascending", true);
        } else {
            App.page.set("ascending", !(App.page.get("ascending")));
        }

        App.page.set("sortBy", sortBy);
        this.sort();
        // CURRENTLY, can't use event for that because events don't trigger if the value doesn't change.
        // Maybe if I had an object ordering: {ascending: x, sortBy: y}
    },

    comparator: function(one, two) {
        var sortBy = App.page.get("sortBy");
        var orderUp = App.page.get("ascending");
        var valueOne = one.get(sortBy);
        var valueTwo = two.get(sortBy);

        switch (sortBy) {
            case "fileName":
            case "uploader":
                valueOne = valueOne.toLowerCase();
                valueTwo = valueTwo.toLowerCase();
                break;
            case "fileSize":
            case "date":
                orderUp = !orderUp;
                break;
            default:
                break;
        }

        // If At least 1 is fixed
        if (one.get("fixed") || two.get("fixed")) {
            if (one.get("fixed") && two.get("fixed")) { // both are fixed
                if ( one.get("fileName").toLowerCase()  < two.get("fileName").toLowerCase()  )  //always filename
                    return -1;
                else
                    return 1;
            }
            if (one.get("fixed")) { // only one
                return -1;
            }
            if (two.get("fixed")) { // only two
                return 1;
            }
        }

        // No fixed file
        if (valueOne < valueTwo)
            return orderUp ? -1 : 1;
        else
            return !orderUp ? -1 : 1;
    }
});

var MyAccount = Backbone.Model.extend({
    defaults: {
        validity: 0,
        oldPassword: "",
        newPassword1: "",
        newPassword2: "",
        loading: false
    },

    reset: function() {
        this.clear().set(this.defaults);
    },

    ///////////
    // Validity
    recalculateValidity: function () {                             
        if (this.get("oldPassword").length === 0)
            this.set("validity", -1);
        else if (this.get("newPassword1").length === 0)
            this.set("validity", -2);
        else if (this.get("newPassword1") !== this.get("newPassword2"))
            this.set("validity", -3);
        else
            this.set("validity", 1);
    },

    onChangeOldPassword: function (value) {
        this.set("oldPassword", value);
        /*if (this.get("oldPassword").length === 0)
            this.set("validity", -1);
        else if (this.isAllValid()) {
            this.set("validity", 1);
        }*/
        this.recalculateValidity();
    },

    onChangeNewPassword1: function (value) {
        this.set("newPassword1", value);
        this.recalculateValidity();
        /*if (this.get("newPassword1").length === 0)
            this.set("validity", -2);*/
    },

    onChangeNewPassword2: function (value) {
        this.set("newPassword2", value);
        this.recalculateValidity();
        /*if (this.get("newPassword1") !== this.get("newPassword2"))
            this.set("validity", -3);*/

    },
    // END Validity
    /////////////

    toJSON: function () {
        var result = _.clone(this.attributes);

        delete result.loading;
        delete result.validity;

        return result;
    },

    onSaveForm: function (form) {               // BETTER TO USE FORM, OR MODEL DATA??????
        if (this.get("validity") === 1) {
            var data = this.toJSON();
            var path = basePath + "changePassword";
            var me = this;

            me.set({loading: true});
                                      
            $.ajax({
                type: 'POST',
                cache: false,
                url: path,
                dataType: "text",
                data: data,
                success: function (msteString) {
                    console.log(msteString);
                    var decodedMSTE = MSTE.parse(msteString).root;
                    console.log(decodedMSTE);

                    me.set({loading: false});

                    if (decodedMSTE.success) {
                        me.set({validity: 100});
                    } else {
                        me.set({validity: -100});
                    }
                },
                error: function (jqXHR, textStatus) {
                    me.set({loading: false});
                    console.log("ERROR in Ajax Response: " + textStatus);
                    console.log(jqXHR);
                    //window.location = basePath + "login";   // send event to app, which does the logout
                },
                complete: function () {
                    //me.set({loading: false});     // ? why not?
                }
            });
        }
    }
});
// END Models + Collections
////////



///////
// Views
var TableView = Backbone.View.extend({
    initialize: function () {
        this.listenTo(this.collection, 'sort', this.render);
    },

    /////////
    // Rendering
    className: 'table table-striped table-hover',
    tagName: 'table',
    template: _.template($("#template-table").html()),

    render: function () {
        var nbUnselectables = 0;
        var nbRemoteUpload = 0;
        this.collection.forEach(function (model) {      //TODO: do this in parse() at load time
            if (model.get("fixed") !== true) {
                nbUnselectables++;
            }
            if (model.get("type") === "remoteUploadFolder") {
                nbRemoteUpload++
            }
        });

        var allAttributes = {
            "nbUnselectables": nbUnselectables,
            "nbRemoteUpload": nbRemoteUpload
        };
        _.extend(allAttributes, App.page.attributes);
        this.$el.html(this.template(allAttributes));

        this.collection.forEach(function (model) {
            var row = new RowView({model: model});
            this.$("tbody").append(row.render().el);
        }, this);

        return this;
    },
    // END Rendering
    /////////

    /////////////
    // Events
    events: {
        "click th[data-sort]": "onSort"
    },
    // END Events
    /////////////

    /////////////
    // Behavior
    onSort: function (event) {
        //this.$("th").removeClass("sortBy");       //doesn't work because we completely re-render all
        //$(event.target).addClass("sortBy");

        var sortBy = $(event.currentTarget).data("sort");
        this.collection.toggleSort(sortBy);

        event.preventDefault();
    }
    // END Behavior
    ////////////
});

var RowView = Backbone.View.extend({
    initialize: function () {
        this.listenTo(this.model.tickets, 'add', this.render);    // update count
        this.listenTo(this.model.tickets, 'remove', this.render);    // update count

        this.listenTo(this.model.publicLinks, 'add', this.render);    // update count
        this.listenTo(this.model.publicLinks, 'remove', this.render);    // update count
    },

    /////////
    // Rendering
    tagName: 'tr',
    template: _.template($("#template-tableRow").html()),

    render: function () {
        var allAttributes = {
            ticketCount: this.model.tickets.length,
            publicLinkCount: this.model.publicLinks.length
        };
        _.extend(allAttributes, this.model.attributes, App.page.attributes);
        this.$el.html(this.template(allAttributes));

        return this;
    },
    // END Rendering
    /////////


    /////////////
    // Events
    events: {
      "click .share": "getSharingLink",
      "click .upload": "getTicketLink"
    },
    // END Events
    /////////////


    /////////////
    // Behavior
    getTicketLink: function (e) {
        var uploadShareView = new UploadSharingView({model: this.model, collection: this.model.tickets});
        $("#app").append(uploadShareView.render().el);
        $("#uploadSharingModal").modal({show: true});
    },

    getSharingLink: function (e) {
        //this.model.getSharingLink();
        var fileShareView = new FileSharingView({model: this.model, collection: this.model.publicLinks});
        $("#app").append(fileShareView.render().el);
        $("#fileSharingModal").modal({show: true});
    }
    // END Behavior
    ///////////
});

var BreadcrumbsView = Backbone.View.extend({
    /////////
    // Rendering
    tagName: 'ol',
    className: 'breadcrumb',
    template: _.template($("#template-breadcrumbs").html()),

    render: function () {
        this.$el.html(this.template());

        this.collection.forEach(function (model) {
            var breadcrumb = new BreadcrumbView({model: model});
            this.$el.append(breadcrumb.render().el);
        }, this);

        return this;
    }
    // END Rendering
    /////////
});

var BreadcrumbView = Backbone.View.extend({
    /////////
    // Rendering
    tagName: 'li',
    className: function () {
        if (this.model.get("isLast")) {
            return "active";
        }
    },
    template: _.template($("#template-breadcrumb").html()),

    render: function () {
        this.$el.html(this.template(this.model.attributes));
        return this;
    }
    // END Rendering
    /////////
});

var MyAccountView = Backbone.View.extend({
    initialize: function () {
        this.listenTo(this.model, 'change:validity', this.toggleValidity);
        this.listenTo(this.model, 'change:loading', this.toggleLoading);
    },

    /////////
    // Rendering
    template: _.template($("#template-myAccount").html()),

    render: function () {
        this.$el.html(this.template(this.model.attributes));
                                         
        /*this.$('#myAccountModal').modal({show:false});          //TODO: necessary?
        $('#myAccount').button();*/

        return this;
    },
    // END Rendering
    /////////

    /////////
    // Events
    events: {
        "hidden.bs.modal #myAccountModal": "resetForm",
        "input #myAccountOldPassword": "onOldPasswordChange",
        "input #myAccountNewPassword1": "onNewPassword1Change",
        "input #myAccountNewPassword2": "onNewPassword2Change",
        "submit form": "onSubmit"
    },
    // END Events
    /////////////

    /////////////
    // Behavior
    toggleValidity: function (model, validity) {

        // remove error classes
        this.$("#myAccountOldPasswordGroup").removeClass("has-error");
        this.$("#myAccountNewPassword1Group").removeClass("has-error");
        this.$("#myAccountNewPassword2Group").removeClass("has-error");
        //

        switch (validity) {
            case 100:
                this.$("#myAccountModal").modal('hide');
                break;

            case 1:
                this.$("button.saveForm").removeAttr('disabled');
                break;

            case -1:
                this.$("#myAccountOldPassword")
                    .attr("placeholder", polyglot.t("cannot_be_empty"));
                this.$("#myAccountOldPasswordGroup").addClass("has-error");
                this.$("button.saveForm").attr('disabled', 'disabled');
                break;

            case -2:
                this.$("#myAccountNewPassword1")
                    .attr("placeholder", polyglot.t("cannot_be_empty"));
                this.$("#myAccountNewPassword1Group").addClass("has-error");
                this.$("button.saveForm").attr('disabled', 'disabled');
                break;

            case -3:
                this.$("#myAccountNewPassword1")
                    .attr("placeholder", polyglot.t("passwords_must_match"));
                this.$("#myAccountNewPassword1Group").addClass("has-error");

                this.$("#myAccountNewPassword2")
                    .attr("placeholder", polyglot.t("passwords_must_match"));
                this.$("#myAccountNewPassword2Group").addClass("has-error");

                this.$("button.saveForm").attr('disabled', 'disabled');
                break;

            case -100:
                this.$("#myAccountOldPassword")
                    .val('')
                    .attr("placeholder", polyglot.t("invalid_password"))
                    .focus();
                this.$("#myAccountOldPasswordGroup").addClass("has-error");
                this.$("button.saveForm").attr('disabled', 'disabled');
                break;

            default:
                break;
        }
    },

    toggleLoading: function (model, value) {
        if (value) {
            $("button.saveForm").button('loading');
        } else {
            $("button.saveForm").button('reset');
        }
    },

    onOldPasswordChange: function () {
        this.model.onChangeOldPassword(this.$("#myAccountOldPassword").val());
    },

    onNewPassword1Change: function () {
        this.model.onChangeNewPassword1(this.$("#myAccountNewPassword1").val());
    },

    onNewPassword2Change: function () {
        this.model.onChangeNewPassword2(this.$("#myAccountNewPassword2").val());
    },

    onSubmit: function (event) {
        var form = $(event.currentTarget);

        event.preventDefault();

        this.model.onSaveForm(form);
    },

    resetForm: function () {
        this.model.reset();                 // with two-way binding, this would reset the form
        //this.$("form")[0].reset();
        this.remove();
    }
    // END Behavior
    ////////////
});


var LinksView = Backbone.View.extend({
    /////////
    // Rendering
    template: _.template($("#template-links").html()),

    render: function () {
        this.$el.html(this.template());

        this.collection.forEach(function (model) {
            var link = new LinkView({model: model});
            this.$(".links").append(link.render().el);
        }, this);

        return this;
    },
    // END Rendering
    /////////

    /////////
    // Events
    events: {
        "hidden.bs.modal #linksModal": "remove"
    }
    // END Events
    /////////////
});

var LinkView = Backbone.View.extend({
    /////////
    // Rendering
    template: _.template($("#template-link").html()),

    render: function () {
        this.$el.html(this.template(this.model.attributes));
        return this;
    }
    // END Rendering
    /////////
});

var TicketView = Backbone.View.extend({
    initialize: function (options) {
      if (options.usePrintTemplate) {
          this.template = this.printTemplate;
      }

      this.listenTo(this.model, "destroy", this.remove);
    },

    /////////
    // Rendering
    template: _.template($("#template-ticket").html()),
    printTemplate: _.template($("#template-ticket-print").html()),
    tagName: "tr",

    render: function () {
        this.$el.html(this.template(this.model.attributes));

        return this;
    },
    // END Rendering
    /////////

    /////////
    // Events
    events: {
        "click .remove": "stopSharing"
    },
    // END Events
    /////////////

    /////////////
    // Behavior
    stopSharing: function () {
        var me = this;
        var data = {
            manage_file: "ticket",
            sharing: false,
            fileID: this.model.get("fileID")
        };

        $.ajax({
            type: 'GET', //MEH...
            cache: false,   // not working????
            url: resourcesPath,
            dataType: "text",   //we want plaintext for MSTE parsing, not a JS array
            data: data,
            success: function (msteString) {
                var decodedMSTE = MSTE.parse(msteString).root;
                console.log(decodedMSTE);

                me.model.destroy();
            },
            error: function (jqXHR, textStatus) {
                console.log("ERROR in Ajax Response: " + textStatus);
                window.location = basePath + "login";   // send event to app, which does the logout
            }
        });
    }
    // END Behavior
    ////////////
});

var TicketsView = Backbone.View.extend({
    initialize: function () {
        this.listenTo(this.collection, 'add', this.addRow);               //todo: don't rerender all

        this.template = this.defaultTemplate;
    },

    /////////
    // Rendering
    defaultTemplate: _.template($("#template-tickets").html()),
    printTemplate: _.template($("#template-tickets-print").html()),

    render: function () {
        this.$el.html(this.template());

        this.collection.forEach(function (model) {
            this.addRow(model);
        }, this);

        return this;
    },

    addRow: function (model) {
        var row = new TicketView({
            model: model,
            usePrintTemplate: (this.template === this.printTemplate)
        });

        this.$(".links").prepend(row.render().el);
    },
    // END Rendering
    /////////

    /////////
    // Events
    events: {
        "click .print": "togglePrint"
    },
    // END Events
    /////////////

    /////////////
    // Behavior
    togglePrint: function () {
        if (this.template === this.defaultTemplate)
            this.template = this.printTemplate;
        else
            this.template = this.defaultTemplate;

        console.log("toggle print");
        this.render();
    }
    // END Behavior
    ////////////
});

    ///////////////// TODO: DRY ////////////////////


    var FileSharingLinkView = Backbone.View.extend({
        initialize: function (options) {
            if (options.usePrintTemplate) {
                this.template = this.printTemplate;
            }

            this.listenTo(this.model, "destroy", this.remove);
        },

        /////////
        // Rendering
        template: _.template($("#template-publicLink").html()),
        printTemplate: _.template($("#template-publicLink-print").html()),
        tagName: "tr",

        render: function () {
            this.$el.html(this.template(this.model.attributes));

            return this;
        },
        // END Rendering
        /////////

        /////////
        // Events
        events: {
            "click .remove": "stopSharing"
        },
        // END Events
        /////////////

        /////////////
        // Behavior
        stopSharing: function () {
            var me = this;
            var data = {
                manage_file: "ticket",
                sharing: false,
                fileID: this.model.get("fileID")
            };

            $.ajax({
                type: 'GET', //MEH...
                cache: false,   // not working????
                url: resourcesPath,
                dataType: "text",   //we want plaintext for MSTE parsing, not a JS array
                data: data,
                success: function (msteString) {
                    var decodedMSTE = MSTE.parse(msteString).root;
                    console.log(decodedMSTE);

                    me.model.destroy();
                },
                error: function (jqXHR, textStatus) {
                    console.log("ERROR in Ajax Response: " + textStatus);
                    window.location = basePath + "login";   // send event to app, which does the logout
                }
            });
        }
        // END Behavior
        ////////////
    });

    var FileSharingLinksView = Backbone.View.extend({
        initialize: function () {
            this.listenTo(this.collection, 'add', this.addRow);               //todo: don't rerender all

            this.template = this.defaultTemplate;
        },

        /////////
        // Rendering
        defaultTemplate: _.template($("#template-publicLinks").html()),
        printTemplate: _.template($("#template-tickets-print").html()),

        render: function () {
            this.$el.html(this.template());

            this.collection.forEach(function (model) {
                this.addRow(model);
            }, this);

            return this;
        },

        addRow: function (model) {
            var row = new FileSharingLinkView({
                model: model,
                usePrintTemplate: (this.template === this.printTemplate)
            });

            this.$(".links").prepend(row.render().el);
        },
        // END Rendering
        /////////

        /////////
        // Events
        events: {
            "click .print": "togglePrint"
        },
        // END Events
        /////////////

        /////////////
        // Behavior
        togglePrint: function () {
            if (this.template === this.defaultTemplate)
                this.template = this.printTemplate;
            else
                this.template = this.defaultTemplate;

            console.log("toggle print");
            this.render();
        }
        // END Behavior
        ////////////
    });




    //////////////////////////////////////



var UploadSharingView = Backbone.View.extend({
        initialize: function () {
            this.listenTo(this.model, 'change:loading', this.toggleLoading);
        },

        /////////
        // Rendering
        template: _.template($("#template-uploadSharing").html()),

        render: function () {
            this.$el.html(this.template(this.model.attributes));

            var ticketsView = new TicketsView({collection: this.collection});
            this.$(".panel-footer").html(ticketsView.render().el);

            this.$('.selectpicker').selectpicker(); //activate picker
            this.$('.selectpicker').selectpicker('val', App.page.get("ticketDuration")); // select value, simpler to do here than in template
            this.$('.selectpicker').selectpicker('render');// need re-render because of visual bug


            console.log(this.$('.selectpicker'));

            return this;
        },
        // END Rendering
        /////////

        /////////
        // Events
        events: {
            "hidden.bs.modal #uploadSharingModal": "remove",         // does it work with just "hidden.bs.modal"????
            "shown.bs.modal #uploadSharingModal": "focus",
            "submit form": "onSubmit"
        },
        // END Events
        /////////////

        /////////////
        // Behavior
        focus: function () {
            this.$(".userName").val("").focus();
        },

        onSubmit: function (event) {
            var me = this;
            var form = $(event.currentTarget);
            var userName = this.$(".userName").val();           //meh, should be returned by server on completion of request

            var validityPeriod = parseInt(this.$(".validityPeriod").val());
            var expiration; //meh, should be returned by server on completion of request
            if (validityPeriod === 0) {
                expiration = polyglot.t("never");
            } else {
                expiration = (new Date(Date.now() + validityPeriod * 1000)).toFrenchString();
            }

            event.preventDefault();
            me.model.set({loading: true});

            $.ajax({
                type: 'GET', //MEH...
                cache: false,   // not working????
                url: resourcesPath,
                dataType: "text",   //we want plaintext for MSTE parsing, not a JS array
                data: form.serialize(),
                success: function (msteString) {
                    me.model.set({loading: false});

                    var decodedMSTE = MSTE.parse(msteString).root;
                    console.log(decodedMSTE);

                    ///////////////////
                    /////////////////// MODIF
                    ///////////////////
                    var ticket = new Ticket(decodedMSTE, {parse: true});
                    ticket.set({userName: userName});
                    ticket.set({expiration: expiration});
                    ticket.set({fileID: me.model.get("fileName")});         //meh, should be kept at a higher level: the owner of the collection. This is just repetition of the value
                    me.collection.add(ticket);
                },
                error: function (jqXHR, textStatus) {
                    console.log("ERROR in Ajax Response: " + textStatus);
                    window.location = basePath + "login";   // send event to app, which does the logout
                }
            });

            this.focus();
        },

        toggleLoading: function (model, value) {                //TODO: parent class with toggleLoading power, with children the modals that use it
            if (value) {
                $("button.saveForm").button('loading');
            } else {
                $("button.saveForm").button('reset');
            }
        }
        // END Behavior
        ////////////
    });

    // TODO: DRY (make template slightly different: change hidden manage_file field for example)
    var FileSharingView = Backbone.View.extend({
        initialize: function () {
            this.listenTo(this.model, 'change:loading', this.toggleLoading);
        },

        /////////
        // Rendering
        template: _.template($("#template-fileSharing").html()),

        render: function () {
            this.$el.html(this.template(this.model.attributes));

            var fileSharingLinksView = new FileSharingLinksView({collection: this.collection});
            this.$(".panel-footer").html(fileSharingLinksView.render().el);

            this.$('.selectpicker').selectpicker(); //activate picker
            this.$('.selectpicker').selectpicker('val', App.page.get("publicLinkDuration")); // select value, simpler to do here than in template
            this.$('.selectpicker').selectpicker('render');// need re-render because of visual bug


            console.log(this.$('.selectpicker'));

            return this;
        },
        // END Rendering
        /////////

        /////////
        // Events
        events: {
            "hidden.bs.modal #fileSharingModal": "remove",         // does it work with just "hidden.bs.modal"????
            "shown.bs.modal #fileSharingModal": "focus",
            "submit form": "onSubmit"
        },
        // END Events
        /////////////

        /////////////
        // Behavior
        focus: function () {
            this.$(".userName").val("").focus();
        },

        onSubmit: function (event) {
            var me = this;
            var form = $(event.currentTarget);

            var validityPeriod = parseInt(this.$(".validityPeriod").val());
            var expiration; //meh, should be returned by server on completion of request
            if (validityPeriod === 0) {
                expiration = polyglot.t("never");
            } else {
                expiration = (new Date(Date.now() + validityPeriod * 1000)).toFrenchString();
            }

            event.preventDefault();
            me.model.set({loading: true});

            $.ajax({
                type: 'GET', //MEH...
                cache: false,   // not working????
                url: resourcesPath,
                dataType: "text",   //we want plaintext for MSTE parsing, not a JS array
                data: form.serialize(),
                success: function (msteString) {
                    me.model.set({loading: false});

                    var decodedMSTE = MSTE.parse(msteString).root;
                    console.log(decodedMSTE);

                    decodedMSTE = decodedMSTE[0];

                    ///////////////////
                    /////////////////// MODIF
                    ///////////////////
                    var sharedFileLink = new PublicLink(decodedMSTE, {parse: true});
                    sharedFileLink.set({expiration: expiration});
                    sharedFileLink.set({fileID: me.model.get("fileName")});         // TODO:NECESSARY??? meh, should be kept at a higher level: the owner of the collection. This is just repetition of the value
                    me.collection.add(sharedFileLink);
                },
                error: function (jqXHR, textStatus) {
                    console.log("ERROR in Ajax Response: " + textStatus);
                    window.location = basePath + "login";   // send event to app, which does the logout
                }
            });

            this.focus();
        },

        toggleLoading: function (model, value) {                //TODO: parent class with toggleLoading power, with children the modals that use it
            if (value) {
                $("button.saveForm").button('loading');
            } else {
                $("button.saveForm").button('reset');
            }
        }
        // END Behavior
        ////////////
    });
// END Views
//////



///////
// App
var App = Backbone.View.extend({
    Collections: {},
    Models: {},
    Views: {},
    AppRouter: new (Backbone.Router.extend({}))(),

    /////////
    // Constructor
    initialize: function () {
        App.page = new Page(bootstrapData);                         // MEH?
        this.items = new Items(bootstrapData.items, {
            parse: true
        });
        this.breadcrumbs = new Breadcrumbs(bootstrapData.currentPath);        // new Items or Breadcrumbs???? ?? BUGBUG
        this.myAccount = new MyAccount();           // currently empty

        document.title = polyglot.t("file_repository");

        //Backbone.history.start({pushState: "pushState" in window.history});

        // Handle selectable inputs and textareas
        $(document).on("mousedown", ".copyable", function (event) {
            if (event.which === 3) {
                var $textToSelect = $(event.target);
                $textToSelect.focus().select();

                /* $textToSelect.on("mouseleave", function (event) {
                 $textToSelect.blur();
                 $textToSelect.off("mouseleave");
                 });*/
            }
        });

        $(document).on("click", ".copyable", function (event) {
            if (event.which === 1) {
                var $textToSelect = $(event.target);
                $textToSelect.focus().select();
            }
        });

        this.render();
    },
    // END Constructor
    /////////

    /////////
    // Rendering
    template: _.template($("#template-app").html()),
    render: function () {
        this.$el.html(this.template(App.page.attributes));

        this.tableView = new TableView({collection: this.items});
        this.$("#table").html(this.tableView.render().el);

        this.breadcrumbsView = new BreadcrumbsView({collection: this.breadcrumbs}); //, {parse: true} ???
        this.$("#breadcrumbs").html(this.breadcrumbsView.render().el);

    /////// MEH: activate bootstrap pickers
        console.log("ACTIVATING SELECTPICKERS");
        console.log(this.$('.selectpicker'));
        this.$('.selectpicker').selectpicker(); //activate picker
        this.$('.selectpicker').selectpicker('val', App.page.get("publicLinkDuration")); // select value, simpler to do here than in template
        this.$('.selectpicker').selectpicker('render');// need re-render because of visual bug

        this.onSelectRow(); // init delete and share based on whether row are selected or not

/*
        ///////////////    TODO: own widget, and bring in clicks cancel and upload here too
        // FILE UPLOAD
        var me = this;
        $(document)
            .on('change', '.btn-file :file', function() {
                var input = $(this),
                    numFiles = input.get(0).files ? input.get(0).files.length : 1,
                    label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
                input.trigger('fileselect', [numFiles, label]);
            });

        $(document).ready( function() {
            $('.btn-file :file').on('fileselect', function(event, numFiles, label) {

                var input = $('.fileupload-preview'),
                    log = numFiles > 1 ? numFiles + ' files selected' : label;

                input.text(log);

                if (numFiles >= 1) {
                    me.$('.addFile').hide();
                    me.$('.icon').show();
                    me.$('.changeFile').show();
                    me.$('.cancel').show();
                    me.$('.upload').show();
                } else {
                    me.$('.addFile').show();
                    me.$('.icon').hide();
                    me.$('.changeFile').hide();
                    me.$('.cancel').hide();
                    me.$('.upload').hide();
                }


            });

            $('.cancel').on('click', function(event) {
                var fileInput = $('.btn-file :file');
                fileInput.replaceWith(fileInput = fileInput.clone( true ) );
                fileInput.trigger('fileselect', [0, ""]);
            });
        });

        this.$('.addFile').show();
        this.$('.icon').hide();
        this.$('.changeFile').hide();
        this.$('.cancel').hide();
        this.$('.upload').hide();
        // END File Upload
        ////////////////
*/

        return this;
    },
    // END Rendering
    /////////

    /////////
    // Events
    events: {
        "click a[data-backbone]" : function (event) {
            event.preventDefault();
            Backbone.history.navigate(event.target.pathname, {trigger: true});
        },
        "click #checkAll" : "checkAll",
        "click input.select-row" : "onSelectRow",

        "click #fileSubmit" : "uploadFile",                     // TODO: cut stuff out of template for reuse
        "click .fileupload .btn.cancel": "cancelUpload",

        "click #logout" : "logout",
        "click button.deleteFiles" : "deleteFiles",
        "click button.shareFiles" : "shareFiles",
        "click button.newDirectory" : "newDirectory",
        "click #myAccount" : "onMyAccount",
        "input #file_management_form .directoryName": "inputDirectoryName"
    },
    // END Events
    ////////

    ///////
    // Behavior
    checkAll: function (event) {
        if ($("#checkAll").is(':checked')) {
           // this.items.doCheckAll();              // TODO: use items collection
            $("input:checkbox").prop( "checked", true);
        } else {
           // this.items.doUncheckAll();
            $("input:checkbox").prop( "checked", false);
        }

        this.onSelectRow();
    },

    onSelectRow: function (event) {
        var counter = 0;
        var allCheckboxes = this.$("input.select-row");
        var nbCheckboxes = allCheckboxes.length;

        allCheckboxes.each(function (index, element) {
            if ($(element).is(':checked')) {
                counter++
            }
        });

        if (counter > 0) {
            this.enableDelete();
            this.enableShare();
        } else {
            this.disableDelete();
            this.disableShare();
        }

        if (counter === nbCheckboxes) {
            this.checkSelectAll();
        } else {
            this.uncheckSelectAll();
        }
    },

    uploadFile: function (event) {
        this.$(".fileupload .btn.add").hide();
        this.$(".fileupload .btn.upload").addClass('fileupload-new').removeClass('fileupload-exists');

        handleRequestStateChange();
    },

    cancelUpload: function () {
        var uploadTarget = this.$('#upload_target')[0]; //get dom el
        uploadTarget.src = "javascript:false";
    },

    logout: function () {
        //window.open(window.location.protocol + "//" + window.location.host + basePath + "login", "_self");
        window.location = basePath + "login";
    },

    deleteFiles: function () {
        this.$("#file_management_form").append('<input type="hidden" name="manage_file" value="Delete" />').submit();
    },

    shareFiles: function () {
        var data = this.$("#file_management_form").append('<input type="hidden" name="manage_file" value="ShareFiles" />').serialize();
        this.doShareFiles(data);
    },

    doShareFiles: function (data) {
        var me = this;

        $.ajax({
            type: 'GET',
            cache: false,   // not working????
            url: resourcesPath,
            dataType: "text",
            data: data,
            success: function (msteString) {
                var decodedMSTE = MSTE.parse(msteString).root;
                console.log(decodedMSTE);

                //var links = [{sharing: true, publicLink: "a"}, {sharing: true, publicLink: "b"}];
                var linksCollection = new PublicLinks(decodedMSTE, {parse: true});

                if (linksCollection.length > 0) {
                    // Show sharing links for selected files
                    var linksView = new LinksView({collection: linksCollection});
                    $("#app").append(linksView.render().el);
                    $("#linksModal").modal({show: true});

                    ///////////////////
                    /////////////////// MODIF
                    ///////////////////

                    // Set link and toggle properly based on value of sharing // TODO: this should be done automatically by having this collection = items
                    // Go through collection and set sharing on Items
                    linksCollection.forEach(function (model) {
                        var fileName = model.get("fileName");
                        //var sharing = model.get("sharing");
                        //var publicLink = model.get("publicLink");

                        // find item in Items by id
                        var correspondingModel = me.items.find(function(item){
                            return item.get('fileName') === fileName;
                        });

                        model.set("expiration", 0);       // BUG TEMPFIX
                        correspondingModel.publicLinks.add(model);
                        //correspondingModel.set('sharing', sharing);
                        //correspondingModel.set('publicLink', publicLink);
                    });
                }

            },
            error: function (jqXHR, textStatus) {
                console.log("ERROR in Ajax Response: " + textStatus);
                window.location = basePath + "login";   // send event to app, which does the logout
            }
        });
    },

    newDirectory: function () {
        this.$("#file_management_form").append('<input type="hidden" name="manage_file" value="New Directory" />').submit();
    },

    inputDirectoryName: function (e) {
        if( !this.$('#file_management_form .directoryName').val() ) {
            this.$('#file_management_form .newDirectory').prop("disabled", true);
        } else {
            this.$('#file_management_form .newDirectory').prop("disabled", false);
        }
    },

    onMyAccount: function (e) {
        var myAccountView = new MyAccountView({model: this.myAccount});
        $("#app").append(myAccountView.render().el);
        $("#myAccountModal").modal({show: true});
    },
    // END Behavior
    ////////


    /////////
    // Helpers
    enableDelete: function () {
        this.$('button.deleteFiles').prop('disabled', false);
    },

    enableShare: function () {
        this.$('button.shareFiles').prop('disabled', false);
        this.$('.selectpicker').prop('disabled', false);
    },

    disableDelete: function () {
        this.$('button.deleteFiles').prop('disabled', true);
    },

    disableShare: function () {
        this.$('button.shareFiles').prop('disabled', true);
        this.$('.selectpicker').prop('disabled', true);
    },

    uncheckSelectAll: function () {
        this.$("#checkAll").prop( "checked", false);
    },

    checkSelectAll: function () {
        this.$("#checkAll").prop( "checked", true);
    }
    // END Helpers
    ////////
});

var app = new App({
    el: $("#app")
});
// END App
///////

});