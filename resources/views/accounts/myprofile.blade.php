@extends('layouts.full')

@push('styles')

{!! Charts::styles() !!}

<style>
    .input-textarea-aktif {
        background-color: #FBF9E4;
    }
</style>

@endpush

@section('title', 'Profil')
@section('subtitle', 'data profil pengguna')

@section('link1', 'Home')
@section('link2', 'My Profile')

@section('content')

<div class="card">
    <div class="card-header bg-light header-elements-inline">
            <h5 class="card-title">Informasi Profil</h5>
            <div class="header-elements">
            </div>
        </div>
        <div class="card-body">

            <form class="form-validate-jquery" action="{{ route('accounts.update_profile',$user) }}" method="POST">
                {{ csrf_field() }} {{ method_field('PUT') }}
                <div class="form-group">
                    <div class="row">
                        <div class="col-md-6">
                            <label>Email</label>
                            <input type="hidden" id="id" name="id" class="form-control" required value="{{ $user->id }}">
                            <input readonly="readonly" id="email" name="email" type="text" class="form-control" value="{{ $user->email }}">
                        </div>
                        <div class="col-md-6">
                            <label>Nama Lengkap</label>
                            <input type="text" id="name" name="name" value="{{ $user->name }}" class="form-control">
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="row">
                        <div class="col-md-4">
                            <label>Nama Bank</label>
                            <select id="bank_id" name="bank_id" data-placeholder="Pilih Bank..." class="form-control form-control-select2 select-search" required data-fouc>
                                <option></option>
                                @foreach($banks as $item)
                                    <option value="{{ $item->id}}" {{ $user->bank_id == $item->id ? 'selected="true"' : '' }}>{{ $item->name}}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label>Nama Cabang</label>
                            <select id="branch_id" name="branch_id" data-placeholder="Pilih Cabang..." class="form-control form-control-select2 select-search" required data-fouc>
                                <option></option>
                                @foreach($branches as $item)
                                    <option value="{{ $item->id}}" {{ $user->branch_id == $item->id ? 'selected="true"' : '' }}>{{ $item->name}}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label>PIC Bank</label>
                            <select id="pic_bank_id" name="pic_bank_id" data-placeholder="Pilih Bank..." class="form-control form-control-select2 select-search" required data-fouc>
                                <option></option>
                                @foreach($banks as $item)
                                    <option value="{{ $item->id}}" {{ $user->pic_bank_id == $item->id ? 'selected="true"' : '' }}>{{ $item->name}}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                </div>

                <div class="text-right">
                    <button type="submit" class="btn btn-primary"><i class="icon-checkmark mr-2"></i> Simpan</button>
                </div>
            </form>

        </div>
</div>

<div class="card">
    <div class="card-header bg-light header-elements-inline">
            <h5 class="card-title">Pengaturan Keamanan</h5>
            <div class="header-elements">
            </div>
        </div>
        <div class="card-body">

            <form class="form-validate-jquery" action="{{ route('accounts.update_password',$user) }}" method="POST">
                {{ csrf_field() }} {{ method_field('PATCH') }}
                <div class="form-group">
                    <div class="row">
                        <div class="col-md-6">
                            <label>Email</label>
                            <input type="hidden" id="id" name="id" class="form-control" required value="{{ $user->id }}">
                            <input type="text" id="email" name="email" value="{{ $user->email }}" readonly="readonly" class="form-control">
                        </div>

                        <div class="col-md-6">
                            <label>Password saat ini</label>
                            <input type="password" id="old_password" name="old_password" value="{{ $user->password }}" readonly="readonly" class="form-control">
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div class="row">
                        <div class="col-md-6">
                            <label>Password Baru</label>
                            <input type="password" id="new_password" name="new_password" placeholder="Enter new password" class="form-control">
                        </div>

                        <div class="col-md-6">
                            <label>Konfirmasi Password</label>
                            <input type="password" id="conf_password" name="conf_password" placeholder="Repeat new password" class="form-control">
                        </div>
                    </div>
                </div>

                <div class="text-right">
                    <button type="submit" class="btn btn-primary"><i class="icon-checkmark mr-2"></i> Simpan</button>
                </div>
            </form>

        </div>
</div>


@endsection

@push('scripts')

<script type="text/javascript" src="{{ asset('js/extensions/jquery_ui/widgets.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/extensions/jquery_ui/interactions.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/media/fancybox.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/selects/select2.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/uploaders/fileinput/fileinput.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/demo/uploader_bootstrap.js') }}"></script>

<script>

$(function() {

    $('.datepicker-format').datepicker({
        dateFormat:'yy-mm-dd',
        isRTL: $('html').attr('dir') == 'rtl' ? true : false,
    });

    $('.select-search').select2();

});

</script>

@endpush
