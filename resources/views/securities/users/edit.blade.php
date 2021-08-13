@extends('layouts.full')

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Edit Data Pengguna')

@section('link1', 'Master')
@section('link2', 'Pengguna')
@section('link3', 'Edit')


@section('content')

@if (\Session::has('failed'))
<div class="alert bg-danger text-white alert-styled-left alert-dismissible">
    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
    <span class="font-weight-semibold">{{ \Session::get('failed') }}
    </div>
@endif

<!-- Form validation -->
<div class="card">
        <div class="card-header header-elements-inline">
            <h5 class="card-title">Form Edit Pengguna</h5>
            <div class="header-elements">
                <a href="{{ route('securities.users.index') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
            </div>
        </div>

        <div class="card-body">
            <form class="form-validate-jquery" action="{{ route('securities.users.update',$user) }}" method="POST">
                        {{ csrf_field() }} {{ method_field('PUT') }}
                <fieldset class="mb-3">
                    <legend class="text-uppercase font-size-sm font-weight-bold">Data Umum</legend>

                    <!-- Nama -->
                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Nama Lengkap<span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="hidden" id="id" name="id" class="form-control" required value="{{ $user->id }}">
                            <input type="text" id="name" name="name" class="form-control" required placeholder="nama lengkap" value="{{ $user->name }}">
                        </div>
                    </div>
                    <!-- Nama -->

                    <!-- Email field -->
                    {{-- <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Email <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="email" id="email" name="email" class="form-control" id="email" required placeholder="email" value="{{ $user->email }}">
                        </div>
                    </div> --}}
                    <!-- /email field -->

                    <!-- Select2 select -->
                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Nama Bank </label>
                        <div class="col-lg-3">
                                <select id="bank_id_user" name="bank_id_user" data-placeholder="Pilih Bank..." class="form-control form-control-select2 select-search" required data-fouc>
                                        <option></option>
                                        @foreach($banks as $item)
                                            <option value="{{ $item->id}}" {{ $user->bank_id == $item->id ? 'selected="true"' : '' }}>{{ $item->name}}</option>
                                        @endforeach
                                    </select>
                        </div>
                        <div class="col-lg-3">

                                <select id="branch_id_user" name="branch_id_user" data-placeholder="Pilih Cabang..." class="form-control form-control-select2 select-search" required data-fouc>
                                        <option></option>
                                        @foreach($branches as $item)
                                            <option value="{{ $item->id }}" {{ $user->branch_id == $item->id ? 'selected="true"' : '' }}>{{ $item->name}}</option>
                                        @endforeach
                                    </select>
                            </div>
                    </div>
                    <!-- /select2 select -->

                     <!-- Select2 select -->
                     <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Nama Asuransi </label>
                        <div class="col-lg-3">
                                <select id="insurance_id_user" name="insurance_id_user" data-placeholder="Pilih Asuransi..." class="form-control form-control-select2 select-search" required data-fouc>
                                        <option></option>
                                        @foreach($insurance as $item)
                                            <option value="{{ $item->id}}" {{ $user->insurance_id == $item->id ? 'selected="true"' : '' }}>{{ $item->name}}</option>
                                        @endforeach
                                    </select>
                        </div>
                        
                    </div>
                    <!-- /select2 select -->

                </fieldset>

                <fieldset class="mb-3">
                    <legend class="text-uppercase font-size-sm font-weight-bold">Data Keamanan</legend>

                    <div class="form-group row">
                            {{-- <label class="col-form-label col-lg-3" style="text-align: right">Username <span class="text-danger">*</span></label>
                            <div class="col-lg-6">
                                <input type="text" id="username" name="username" class="form-control" required readonly placeholder="username" value="{{ $user->name }}">
                            </div> --}}
                            <label class="col-form-label col-lg-3" style="text-align: right">Email <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input readonly type="email" id="email" name="email" class="form-control" id="email" required placeholder="email" value="{{ $user->email }}">
                        </div>
                        </div>

                    <!-- Password field -->
                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Password <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="password" name="password" id="password" class="form-control" placeholder="Password minimum 5 karakter">
                        </div>
                    </div>
                    <!-- /password field -->


                    <!-- Repeat password -->
                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Ulangi password <span class="text-danger">*</span></label>
                        <div class="col-lg-6">
                            <input type="password" name="repeat_password" class="form-control" placeholder="Input ulang password">
                        </div>
                    </div>
                    <!-- /repeat password -->

                </fieldset>

                <fieldset class="mb-3">
                    <legend class="text-uppercase font-size-sm font-weight-bold">Data Role</legend>

                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right">Role </label>
                        <div class="col-lg-6">
                                @foreach ($roles as $item)
                                <div class="custom-control custom-checkbox">
                                        {{-- <input type="checkbox" class="custom-control-input" checked value="{{ $item->id }}"> --}}
                                        {{-- <input type="checkbox" class="custom-control-input" id="permission[]" name="permission[]"  value="{{ $item->id}}" @if($data->permissions->contains($item)) checked @endif> --}}
                                        {{-- <label class="custom-control-label">{{ $item->name }}</label> --}}

                                        {{-- <input type="checkbox" class="custom-control-input" name="permissions[]" value="{{ $item->id }}" @if($data->permissions->contains($item)) checked @endif> --}}
                                        {{-- <label class="custom-control-label" for="permissions[]">{{ $item->name }}</label> --}}
                                        <label class="form-check-label">
                                                <input type="checkbox" class="form-check-input" name="roles[]" value="{{ $item->id }}" @if($user->roles->contains($item)) checked @endif>
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



                {{--
                <fieldset class="mb-3"> --}}
                    <div class="form-group row">
                        <label class="col-form-label col-lg-3" style="text-align: right;"></label>
                        <div style="padding-left:10px;">
                            <button type="submit" class="btn btn-primary"><i class="icon-checkmark mr-2"></i> Simpan</button>
                            <button type="reset" class="btn btn-light ml-3" id="reset"><i class="icon-reload-alt mr-2"></i> Reset</button>
                        </div>
                    </div>

                    {{-- </fieldset> --}}
            </form>
        </div>
    </div>
    <!-- /form validation -->

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
        $('#bank_id_user').on('change', function() {
                var bankID = $(this).val();
                $('#hasil1').val(bankID);
                if(bankID) {
                    getBranches(bankID);
                }else{
                    $('#bank_id_user').empty();
                }
        });
    });

    function getBranches(bankID) {
        if(bankID) {
                $.ajax({
                    url: '/ajax/getbranchesbybank/'+bankID,
                    type: "GET",
                    dataType: "json",
                    success:function(data) {
                        $('select[name="branch_id_user"]').empty();
                        $('select[name="branch_id_user"]').append('<option value="" selected>Pilih Cabang</option>');
                        $.each(data, function(key, value) {
                            $('select[name="branch_id_user"]').append('<option value="'+ value['id'] +'">'+ value['name'] +'</option>');
                        });
                    }
                });
        } else {
            $('select[name="branch_id_user"]').empty();
        }
    }

</script>




@endpush
