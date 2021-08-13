<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>BCamp - PT. POS Financial</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <!-- App favicon -->
    <link rel="shortcut icon" href="assets/images/favicon.ico">

    <!-- App css -->
    <link href="{{ asset('css/bootstrap.min.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/login/icons.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/login/style.css') }}" rel="stylesheet" type="text/css">
    <script src="{{ asset('js/login/modernizr.min.js') }}"></script>

</head>

<body>
    <div class="accountbg" style="background: url({{ asset('images/login-background.png') }});background-size: cover;background-position: center;"></div>

    <div class="wrapper-page account-page-full" style="width: 400px;">

        <div class="card">
            <div class="card-block">

                <div class="account-box">

                    @yield('content')

                </div>

            </div>
        </div>

        <div class="m-t-40 text-center">
            <p class="account-copyright">2021 © BCamp PT. POS Financial</p>
        </div>

    </div>


    <!-- Core JS files -->
    <script src="{{ asset('js/main/jquery.min.js') }}"></script>
    <script src="{{ asset('js/main/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('js/login/waves.js') }}"></script>
    <script src="{{ asset('js/login/jquery.slimscroll.js') }}"></script>
    <script src="{{ asset('js/login/jquery.core.js') }}"></script>
    <script src="{{ asset('js/login/jquery.app.js') }}"></script>

</body>
</html>
