<!-- Page header -->
<div class="page-header">
    <div class="page-header-content header-elements-md-inline">
        <div class="page-title d-flex">
            <h4><i class="icon-arrow-left52 mr-2"></i> <span class="font-weight-semibold">@yield('title')</span> - @yield('subtitle')</h4>
            <a href="#" class="header-elements-toggle text-default d-md-none"><i class="icon-more"></i></a>
        </div>

        <div class="header-elements d-none py-0 mb-3 mb-md-0">
            <div class="breadcrumb">
                <a href="{{ route('dashboard') }}" class="breadcrumb-item"><i class="icon-home2 mr-2"></i> Home</a>
                <span class="breadcrumb-item active">@yield('link1')</span>
                <span class="breadcrumb-item active">@yield('link2')</span>
                <span class="breadcrumb-item active">@yield('link3')</span>
            </div>
        </div>
    </div>
</div>
<!-- /page header -->
