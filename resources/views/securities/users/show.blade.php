@extends('layouts.full')

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Info Data Pengguna')

@section('link1', 'Master')
@section('link2', 'Pengguna')
@section('link3', 'Info')

@section('content')

<div class="card">
    <div class="card-header header-elements-inline">
        <h5 class="card-title">Detail Pengguna</h5>
        <div class="header-elements">
            <a href="{{ route('securities.users.index') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-lg">
            <tbody>
                <tr class="table-active">
                    <th colspan="3">Data Umum</th>
                </tr>
                <tr>
                    <td class="wmin-md-100">Nama</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $user->name }}</span>
                    </td>
                </tr>
                <tr>
                    <td class="wmin-md-100">Email</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $user->email }}</span>
                    </td>
                </tr>
                <tr>
                    <td class="wmin-md-100">Bank</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $user->bank['name'] }}</span>
                    </td>
                </tr>
                <tr>
                    <td class="wmin-md-100">Cabang</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $user->branch['name'] }}</span>
                    </td>
                </tr>

                <tr>
                    <td class="wmin-md-100">Asuransi</td>
                    <td class="wmin-md-350" colspan="2">
                        <span class="font-weight-bold">{{ $user->insurance['name'] }}</span>
                    </td>
                </tr>

                <tr>
                    <td class="wmin-md-100">Data Role</td>
                    <td class="wmin-md-350" colspan="2">
                        User ini mempunyai role :
                        <ul>
                        @foreach ($user->roles as $item)
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