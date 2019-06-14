<!doctype html>
<html lang="en">
<head>
    <title>Exams Management System</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Contact Form</title>
    <link rel="stylesheet" href="assets/css/contact.css">
    <link rel="stylesheet" href="assets/css/bootstrap.css">
    <link rel="stylesheet" href="assets/css/topback.css">
    <!--script for button top and back-->
    <script src="assets/js/topback.js"></script>
</head>
<body >
    
  	<div class="mynav navbar navbar-inverse navbar-fixed-top " id="menu" >
        <div class="container">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>

                <a class="navbar-brand" href="index.html">
                <img class="logo-custom" src="assets/img/suez.png" alt=Suez University Drop Logo" />
                </a>
                <h1 id="nameweb">Suez  University</h1>
            </div>
            <div class="navbar-collapse collapse move-me">
                    <ul class="nav navbar-nav navbar-right">
                        <li class="mi">
                                <a href="index.html">home</a>
                        </li>
                        <li class="mi">
                                <a href="log.html">login</a>
                        </li> 
                    </ul>
                                                               
                </div>
    
            </div>
                                                               
        </div>
    <center><h1 class="h">Contact Us</h1>
    </center>
    <center>
    <img class="social" src="assets/img/social/facebook.png">
    <img class="social" src="assets/img/social/twitter.png">
    <img class="social" src="assets/img/social/instagram.png">
    <img class="social" src="assets/img/social/linkedin.png">
    <img class="social" src="assets/img/social/whatsapp.png">
    <img class="social" src="assets/img/social/youtube.png">
    </center>
    <div class="container" style="margin-top:10px;">
        <div class="row justify-content-center">
            <div class="m col-md-6 col-md-offset-3" align="center">
                <input id="name" placeholder="Name" class="form-control" style='border: 2px solid green;'>
                <input id="email" placeholder="Email" class="form-control" style='border: 2px solid green;'>
                <input id="subject" placeholder="Subject" class="form-control" style='border: 2px solid green;'>
                <textarea class="form-control" id="body" placeholder="Email Body" rows="7" style='border: 2px solid green;'></textarea>
                <input type="button" onclick="sendEmail()" value="Send An Email" class="btn btn-primary c" >
            </div>
        </div>
    </div>

    <script src="http://code.jquery.com/jquery-3.3.1.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
    <script type="text/javascript">
        function sendEmail() {
            var name = $("#name");
            var email = $("#email");
            var subject = $("#subject");
            var body = $("#body");

            if (isNotEmpty(name) && isNotEmpty(email) && isNotEmpty(subject) && isNotEmpty(body)) {
                $.ajax({
                   url: 'sendEmail.php',
                   method: 'POST',
                   dataType: 'json',
                   data: {
                       name: name.val(),
                       email: email.val(),
                       subject: subject.val(),
                       body: body.val()
                   }, success: function (response) {
                        if (response.status == "success")
                            alert('Email Has Been Sent!');
                        else {
                            alert('Please Try Again!');
                            console.log(response);
                        }
                   }
                });
            }
        }

        function isNotEmpty(caller) {
            if (caller.val() == "") {
                caller.css('border', '1px solid red');
                return false;
            } else
                caller.css('border', '');

            return true;
        }
    </script>







<div><a id='mina' href="javascript:history.go(-1)"onMouseOver="self.status.referrer;return true">Back</a></div>
<button onclick="topFunction()" id='myBtn' title="Go to top">Top</button>

<div id="footer" class="page-footer font-small blue pt-4" >
&copy 2019 smallproject.com | All Rights Reserved |
</div>
</body>
</html>