<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ArtistGoogleImage.Default" %>

<!DOCTYPE html>

<!-- Responsive design: Portrait: -->
<meta id="viewport" name="viewport" content="width=device-width, initial-scale=1.0">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Google Image Finder</title>

    <link rel="icon"       type="image/x-icon" href="favicon.ico" />
    <link rel="stylesheet" type="text/css"     href="Site.css" />
    <link rel="stylesheet" type="text/css"     href="banner.css" />
    <link rel="stylesheet" type="text/css"     href="StandardStreams.css" />

    <script src="StandardStreams.js"           type="text/javascript"></script>
    <script src="WorkingWebBrowserServices.js" type="text/javascript"></script>

    <script type="text/javascript">

        //-----------------------------------------------------------------------------------------
        // Responsive web design is an approach that makes web pages render well on a variety of
        // devices and window or screen sizes.  Search for "responsive".
        window.addEventListener("orientationchange", function () {

            // The NOTE and processing below is taken from application ArtistMaint.  That app
            // had no problem when switching back to portrait mode.  This app does, though the
            // zooming is out, not in.  What a mess!  Here, the message will be generic and
            // apply to both portrait and landscape:
            alert("Correcting resizing error...");

            if (window.orientation == 0) {

                // Portrait:
                document.getElementById("viewport").setAttribute("content", "initial-scale=1.0");
            }
            else {
                // NOTE: It is a known problem that, on changing to landscape mode, the browser
                // fully zooms the page.  I have seen it documented for both Android and I-Phone.
                // Unfortunately, non of the solutions suggested worked for me.  In the course of
                // my debugging, I saw that a simple messagebox somehow short-circuits the problem.

                // Having wasted enough time on this, I will wait a few years, check back, and see
                // if the problem has been fixed.

                // Landscape:
                //alert("Correcting landscape resizing error...");
                document.getElementById("viewport").setAttribute("content", "initial-scale=0.5");
            }

        }, false);
        //---------------------------------------------------------------------------------------------------

        // <HEAD> GLOBAL VARIABLES:

        // This will be filled in main():
        var standard_streams_services;

        // This will be filled in load_artists_array();
        var artists;

        // <HEAD> AVAILABLE FUNCTIONS:

        function main() {

            //---------------------------------------------------------------------
            // Responsive design:
            if (window.innerWidth < 700) {
                document.getElementById("bannerDivFull").style.display = "none";
            }
            else {
                document.getElementById("bannerDivPhone").style.display = "none";
            }
            //---------------------------------------------------------------------

            // NOTE: All output of all types will be handled by this service:
            standard_streams_services = new standard_streams();

            // Inform the user of this policy:
            standard_streams_services.write("message", "For Custom Search Engine users, the API provides 100 search queries per day for free. If you need more, you may sign up for billing in the API Console. Exceeding this limit produces a 403 (Forbidden) error.");

        }

        function ButtonAbout_onclick() {

            open_popup_window(
                "About.aspx",
                true, // modal dialog
                "no", // resizable
                "no", // scrollbars
                505,  // width
                660   // height
            );

        }

        function get_google_artist_images() {

            // Fill the array with user-entered artists:
            var user_entered_artists = 
                accept_clean_parse_to_array(
                    document.getElementById("user_entered_artists").value,
                    true // sort the resultant array
                );

            var artist_image_url = new Array(); // init

            // For each artist, look up and save the URL of the Google image:
            for (var i = 0; i < user_entered_artists.length; i++) {
                artist_image_url.push(get_google_artist_image(user_entered_artists[i]));
            }

            // Init:
            var artists_HTML_string = "";
            artists = new Array;

            // NOTE: If there is, for eg., only one entry, newspaper will break up the image
            // and its caption across columns:
            if (artist_image_url.length > 2) {

                // Style as "newspaper" columns:
                document.getElementById(standard_streams_services.OUTPUT_FIELD).className = "newspaper";
            } else {
                // Clear the style:
                document.getElementById(standard_streams_services.OUTPUT_FIELD).className = "";
            }

            for (var i = 0; i < artist_image_url.length; i++) {

                if (artist_image_url[i] != "") {

                    // Assemble the report HTML:
                    artists_HTML_string += "<p>" + user_entered_artists[i] + "</p>";
                    artists_HTML_string += '<img src="' + artist_image_url[i] + '" class="artistImage" >';

                    // Load the JSON array:
                    load_artists_array(user_entered_artists[i], artist_image_url[i])

                }

            }

            // Assemble the JSON as a string:
            var artists_JSON_string = JSON.stringify(artists);

            // Write both outputs, HTML and JSON:
            document.getElementById("artists_json").value = artists_JSON_string;
            standard_streams_services.clear("output");
            standard_streams_services.write("output", artists_HTML_string);

            //-----------------------------------
            // [
            //    {
            //        "artist": "Elton John",
            //        "imageUrl": "XXX"
            //    },
            //    {
            //        "artist": "Paul Simon",
            //        "imageUrl": "YYY"
            //    }
            // ]
            //-----------------------------------

        }

        function get_google_artist_image(artist) {

            // Constants:
            var GOOGLE_IMAGE_PREFIX = "http://www.workingweb.info/Utility/WorkingWebWebServices/api/GoogleImage/?number=1&request=";
            var ARTIST_PREFIX = "music+group+singer+";

            // Since we will be modifying the argument, let's make a copy and work with that:
            var artist_edited = artist;

            // Alas the "modern world" has some very lame bands that supersede these:
            if (artist_edited == "The Band") {
                artist_edited = "Dylan's The Band";
            } else if (artist_edited == "The Beat") {
                artist_edited = "The English Beat";
            }

            // Construct the Google Image web service URL:
            var artist_formatted = replace_all(artist_edited, " ", "+");

            var google_image_url = GOOGLE_IMAGE_PREFIX + ARTIST_PREFIX + artist_formatted;

            // Google Image web service:
            // http://www.workingweb.info/Utility/WorkingWebWebServices/api/GoogleImage/?number=1&request=music+group+singer+elton+john

            //--------------------------------------------------------------------------------------------------------------------------
            // These are for testing:
            var SUCCESSFUL_RESPONSE = '{"images":["http://www.mtishows.com/sites/default/files/profile/elton-john.jpg?download=1"]}';
            var ERROR_EMPTY_RESPONSE = '{"images":[]}';
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // Unfortunately, this API is subject to this limit.  I must make all test/run cycles count.  Test in small batches, ones,
            // threes, elevens at the most.  When possible, test from these string values instead of the Google server.
            //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            // This occurs on the server:
          //var ERROR_DAILY_LIMIT = '{"error":{"errors":[{"domain":"usageLimits","reason":"dailyLimitExceeded","message":"This API requires billing to be enabled on the project. Visit https://console.developers.google.com/billing?project=124542758258 to enable billing.","extendedHelp":"https://console.developers.google.com/billing?project=124542758258"}],"code":403,"message":"This API requires billing to be enabled on the project. Visit https://console.developers.google.com/billing?project=124542758258 to enable billing."}}';
            // This occurs on the client
            var ERROR_DAILY_LIMIT = '{"Message":"An error has occurred.","ExceptionMessage":"The remote server returned an error: (403) Forbidden.","ExceptionType":"System.Net.WebException","StackTrace":"   at System.Net.WebClient.DownloadDataInternal(Uri address, WebRequest& request)\r\n   at System.Net.WebClient.DownloadString(Uri address)\r\n   at System.Net.WebClient.DownloadString(String address)\r\n   at WorkingWebWebServices.GoogleImage.GoogleImageHelper.GetGoogleImageCustomSearchResponse(Int32 intPage, String strCustomSearch) in C:\\a_dev\\ASP\\WorkingWebWebServices\\WorkingWebWebServices\\GoogleImage\\GoogleImageHelper.cs:line 178\r\n   at WorkingWebWebServices.GoogleImageController.Get(String request, Int32 number) in C:\\a_dev\\ASP\\WorkingWebWebServices\\WorkingWebWebServices\\GoogleImageController.cs:line 61\r\n   at lambda_method(Closure , Object , Object[] )\r\n   at System.Web.Http.Controllers.ReflectedHttpActionDescriptor.ActionExecutor.<>c__DisplayClass10.<GetExecutor>b__9(Object instance, Object[] methodParameters)\r\n   at System.Web.Http.Controllers.ReflectedHttpActionDescriptor.ActionExecutor.Execute(Object instance, Object[] arguments)\r\n   at System.Web.Http.Controllers.ReflectedHttpActionDescriptor.ExecuteAsync(HttpControllerContext controllerContext, IDictionary`2 arguments, CancellationToken cancellationToken)\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Web.Http.Controllers.ApiControllerActionInvoker.<InvokeActionAsyncCore>d__0.MoveNext()\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Web.Http.Controllers.ActionFilterResult.<ExecuteAsync>d__2.MoveNext()\r\n--- End of stack trace from previous location where exception was thrown ---\r\n   at System.Runtime.CompilerServices.TaskAwaiter.ThrowForNonSuccess(Task task)\r\n   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)\r\n   at System.Web.Http.Dispatcher.HttpControllerDispatcher.<SendAsync>d__1.MoveNext()"}';
            //--------------------------------------------------------------------------------------------------------------------------

            // Get the Google page content:
            var response = get_xml_http_request(google_image_url);
          //var response = ERROR_EMPTY_RESPONSE;
          //var response = ERROR_DAILY_LIMIT;
          //var response = SUCCESSFUL_RESPONSE;

            // The JSON comes with "pretty" stuff:
            response = remove_all_procedural(response, "\\r");
            response = remove_all_procedural(response, "\\n");

            // The double quotes have slashes:
            response = remove_all_procedural(response, "\\");

            // The whole JSON string is wrapped in quotes:
            response = replace_all(response, '"{', '{');
            response = replace_all(response, '}"', '}');

            var artist_image_url = ""; // init

            // NOTE: A 403 (Forbidden) error is probably a "usageLimits"/"dailyLimitExceeded" error:
            if (response.indexOf("403") > -1) {

                // Write a shortened version of the error message:
                standard_streams_services.write("error", artist + ": " + response.substr(0, 125) + "...");
            } else {

                try {

                    // 1) JSON string to, 2) JSON object to, 3) URL string:
                    var JSON_object = JSON.parse(response);
                    if (JSON_object.images.length > 0) {
                        artist_image_url = JSON_object.images[0];
                    }

                } catch (e) {

                    // An unexpected error.  Write the full error message:
                    standard_streams_services.write("error", artist + ": " + e.message);
                }

            }

            // Return the final result, a URL string.  Errors return an empty string:
            return artist_image_url;

        }

        function load_artists_array(name, image_url) {

            var artist = new Object;
            artist.artist = name;
            artist.imageUrl = image_url;

            artists.push(artist);

        }

    </script>

</head>
<body class="BaseColor">

    <!--------------------------- Responsive design: --------------------------->
    <!-- For Full Size Monitors: -->
    <div id="bannerDivFull" class="bannerDiv">
        <img src="google100X100transparent.png" alt="Google Logo" />
        <span id="bannerTextFull" class="bannerText">Google Image Finder</span>
    </div>
    
    <!-- For Cell Phones: -->
    <div id="bannerDivPhone" class="bannerDiv">
        <img src="google100X100transparent.png" alt="Google Logo" />
        <br/>
        <span id="bannerTextPhone" class="bannerText">Google Image Finder</span>
    </div>
    <!-------------------------------------------------------------------------->

    <form id="form1" runat="server">

        <br />
        <span>Artists separated by line breaks:</span>
        <br />
        <textarea id="user_entered_artists" rows="8" cols="35"></textarea>
        <br />
        <br />

        <input id="run" type="button" onclick="get_google_artist_images()" value="Get Google Artist Images"/>&nbsp;
        <input id="ButtonAbout" type="button" value="About" onclick="return ButtonAbout_onclick()"/>
        <br/>
        <br/>
        
        <%------------------------------------------------------------------------------------------------------------------%> 
        <!-- This shows the "standard footer" for my GUI forms. -->
        <!--#include file="StandardStreams.htm"-->
        <%------------------------------------------------------------------------------------------------------------------%>

        <br/>
        <a href="http://jsonformatter.curiousconcept.com/" target="_blank">JSON Formatter & Validator</a>        
        <br/>
        <br/>
        <a href="http://www.convertcsv.com/json-to-csv.htm" target="_blank">JSON to CSV/Excel Converter</a>        
        <br/>
        <br/>

        <textarea id="artists_json" readonly="readonly" rows="1" cols="1"></textarea>

        <script type="text/javascript">

            // <BODY> STARTUP PROCESSING:

            main();

        </script>

    </form>
</body>
</html>
