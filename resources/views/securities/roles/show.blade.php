@extends('layouts.full')

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Detail Data Role')

@section('link1', 'Master')
@section('link2', 'Role')
@section('link3', 'Info')

@section('content')

{{-- {{ $data->permissions }} --}}
<div class="card">
    <div class="card-header bg-light header-elements-inline">
        <h5 class="card-title">Detail Data Role</h5>
        <div class="header-elements">
            <a href="{{ route('securities.roles.index') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-lg">
            <tbody>
                <tr>
                    <td class="wmin-md-100">Kode Role</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $data->id }}</span>
                    </td>
                </tr>
                <tr>
                    <td class="wmin-md-100">Nama Role</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $data->name }}</span>
                    </td>
                </tr>
                <tr>
                        <td class="wmin-md-100">Nama Pendek</td>
                        <td class="wmin-md-350" colspan="2">
                            <span class="font-weight-bold">{{ $data->display_name }}</span>
                        </td>
                    </tr>
                    <tr>
                            <td class="wmin-md-100">Deskripsi</td>
                            <td class="wmin-md-350" colspan="2">
                                <span class="font-weight-bold">{{ $data->description }}</span>
                            </td>
                        </tr>
                <tr>
                    <td class="wmin-md-100">Created At</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $data->created_at }}</span>
                    </td>
                </tr>
                <tr>
                        <td class="wmin-md-100">Updated At</td>
                        <td class="wmin-md-350" colspan="2">
                            <span class="font-weight-bold">{{ $data->updated_at }}</span>
                        </td>
                    </tr>
                    <tr>
                            <td class="wmin-md-100">Data Permission</td>
                            <td class="wmin-md-350" colspan="2">
                                Role ini mempunyai beberapa permission :
                                <ul>
                                @foreach ($data->permissions as $item)
                                    <li><span class="font-weight-bold">{{ $item->name }}</span>  <i>(<span class="font-weight-italic">{{ $item->display_name }}</span>)</i></li>
                                @endforeach
                                </ul>
                            </td>
                        </tr>
            </tbody>
        </table>
    </div>
</div>

@endsection

@push('scripts')

<script type="text/javascript" src="{{ asset('js/tables/footable/footable.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/demo/table_responsive.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/notifications/sweet_alert.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/demo/extra_sweetalert.js') }}"></script>

<script>
    $(function() {

    });

</script>

@endpush
