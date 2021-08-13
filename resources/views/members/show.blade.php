@extends('layouts.full')
@section('content')

@section('title', 'Peserta')
@section('subtitle', 'Detail Info Peserta')

@section('link1', 'Client')
@section('link2', 'Informasi')
@section('link3', 'Peserta')

<!-- Table components -->
{{-- {{ $user }} --}}
<div class="card">
    <div class="card-header header-elements-inline">
        <h5 class="card-title">Detail Info Peserta</h5>
        <div class="header-elements">
            {{-- <button type="button" class="btn bg-blue">Tambah Pengguna</button> --}}
            <a href="{{ route('members.index') }}" class="btn btn-secondary btn-labeled btn-labeled-left"><b><i class="icon-circle-left2 "></i></b> Kembali</a>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-lg">
            <tbody>
                <tr class="table-active">
                    <th colspan="6">Data Utama</th>
                </tr>
                <tr>
                    <td class="wmin-md-100 table-active">Id Member</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->loan_id }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">No. Polis</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">@if ($member->polis_number == '') N/A @else {{ $member->polis_number }} @endif</span>
                    </td>
                    <td class="wmin-md-100 table-active">Premi</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ number_format($member->total_premi, 2,',','.') }}</span>
                    </td>
                </tr>
                <tr>

                    <td class="wmin-md-100 table-active">Status</td>
                    <td class="wmin-md-300" colspan="3">
                        <span class="font-weight-bold">
                                        @if ($member->data_status_id == 1) Unverified
                                        @elseif ($member->data_status_id == 2) Open
                                        @elseif ($member->data_status_id ==3) Closed
                                        @elseif ($member->data_status_id == 4) On Claiming
                                        @elseif ($member->data_status_id == 5) Claimed
                                        @elseif ($member->data_status_id == 6) Gagal Validasi
                                        @elseif ($member->data_status_id == 7) On Proposing Repayment
                                        @endif
                                </span>
                    </td>
                    <td class="wmin-md-100 table-active">Kurs</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->currency }}</span>

                    </td>

                </tr>
                <tr class="table-active">
                    <th colspan="6">Data Loan</th>
                </tr>
                <tr>
                    <td class="wmin-md-100 table-active">Plafond</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ number_format($member->plafond, 2,',','.')  }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">Pertanggungan</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ number_format($member->pertanggungan, 2,',','.') }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">Rate</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ number_format($member->insurance_rate, 2,',','.')}} % / mil</span>
                    </td>
                </tr>
                <tr>
                    <td class="wmin-md-100 table-active">Tgl. Mulai</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->start_date }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">Tgl. Selesai</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->end_date }}</span>
                    </td>
                    {{--
                    <td class="wmin-md-100">Kurs</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $loan->currency }}</span>
                        <span class="font-weight-bold">{{ $loan->tenor }}</span>
                    </td> --}}
                    <td class="wmin-md-100 table-active">Jangka Waktu</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->tenor }}</span>
                    </td>

                </tr>
                <tr class="table-active">
                    <th colspan="6">Data Nasabah</th>
                </tr>
                <tr>
                    <td class="wmin-md-100 table-active">CIF</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->cif }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">Nama</td>
                    <td class="wmin-md-300" colspan="3">
                        <span class="font-weight-bold">{{ $member->customer_name }}</span>
                    </td>


                </tr>
                <tr>
                    <td class="wmin-md-100 table-active">No. Rekening</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->customer_deposit_amount }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">Tgl. Lahir</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->birth_date }}</span>
                    </td>
                    <td class="wmin-md-100 table-active">Tempat Lahir</td>
                    <td class="wmin-md-300">
                        <span class="font-weight-bold">{{ $member->born_place }}</span>
                    </td>

                </tr>
                <tr>
                    <td class="wmin-md-100 table-active">Pekerjaan</td>
                    <td class="wmin-md-300" colspan="5">
                        <span class="font-weight-bold">{{ $member->job }}</span>
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










































@endpush
