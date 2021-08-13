@extends('layouts.full')

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Pendaftaran Role')

@section('link1', 'Master')
@section('link2', 'Role')
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
        <h5 class="card-title">Form Tambah Data Role</h5>
        <div class="header-elements">
            <a href="{{ route('securities.roles.index') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
        </div>
    </div>

    <div class="card-body">
        <form class="form-validate-jquery" action="{{ route('securities.roles.store') }}" method="POST">
            @csrf
            <fieldset class="mb-3">

                <!-- Email field -->
                <div class="form-group row">
                    <label class="col-form-label col-lg-3" style="text-align: right">Nama Role <span class="text-danger">*</span></label>
                    <div class="col-lg-6">
                        <input type="text" id="name" name="name" class="form-control" required placeholder="Isi nama role" maxlength="150">
                    </div>
                </div>
                <!-- /email field -->

                <!-- Email field -->
                <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Nama Pendek <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="text" id="display_name" name="display_name" class="form-control" required placeholder="Isi nama role" maxlength="150">
                        </div>
                    </div>
                    <!-- /email field -->

                <!-- Email field -->
                <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Deskripsi </label>
                        <div class="col-lg-6">
                            <input type="text" id="description" name="description" class="form-control" placeholder="Isi nama role" maxlength="150">
                        </div>
                    </div>
                    <!-- /email field -->
                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Hak Akses </label>
                        <div class="col-lg-6">
                                @foreach ($permissions as $item)
                                <div class="custom-control custom-checkbox">
                                        {{-- <input type="checkbox" class="custom-control-input" checked value="{{ $item->id }}"> --}}
                                        {{-- <input type="checkbox" class="custom-control-input" id="permission[]" name="permission[]"  value="{{ $item->id}}" @if($data->permissions->contains($item)) checked @endif> --}}
                                        {{-- <label class="custom-control-label">{{ $item->name }}</label> --}}

                                        {{-- <input type="checkbox" class="custom-control-input" name="permissions[]" value="{{ $item->id }}" @if($data->permissions->contains($item)) checked @endif> --}}
                                        {{-- <label class="custom-control-label" for="permissions[]">{{ $item->name }}</label> --}}
                                        <label class="form-check-label">
                                                <input type="checkbox" class="form-check-input" name="permissions[]" value="{{ $item->id }}">
                                                {{ $item->name }}
                                        </label>
                                    </div>
                                    @endforeach

                                    {{-- <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="custom_checkbox_stacked_checked">
                                        <label class="custom-control-label" for="custom_checkbox_stacked_checked">Custom unchecked</label>
                                    </div>

                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="custom_checkbox_stacked_checked_disabled" checked disabled>
                                        <label class="custom-control-label" for="custom_checkbox_stacked_checked_disabled">Custom checked disabled</label>
                                    </div> --}}
                            {{-- @foreach ($data->permissions as $item)
                            <input type="checkbox" class="custom-control-input" id="custom_checkbox_stacked_unchecked" checked>
                            <label class="custom-control-label" for="custom_checkbox_stacked_unchecked">Custom checked</label> --}}
                                {{-- <li><span class="font-weight-bold">{{ $item->name }}</span>  <i>(<span class="font-weight-italic">{{ $item->display_name }}</span>)</i></li> --}}
                            {{-- @endforeach --}}
                        </div>
                    </div>

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
