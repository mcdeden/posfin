<!DOCTYPE html>
<html lang="en">
<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <title>AJBCS - Client Settlement Monitoring</title>

        <!-- Global stylesheets -->
        <link href="https://fonts.googleapis.com/css?family=Roboto:400,300,100,500,700,900" rel="stylesheet" type="text/css">
        {{--  <link href="../../../../global_assets/css/icons/icomoon/styles.css" rel="stylesheet" type="text/css">  --}}
        <link href="{{ asset('css/styles.css') }}" rel="stylesheet" type="text/css">

        <link href="{{ asset('css/bootstrap.min.css') }}" rel="stylesheet" type="text/css">
        <link href="{{ asset('css/bootstrap_limitless.min.css') }}" rel="stylesheet" type="text/css">
        <link href="{{ asset('css/layout.min.css') }}" rel="stylesheet" type="text/css">
        <link href="{{ asset('css/components.min.css') }}" rel="stylesheet" type="text/css">
        <link href="{{ asset('css/colors.min.css') }}" rel="stylesheet" type="text/css">
        <!-- /global stylesheets -->

        <!-- Core JS files -->
        <script src="{{ asset('js/jquery.min.js') }}"></script>
        <script src="{{ asset('js/bootstrap.bundle.min.js') }}"></script>
        <script src="{{ asset('js/blockui.min.js') }}"></script>

        {{--  <script src="{{ asset('js/validate.min.js') }}"></script>  --}}
        {{--  <script src="{{ asset('js/uniform.min.js') }}"></script>  --}}
        <!-- /core JS files -->

        {{--  <script src="assets/js/app.js"></script>  --}}
        {{--  <script src="../../../../global_assets/js/demo_pages/login_validation.js"></script>  --}}
        <!-- /theme JS files -->

</head>

<body>

	<!-- Page content -->
	<div class="page-content">

		<!-- Main content -->
		<div class="content-wrapper">

			<!-- Content area -->
			<div class="content d-flex justify-content-center align-items-center">

				<!-- Password recovery form -->
				<form class="login-form" action="index.html">
					<div class="card mb-0">
						<div class="card-body">
							<div class="text-center mb-3">
								<i class="icon-spinner11 icon-2x text-warning border-warning border-3 rounded-round p-3 mb-3 mt-1"></i>
								<h5 class="mb-0">Password recovery</h5>
								<span class="d-block text-muted">Kami akan mengirim instruksi dengan email</span>
							</div>

							<div class="form-group form-group-feedback form-group-feedback-right">
								<input type="email" class="form-control" placeholder="Your email">
								<div class="form-control-feedback">
									<i class="icon-mail5 text-muted"></i>
								</div>
							</div>

							<button type="submit" class="btn bg-blue btn-block"><i class="icon-spinner11 mr-2"></i> Reset password</button>
						</div>
					</div>
				</form>
				<!-- /password recovery form -->

			</div>
			<!-- /content area -->




		</div>
		<!-- /main content -->

	</div>
	<!-- /page content -->

</body>
</html>
