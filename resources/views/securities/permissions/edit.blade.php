@extends('layouts.full')

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Edit Data Permission')

@section('link1', 'Master')
@section('link2', 'Permission')
@section('link3', 'Edit')

@section('content')

@if (\Session::has('failed'))
<div class="alert bg-danger text-white alert-styled-left alert-dismissible">
    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
    <span class="font-weight-semibold">{{ \Session::get('failed') }}
    </div>
@endif

@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<div class="card">
    <div class="card-header bg-light header-elements-inline">
        <h5 class="card-title">Form Edit Data Permission</h5>
        <div class="header-elements">
            <a href="{{ route('securities.permissions.index') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
        </div>
    </div>



    <div class="card-body">
        <form class="form-validate-jquery" action="{{ route('securities.permissions.update',$data) }}" method="POST">
            {{ csrf_field() }} {{ method_field('PUT') }}

            {{-- <legend class="text-uppercase font-size-sm font-weight-bold"></legend> --}}

            <!-- Nama -->
            <div class="form-group row">
                <label class="col-form-label col-lg-3" style="text-align: right">Kode <span class="text-danger">*</span></label>
                <div class="col-lg-6">
                    <input type="text" id="id" name="id" class="form-control" required placeholder="Isi kode" value="{{ $data->id }}" readonly>
                </div>
            </div>
            <!-- Nama -->

            <!-- Email field -->
            <div class="form-group row">
                    <label class="col-form-label col-lg-3" style="text-align: right">Nama Permission <span class="text-danger">*</span></label>
                    <div class="col-lg-6">
                        <input readonly type="text" id="name" name="name" class="form-control" required placeholder="Isi nama permission" maxlength="150" value="{{ $data->name }}">
                    </div>
                </div>
                <!-- /email field -->

                <!-- Email field -->
                <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Nama Pendek <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="text" id="display_name" name="display_name" class="form-control" required placeholder="Isi nama pendek" maxlength="150" value="{{ $data->display_name }}">
                        </div>
                    </div>
                    <!-- /email field -->

                <!-- Email field -->
                <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Deskripsi </label>
                        <div class="col-lg-6">
                            <input type="text" id="description" name="description" class="form-control" placeholder="Isi deskripsi" maxlength="150" value="{{ $data->description }}">
                        </div>
                    </div>
                    <!-- /email field -->
                    <div class="form-group row">
                            <label class="col-form-label col-lg-3" style="text-align: right;"></label>
                            <div style="padding-left:10px;">
                                <button type="submit" class="btn btn-primary"><i class="icon-checkmark mr-2"></i> Simpan</button>
                                <a href="{{ route('securities.permissions.index') }}" class="btn btn-light ml-3" id="reset"><i class="icon-reload-alt mr-2"></i> Batal</a>
                            </div>
                        </div>
        </form>
    </div>
</div>

@endsection

@push('scripts')

<script type="text/javascript" src="{{ asset('js/forms/validation/validate.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/inputs/touchspin.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/extensions/jquery_ui/interactions.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/selects/select2.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/styling/switch.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/styling/switchery.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/styling/uniform.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/demo/form_validation.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/demo/form_select2.js') }}"></script>

<script>
    $(document).ready(function() {

    });

</script>

@endpush
