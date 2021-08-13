<!-- Alternative navbar -->
<div class="navbar navbar-expand-md navbar-dark bg-blue-400 navbar-sticky">
    <div class="text-center d-md-none w-100">
        <button type="button" class="navbar-toggler dropdown-toggle" data-toggle="collapse" data-target="#navbar-second"><i class="icon-unfold mr-2"></i>Alternative navbar</button>
    </div>

    <div class="navbar-collapse collapse" id="navbar-second">

        <ul class="navbar-nav">
            @permission('can_view_root_menu_dashboard')
            <li class="nav-item">
                <a href="{{ route('dashboard') }}" class="navbar-nav-link"><i class="icon-home2 mr-2"></i>Dashboard</a>
            </li>
            @endpermission            

            @permission('can_view_root_menu_peserta')
            <li class="nav-item dropdown">
                <a href="#" class="navbar-nav-link dropdown-toggle" data-toggle="dropdown" data-hover="dropdown"><i class="icon-users4  mr-2"></i>Peserta</a>

                <div class="dropdown-menu">
                    @permission('can_view_sub_menu_list_peserta_bnk')
                    <a href="{{ route('members.index') }}" class="dropdown-item"><i class="icon-list-unordered"></i> Daftar Peserta</a>
                    @endpermission
                </div>
            </li>
            @endpermission

            @permission('can_view_root_menu_master_access')
            <li class="nav-item dropdown">
                <a href="#" class="navbar-nav-link dropdown-toggle" data-toggle="dropdown" data-hover="dropdown"><i class="icon-cog2 mr-2"></i> Akses</a>

                <div class="dropdown-menu">
                    @permission('can_view_sub_menu_pemeliharaan_user')
                    <a href="{{ route('securities.users.index') }}" class="dropdown-item"><i class="icon-users "></i>Pengguna</a>
                    @endpermission

                    @permission('can_view_sub_menu_pemeliharaan_role')
                    <a href="{{ route('securities.roles.index') }}" class="dropdown-item"><i class="icon-user-lock "></i> Role</a>
                    @endpermission

                    @permission('can_view_sub_menu_pemeliharaan_permission')
                    <a href="{{ route('securities.permissions.index') }}" class="dropdown-item"><i class="icon-key"></i> Permission</a>
                    @endpermission
                </div>
            </li>
            @endpermission      
        </ul>

        <div class="navbar-nav ml-md-auto"><span id="todayDate" name="todayDate"></span></div>
    </div>
</div>
    <!-- /alternative navbar -->

<script src="{{ asset('js/main/jquery.min.js') }}"></script>
<script>

    $(document).ready(function() {
        setInterval(function() {
            var dt = new Date();
            var datetext = dt.toTimeString();

            $("#todayDate").text(get_tanggal(dt) + ' ' + datetext.split(' ')[0]);
        }, 1000);
    });

    function get_tanggal(dt){
        var hari = ["Minggu","Senin","Selasa","Rabu","Kamis","Jumat","Sabtu"];
        var bulan = ["Januari","Pebruari","Maret","April","Mei","Juni","Juli","Agustus","September","Oktober","Nopember","Desember"];

        var tanggal =dt.getDate();
        var _hari = dt.getDay();
        var _bulan = dt.getMonth();
        var _tahun =dt.getFullYear();

        var hari = hari[_hari];
        var bulan = bulan[_bulan];
        var tahun = (_tahun < 1000) ? _tahun + 1900 : _tahun;

        return hari + ', ' + tanggal + ' '  + bulan + ' ' + tahun;
    }

</script>
