<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>BCamp - PT. POS Financial</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <link rel='icon' href='{{ asset('images/favicon_01.ico') }}' type='image/x-icon'>



    <!-- Global stylesheets -->
    <link href="{{ asset('css/font-googleapis.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/icons/icomoon/styles.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/bootstrap.min.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/bootstrap_limitless.min.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/layout.min.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/components.min.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/colors.min.css') }}" rel="stylesheet" type="text/css">
    <link href="{{ asset('css/loader.css') }}" rel="stylesheet" type="text/css">
    <!-- /global stylesheets -->

    {!! Charts::styles() !!}

    @stack('styles')

</head>

<body>

    @include('_includes/_loader')

    {{-- header --}}
    @include('_includes/_header')
    <!-- /main navbar -->


    <!-- Secondary navbar -->
    @include('_includes/_navbar')
    <!-- /secondary navbar -->
    @include('_includes/_breadcrumb')


    <!-- Page content -->
    <div class="page-content pt-0">

        <!-- Main content -->
        <div class="content-wrapper">

            <!-- Content area -->
            <div class="content">

                @yield('content')

            </div>
            <!-- /content area -->

        </div>
        <!-- /main content -->

    </div>
    <!-- /page content -->




    <!-- Footer -->
    @include('_includes/_footer')
    <!-- /footer -->


    <!-- Core JS files -->
    <script src="{{ asset('js/main/jquery.min.js') }}"></script>
    <script src="{{ asset('js/main/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('js/loaders/blockui.min.js') }}"></script>
    <!-- /core JS files -->

    <script src="{{ asset('js/ui/sticky.min.js') }}"></script>
    <script src="{{ asset('js/demo/navbar_multiple_sticky.js') }}"></script>

    <!-- /theme JS files -->

    @stack('scripts')

    <script>
            $(document).ready(function () {
                // loader 2
                $(function () {
                    setTimeout(function() {
                        $(".preloader").fadeOut();
                    }, 50);
                });
            });

    </script>

</body>

</html>
