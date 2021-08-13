@extends('layouts.full') @push('styles')

<style>

    .dataTables_wrapper .dataTables_length {
        float: left;
        margin-left: -0px;
    }

    .dataTables_filter {
        display: none;
    }

    .badge-unverified {
        background-color: orange;
    }

    .badge-onproposingrepayment {
        background-color: yellow;
    }

</style>

@section('title', 'Peserta')
@section('subtitle', 'Daftar Peserta')

@section('link1', 'Member')
@section('link2', 'All')

@endpush

@section('content') @if (\Session::has('success'))
<div class="alert bg-success text-white alert-styled-left alert-dismissible">
    <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
    <span class="font-weight-semibold">{{ \Session::get('success') }}
    </div>
@endif

<div class="card">
        <div class="card-header bg-light header-elements-inline">
            <h5 class="card-title">Form Filter</h5>
            <div class="header-elements">
            </div>
        </div>

        <div class="card-body">

                <table style="width: 100%;">
                    <tr>
                        <td style="padding: 5px;width:20%;">Nama Cabang</td>
                        <td style="padding: 5px;width:20%;">Asuransi</td>
                        <td style="padding: 5px;width:15%;">Nama Produk</td>
                        <td style="padding: 5px;width:20%;">Nama Nasabah</td>
                        <td style="padding: 5px;width:20%;">Status</td>
                        <td style="padding: 5px;width:5%;"></td>
                    </tr>
                    <tr>
                        <form method="post" id="search-form">
                            <td style="padding: 5px;">
                                    <select id="branch_id" name="branch_id" data-placeholder="Pilih cabang..." class="form-control form-control-select2 select-search"
                                    data-fouc>
                                    <option value="0" selected>All</option>
                                    @foreach($branches as $item)
                                        <option value="{{ $item->id }}">{{ $item->name}}</option>
                                    @endforeach
                                </select>
                                </td>
                                <td style="padding: 5px;">
                                        <select id="insurance_id" name="insurance_id" data-placeholder="Pilih asuransi..." class="form-control form-control-select2 select-search"
                                            data-fouc>
                                            <option></option>
                                            <option value="0" selected>All</option>
                                            @foreach($insurance as $item)
                                            <option value="{{ $item->id }}">{{ $item->name}}</option>
                                            @endforeach
                                        </select>
                                    </td>

                                <td style="padding: 5px;">
                                        <select id="product_id" name="product_id" data-placeholder="Pilih product..." class="form-control form-control-select2 select-search"
                                            data-fouc>
                                            <option></option>
                                            <option value="0" selected>All</option>
                                            @foreach($products as $item)
                                            <option value="{{ $item->id }}">{{ $item->name}}</option>
                                            @endforeach
                                        </select>
                                    </td>
                        <td style="padding: 5px;"><input type="text" class="form-control" placeholder="nama" name="name" id="name"></td>
                       
                        <td style="padding: 5px;">
                                <select id="data_status_id" name="data_status_id" data-placeholder="Pilih Status..." class="form-control form-control-select2 select-search"
                                    data-fouc>
                                    <option></option>
                                    <option value="0" selected>All</option>
                                    @foreach($datastatus as $item)
                                    <option value="{{ $item->id }}">{{ $item->name}}</option>
                                    @endforeach
                                </select>
                            </td>

                        <td style="padding: 5px;text-align: right">
                            <button style="width: 100%" type="submit" class="btn btn-warning"><i class="icon-search4  mr-2"></i> Cari</button>
                        </td>
                    </form>
                    </tr>
                </table>

        </div>
    </div>

<div class="card">

    <table class="table  datatable-button-html5-columns table-bordered table-striped table-hover dtloans">
        <thead>
            <tr>
                    <th style="width: 5%;" rowspan="2" class="text-center">No.</th>
                    <th style="width: 5%;" rowspan="2" class="text-center">Kode Peserta</th>
                    <th style="width: 15%;" rowspan="2" class="text-center">Unit Bisnis</th>
                    <th style="width: 15%;" rowspan="2" class="text-center">Nama Peserta</th>
                    <th style="width: 5%;" colspan="2" class="text-center">Tanggal</th>
                    <th style="width: 10%;" rowspan="2" class="text-center">Pertanggungan</th>
                    <th style="width: 10%;" rowspan="2" class="text-center">Premi</th>
                    <th style="width: 10%;" rowspan="2" class="text-center">Status</th>
                    <th style="width: 16%;" rowspan="2" class="text-center">Action</th>
            </tr>
            <tr>
                    <th style="width: 5%;" class="text-center">Mulas</th>
                    <th style="width: 5%;" class="text-center">Selesai</th>                
            </tr>
        </thead>
    </table>
</div>

@endsection

@push('scripts')

{{-- other --}}
<script type="text/javascript " src="{{ asset( 'js/tables/footable/footable.min.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/notifications/sweet_alert.min.js') }} "></script>
<script type="text/javascript" src="{{ asset('js/extensions/jquery_ui/interactions.min.js') }}"></script>
<script type="text/javascript" src="{{ asset('js/forms/selects/select2.min.js') }}"></script>

{{-- datatable --}}
<script type="text/javascript " src="{{ asset( 'js/tables/datatables/datatables.min.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/tables/datatables/extensions/jszip/jszip.min.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/tables/datatables/extensions/pdfmake/pdfmake.min.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/tables/datatables/extensions/pdfmake/vfs_fonts.min.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/tables/datatables/extensions/buttons.min.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/demo/datatables_extension_buttons_html5.js') }} "></script>

{{-- demo --}}
<script type="text/javascript " src="{{ asset( 'js/demo/table_responsive.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/demo/extra_sweetalert.js') }} "></script>
<script type="text/javascript " src="{{ asset( 'js/demo/form_select2.js') }}"></script>

<script>
    $(function() {

        var branchID=$('#branch_id').val();
        var insuranceID=$('#insurance_id').val();
        var productID=$('#product_id').val();
        var datastatusID=$('#data_status_id').val();
        var custname=$('#name').val();        

        var oTable = $('.dtloans').DataTable({
            processing: true,
            serverSide: true,
            ajax: {
                    url: '{!! route('members.ajax.get_all_data_members') !!}',
                    data: function (d) {
                        d.customer_name = $('input[name=name]').val();
                        d.insurance_id = $('select[name=insurance_id]').val();
                        d.product_id = $('select[name=product_id]').val();
                        d.branch_id = $('select[name=branch_id]').val();
                        d.data_status_id = $('select[name=data_status_id]').val();
                    }
            },
            headers: {
                'X-CSRF-Token': '{{ csrf_token() }}',
            },
            order: [[ 0, "desc" ]],
            buttons: [
                    { extend: 'print',className: 'btn btn-light',text: '<i class="icon-printer mr-2"></i>Print all'},                   
					{ extend: 'colvis',text: '<i class="icon-three-bars"></i>',className: 'btn bg-blue btn-icon dropdown-toggle'}
			],
            columns: [
                {data: 'DT_Row_Index',className: "text-center", orderable: false, searchable: false},
                { data: function (data, type, dataToSet) {
                    return data.id.substr(18,24);
                }, name: 'id',className: "text-center", orderable: false },
                { data: 'branch.name', name: 'branch',className: "text-left", orderable: false },
                { data: 'customer_name', name: 'name',className: "text-left", orderable: false },
                { data: 'start_date', name: 'start_date',className: "text-left", orderable: false },
                { data: 'end_date', name: 'end_date',className: "text-left", orderable: false },
                { data: 'pertanggungan', name: 'pertanggungan',render: $.fn.dataTable.render.number( '.', ',', 2, '' ),className: "text-right", orderable: false },
                { data: 'total_premi', name: 'total_premi',render: $.fn.dataTable.render.number( '.', ',', 2, '' ),className: "text-right", orderable: false },
                { data: 'data_status_id', name: 'data_status_id', render:function(data,type,row) {
                    if (data==1) {
                        return '<span class="badge badge-unverified">Unverified</span>'
                    } else if (data==2) {
                        return '<span class="badge badge-success">Open</span>'
                    } else if (data==3) {
                        return '<span class="badge badge-secondary">Closed</span>'
                    } else if (data==4) {
                        return '<span class="badge badge-warning">On Claiming</span>'
                    } else if (data==5) {
                        return '<span class="badge badge-danger">Claimed</span>'
                    } else if (data==6) {
                        return '<span class="badge badge-danger">Validation Failed</span>'
                    } else {
                        return '<span class="badge badge-onproposingrepayment">On Proposing Refund</span>'
                    }
                },className: "text-center", orderable: false},
                { data: 'action', name:'action',orderable:false, searchable: false,className: "text-center"},
            ],
        });

        $('#search-form').on('submit', function(e) {
            oTable.draw();
            e.preventDefault();
        });
    });

    </script>
















@endpush
