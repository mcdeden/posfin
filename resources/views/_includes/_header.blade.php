<!-- Main navbar -->
<div class="navbar navbar-expand-md navbar-dark">
    <div class="navbar-brand">
            <a href="{{ route('dashboard') }}" class="d-inline-block">
                    {{-- <img src="{{ asset('images/logo_light.png') }}" alt="AJB Settlement"> --}}
                    <img src="{{ asset('images/logo_ajb.png') }}" alt="AJB Settlement" style="width: 200px;height: 20px;">
                    {{-- <label style="color: white">Inagos</label> --}}
                </a>
    </div>

    <div class="d-md-none">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbar-mobile">
				<i class="icon-tree5"></i>
			</button>
        <button class="navbar-toggler sidebar-mobile-main-toggle" type="button">
				<i class="icon-paragraph-justify3"></i>
			</button>
    </div>

    <div class="collapse navbar-collapse" id="navbar-mobile">
        {{-- <ul class="navbar-nav">
            <li class="nav-item">
                <a href="#" class="navbar-nav-link sidebar-control sidebar-main-toggle d-none d-md-block">
						<i class="icon-paragraph-justify3"></i>
					</a>
            </li>
        </ul> --}}

        <ul class="navbar-nav ml-auto">
            {{-- <li class="nav-item">
                <a href="#" class="navbar-nav-link">
						Text link
					</a>
            </li> --}}

            {{-- <li class="nav-item dropdown">
                <a href="#" class="navbar-nav-link">
						<i class="icon-bell2"></i>
						<span class="d-md-none ml-2">Notifications</span>
						<span class="badge badge-mark border-white ml-auto ml-md-0"></span>
					</a>
            </li> --}}

            <li class="nav-item dropdown dropdown-user">
                {{-- <a href="#" class="navbar-nav-link dropdown-toggle" data-toggle="dropdown">
						<img src="../../../../global_assets/images/image.png" class="rounded-circle" alt="">
						<span>Victoria</span>
                    </a> --}}
                    <a href="#" class="navbar-nav-link dropdown-toggle" data-toggle="dropdown">
                            <img src="{{ asset('images/user.png') }}" class="rounded-circle" alt="">
                            <span>{{ Auth::user()->name }}</span>
                        </a>

                <div class="dropdown-menu dropdown-menu-right">
                    <a href="{{ route('accounts.profile') }}" class="dropdown-item"><i class="icon-user-plus"></i> Profil Ku</a>
                    {{-- <a href="#" class="dropdown-item"><i class="icon-coins"></i> My balance</a> --}}
                    {{-- <a href="#" class="dropdown-item"><i class="icon-comment-discussion"></i> Messages <span class="badge badge-pill bg-blue ml-auto">58</span></a> --}}
                    {{-- <a href="#" class="dropdown-item"><i class="icon-cog5"></i> Ubah Password</a> --}}
                    {{-- <a href="#" class="dropdown-item"><i class="icon-switch2"></i> Logout</a> --}}
                    <div class="dropdown-divider"></div>
                    <div>
                            <a class="dropdown-item" href="{{ route('logout') }}" onclick="event.preventDefault();document.getElementById('logout-form').submit();">
                                            <i class="icon-switch2"></i>
                                        {{ __('Logout') }}
                                    </a>

                            <form id="logout-form" action="{{ route('logout') }}" method="POST" style="display: none;">
                                @csrf
                            </form>
                        </div>
                </div>
            </li>
        </ul>
    </div>
</div>
<!-- /main navbar -->


