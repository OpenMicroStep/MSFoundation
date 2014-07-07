// TODO: share code instead of copy paste

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

//$("#fileSubmit").attr('disabled', 'enabled');
//$("#fileSubmit").removeAttr('disabled');

function handleRequestStateChange(){
    var urlSplit = window.location.toString().split("?");
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
                var userName = $('#userName').val();

                myForm.action = url+"upload?id="+uploadId+"&type=storable&userName="+userName;
                myForm.method = "POST";
                myForm.enctype = "multipart/form-data";
                myForm.target = 'upload_target';

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
                                myComponent.width("0%")
                                $(".progress").hide();

                                // message error
                                $("#core .messages").prepend((_.template($("#template-alert").html()))({fileName: fileName}));

                                $(".fileupload .btn.add").show();
                                $(".fileupload .btn.upload").addClass('fileupload-exists').removeClass('fileupload-new');

                                clearInterval(interval);
                            }
                            if (responseObject.upload_status === 4) {
                                myComponent.width("0%")
                                $(".progress").hide();

                                //message success
                                $("#core .messages").prepend((_.template($("#template-success").html()))({fileName: fileName}));

                                //Reset the field
                                $(".fileupload").fileupload("reset");

                                $(".fileupload .btn.add").show();
                                $(".fileupload .btn.upload").addClass('fileupload-exists').removeClass('fileupload-new');

                                clearInterval(interval);
                            }
                        }
                    }
                }

                mycontrolrequest.open("GET", url+"getUploadStatus?id="+uploadId+"&cachebusting="+Math.floor(Math.random()*99999999999999999999999), true);
                mycontrolrequest.send(null);

                // Status request loop
                var interval = setInterval( function () {
                    mycontrolrequest.open("GET", url+"getUploadStatus?id="+uploadId+"&cachebusting="+Math.floor(Math.random()*99999999999999999999999), true);
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
            //Backbone.history.start({pushState: "pushState" in window.history});

            document.title = polyglot.t("upload");

            this.render();
        },
        // END Constructor
        /////////

        /////////
        // Rendering
        template: _.template($("#template-app").html()),
        render: function () {
            this.$el.html(this.template(target));

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
            "click #fileSubmit" : "uploadFile",
            "click #logout" : "logout",
            "click .fileupload .btn.cancel": "cancelUpload"
        },
        // END Events
        ////////

        ///////
        // Behavior
        logout: function () {
            window.location = basePath + "login";
        },

        uploadFile: function (event) {
            this.$(".fileupload .btn.add").hide();
            this.$(".fileupload .btn.upload").addClass('fileupload-new').removeClass('fileupload-exists');

            handleRequestStateChange();
        },

        cancelUpload: function () {
            var uploadTarget = this.$('#upload_target')[0]; //get dom el
            uploadTarget.src = "javascript:false";
        }
        // END Behavior
        ////////
    });

    var app = new App({
        el: $("#app")
    });
// END App
///////
});