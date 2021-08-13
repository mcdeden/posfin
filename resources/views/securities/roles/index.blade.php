@extends('layouts.full')

@push('styles')

@endpush


@section('title', 'Pemeliharaan Data')
@section('subtitle', 'Role')

@section('link1', 'Master')
@section('link2', 'Role')
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
        <h5 class="card-title">List Data Role</h5>
        <div class="header-elements">
            <a href="{{ route('securities.roles.create') }}" class="btn btn-primary btn-labeled btn-labeled-left"><b><i class="icon-plus3"></i></b> Tambah Role</a>
        </div>
    </div>

    <div class="card-body" style="margin-top: -20px;">
        <table class="table datatable-button-html5-columns table-hover dtdata">
            <thead>
                <tr>
                    <th style="width: 5%;">Id</th>
                    <th style="width: 20%;">Role</th>
                    <th style="width: 10%;">Nama Pendek</th>
                    <th style="width: 30%;">Deskripsi</th>
                    <th style="width: 15%;">Tgl. Buat</th>
                    <th style="width: 20%;">Action</th>
                </tr>
            </thead>
        </table>
    </div>
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
                        url: 'roles/'+id,
                        data: {
                            '_token': $('input[name=_token]').val(),
                            'id': id
                        },
                        success: function(data) {
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

        var oTable = $('.dtdata').DataTable({
            processing: true,
            serverSide: true,
            ajax: {
                url: '{!! route('ajax.securities.roles') !!}',
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
                { data: 'name', name: 'name',className: "text-left" },
                { data: 'display_name', name: 'display_name',className: "text-left" },
                { data: 'description', name: 'description',className: "text-left" },
                { data: 'created_at', name: 'created_at',className: "text-left" },
                { data: 'action', name: 'action', orderable: false, searchable: false,className: "text-center"},
            ],
        });

    });

</script>




@endpush
