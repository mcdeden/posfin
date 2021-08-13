@extends('layouts.full')

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Pendaftaran Permission')

@section('link1', 'Master')
@section('link2', 'Permission')
@section('link3', 'Create')

@section('content') @if (\Session::has('failed'))
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
        <h5 class="card-title">Form Tambah Data Permission</h5>
        <div class="header-elements">
            <a href="{{ route('securities.permissions.index') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
        </div>
    </div>

    <div class="card-body">
        <form class="form-validate-jquery" action="{{ route('securities.permissions.store') }}" method="POST">
            @csrf
            <fieldset class="mb-3">

                <!-- Email field -->
                <div class="form-group row">
                    <label class="col-form-label col-lg-3" style="text-align: right">Nama Permission <span class="text-danger">*</span></label>
                    <div class="col-lg-6">
                        <input type="text" id="name" name="name" class="form-control" required placeholder="Isi nama permission" maxlength="150">
                    </div>
                </div>
                <!-- /email field -->

                <!-- Email field -->
                <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Nama Pendek <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="text" id="display_name" name="display_name" class="form-control" required placeholder="Isi nama pendek" maxlength="150">
                        </div>
                    </div>
                    <!-- /email field -->

                <!-- Email field -->
                <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Deskripsi </label>
                        <div class="col-lg-6">
                            <input type="text" id="description" name="description" class="form-control" placeholder="Isi deskripsi" maxlength="150">
                        </div>
                    </div>
                    <!-- /email field -->

            </fieldset>

            <div class="form-group row">
                <label class="col-form-label col-lg-3" style="text-align: right;"></label>
                <div style="padding-left:10px;">
                    <button type="submit" class="btn btn-primary"><i class="icon-checkmark mr-2"></i> Simpan</button>
                    <button type="reset" class="btn btn-light ml-3" id="reset"><i class="icon-reload-alt mr-2"></i> Reset</button>
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
