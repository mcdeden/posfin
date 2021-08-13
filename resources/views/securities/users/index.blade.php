@extends('layouts.full')

@push('styles')

<style>
    .dataTables_wrapper .myfilter .dataTables_filter {
        float:left
    }
    .dataTables_wrapper .mylength .dataTables_length {
        float:right
    }
    </style>

@endpush

@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Data Pengguna')

@section('link1', 'Master')
@section('link2', 'Pengguna')
@section('link3', 'Index')

@section('content')

@if (\Session::has('success'))
    <div class="alert bg-success text-white alert-styled-left alert-dismissible">
        <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
        <span class="font-weight-semibold">{{ \Session::get('success') }}
    </div>
@endif


<div class="card">
        <div class="card-header bg-light header-elements-inline">
                <h5 class="card-title">Form Filter</h5>
                <div class="header-elements">
                        <a href="{{ route('securities.users.create') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-plus3"></i></b> Tambah Pengguna</a>
                </div>
            </div>
            <div class="card-body">

                    <table style="width: 100%;">
                        <tr>
                            <td style="padding: 5px;width:20%;">Nama Bank</td>
                            <td style="padding: 5px;width:20%;">Nama Cabang</td>
                            <td style="padding: 5px;width:20%;">Nama Asuransi</td>
                            <td style="padding: 5px;width:30%;">Nama Pengguna</td>
                            <td style="padding: 5px;width:5%;"></td>
                            <td style="padding: 5px;width:5%;"></td>
                        </tr>
                        <tr>
                                <form method="post" id="search-form">
                                        <td style="padding: 5px;width:15%;">
                                                <select id="bank_id" name="bank_id" data-placeholder="Pilih Bank..." class="form-control form-control-select2 select-search"
                                                data-fouc>
                                                <option></option>
                                                <option value="0" selected>All</option>
                                                @foreach($banks as $item)
                                                <option value="{{ $item->id }}">{{ $item->name}}</option>
                                                @endforeach
                                            </select>
                                            </td>
                                        <td style="padding: 5px;width:20%;">
                                                <select id="branch_id" name="branch_id" data-placeholder="Pilih cabang..." class="form-control form-control-select2 select-search"
                                                data-fouc>
                                                <option value="0" selected>All</option>
                                            </select>
                                            </td>
                                        
                                        <td style="padding: 5px;width:20%;">
                                            <select id="insurance_id" name="insurance_id" data-placeholder="Pilih Asuransi..." class="form-control form-control-select2 select-search"
                                                required data-fouc>
                                                <option></option>
                                                <option value="0" selected>All</option>
                                                @foreach($insurance as $item)
                                                <option value="{{ $item->id }}">{{ $item->name}}</option>
                                                @endforeach
                                            </select>
                                        </td>

                                    <td style="padding: 5px;width:20%;"><input type="text" class="form-control" placeholder="nama" name="name" id="name"></td>


                            <td style="padding: 5px;width:5%;">
                                <button style="width: 100%" type="submit" class="btn btn-warning"><i class="icon-search4  mr-2"></i> Cari</button>

                            </td>
                        </form>
                        </tr>
                    </table>

            </div>
</div>


<div class="card">
    <table class="table datatable-button-html5-columns table-hover dtusers">
        <thead>
            <tr>
                <th style="width: 5%;">Id</th>
                <th style="width: 10%;">Email</th>
                <th style="width: 20%;">Nama Lengkap</th>
                <th style="width: 15%;">Nama Bank</th>
                <th style="width: 15%;">Nama Cabang</th>
                <th style="width: 15%;">Nama Asuransi</th>
                <th style="width: 5%;">Status</th>
                <th style="width: 20%;">Action</th>
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
        var bankID=$('#bank_id').val();
        var branchID=$('#branch_id').val();
        var insuranceID=$('#insurance_id').val();
        var custname=$('#name').val();
        $('#h_bankid').val(bankID);
        $('#h_branchid').val(branchID);
        $('#h_insuranceid').val(insuranceID);
        $('#h_name').val(custname);

        if(bankID) {
            getBranches(bankID);
        }

        $('#bank_id').on('change', function() {
            var bankID = $(this).val();
            $('#h_bankid').val(bankID);
            if(bankID) {
                getBranches(bankID);
            }else{
                $('#bank_id').empty();
            }
        });

        $('#branch_id').on('change', function() {
            var branchID = $(this).val();
            $('#h_branchid').val(branchID);
        });

        $('#insurance_id').on('change', function() {
            var insuranceID = $(this).val();
            $('#h_insuranceid').val(insuranceID);
        });

         $('#name').keyup(function (){
            var custname = $(this).val();
            $('#h_name').val(custname); // <-- and here
        });

        $(document).on('click', '.delete', function (e) {
            e.preventDefault();
            var id = $(this).data('id');
            swal({
                title: 'Yakin akan menghapus data ?',
                text: "Data tidak akan bisa direstore ketika sudah dihapus! ",
                type: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Ya, hapus data!',
                cancelButtonText: 'Tidak, batal!',
                confirmButtonClass: 'btn btn-success',
                cancelButtonClass: 'btn btn-danger',
                buttonsStyling: false
            }).then((result) => {
                if (result.value) {
                    $.ajax({
                        type: 'DELETE',
                        url: 'users/'+id,
                        data: {
                            '_token': $('input[name=_token]').val(),
                            'id': id
                        },
                        success: function(data) {
                            // $('.item'+ id).remove();
                            oTable.draw();
                            swal(
                                'Terhapus!',
                                'Data sudah terhapus.',
                                'success'
                            );
                        }
                    });
                } else if (result.dismiss === swal.DismissReason.cancel) {
                    swal(
                        'Dibatalkan',
                        'Data masih aman :)',
                        'error'
                    );
                }
            });
        });


        var oTable = $('.dtusers').DataTable({
            processing: true,
            serverSide: true,
            ajax: {
                    
                    url: '{!! route('ajax.securities.users') !!}',
                    data: function (d) {
                        d.bank_id = $('select[name=bank_id]').val();
                        d.branch_id = $('select[name=branch_id]').val();
                        d.insurance_id = $('select[name=insurance_id]').val();
                        d.name = $('input[name=name]').val();
                    }
            },
            headers: {
                'X-CSRF-Token': '{{ csrf_token() }}',
            },
            order: [[ 0, "desc" ]],
            buttons: {
				buttons: [
					{
						extend: 'excelHtml5',
						className: 'btn btn-light',
						exportOptions: {
							columns: ':visible'
                        },
                        text: '<i class="icon-file-excel mr-2"></i>Excel'
					},
					{
						extend: 'pdfHtml5',
						className: 'btn btn-light',
						exportOptions: {
							columns: [ 0, 1, 2, 5 ]
                        },
                        text: '<i class="icon-file-pdf ml-2"></i> PDF'
                    },
					{
						extend: 'colvis',
						text: '<i class="icon-three-bars"></i>',
						className: 'btn bg-blue btn-icon dropdown-toggle'
					}
				]
			},
            columns: [
                { data: 'id', name: 'id',className: "text-left" },
                { data: 'email', name: 'email',className: "text-left" },
                { data: 'name', name: 'name',className: "text-left" },
                { data: 'bank.name', name: 'bank',className: "text-left", defaultContent: "" },
                { data: 'branch.name', name: 'branch',className: "text-left", defaultContent: "" },
                { data: 'insurance.name', name: 'insurance',className: "text-left", defaultContent: "" },
                { data: 'is_active', name: 'is_active', render:function(data,type,row) {
                    if (data == 1) {
                        return '<span class="badge badge-success">Active</span>'
                    } else if (data==0) {
                        return '<span class="badge badge-secondary">Inactive</span>'
                    }
                },className: "text-center", orderable: false},
                { data: 'action', name: 'action', orderable: false, searchable: false,className: "text-center"},
            ],
        });

        $('select[name="bank_id"]').on('change', function() {
            var bankID = $(this).val();
            if(bankID) {
                getBranches(bankID);
            }else{
                $('select[name="branch_id"]').empty();
            }
        });

        $('#search-form').on('submit', function(e) {
            oTable.draw();
            e.preventDefault();
          });

    });

    function getBranches(bankID) {
        if(bankID) {
                $.ajax({
                    url: '{{ url("/") }}/ajax/getbranchesbybank/'+bankID,
                    
                    type: "GET",
                    dataType: "json",
                    success:function(data) {
                        $('select[name="branch_id"]').empty();
                        $('select[name="branch_id"]').append('<option value="0" selected>All</option>');
                        $.each(data, function(key, value) {
                            $('select[name="branch_id"]').append('<option value="'+ value['id'] +'">'+ value['name'] +'</option>');
                        });
                    }
                });
        } else {
            $('select[name="branch_id"]').empty();
        }
    }    

</script>


@endpush
