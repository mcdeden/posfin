@extends('layouts.full')

@push('styles')

{!! Charts::styles() !!}

<style>
    .input-textarea-aktif {
        background-color: #FBF9E4;
    }
</style>

@endpush

@section('title', 'Dashboard')
@section('subtitle', 'overall review')

@section('link1', 'Home')
@section('link2', 'Dashboard')

@section('content')

{{-- row 1 --}}
<div class="row">
    <div class="col-sm-6 col-xl-3">
        <div class="card card-body bg-blue-400 has-bg-image">
            <div class="media">
                <div class="ml-3 align-self-center">
                    <i class="icon-users icon-3x opacity-75"></i>
                </div>
                <div class="media-body text-right">
                    <h3 class="mb-0">@foreach ($dbdatas as $total) {{ $total->total_member }}<br> @endforeach</h3>
                    <span class="text-uppercase font-size-xs">jumlah peserta</span>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-xl-3">
        <div class="card card-body bg-indigo-400 has-bg-image">
            <div class="media">
                <div class="mr-3 align-self-center">
                    <i class="icon-umbrella icon-3x opacity-75"></i>
                </div>

                <div class="media-body text-right">
                    <h3 class="mb-0">@foreach ($dbdatas as $total) {{ number_format($total->total_pertanggungan, 2,',','.') }}<br> @endforeach</h3>
                    <span class="text-uppercase font-size-xs">total pertanggungan</span>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-xl-3">
        <div class="card card-body bg-success-400 has-bg-image">
            <div class="media">
                <div class="mr-3 align-self-center">
                    <i class="icon-cash4 icon-3x opacity-75"></i>
                </div>

                <div class="media-body text-right">
                    <h3 class="mb-0">@foreach ($dbdatas as $total) {{ number_format($total->total_premi, 2,',','.') }}<br> @endforeach</h3>
                    <span class="text-uppercase font-size-xs">total premi</span>
                </div>
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-xl-3">
        <div class="card card-body bg-danger-400 has-bg-image">
            <div class="media">
                <div class="ml-3 align-self-center">
                    <i class="icon-enter6 icon-3x opacity-75"></i>
                </div>
                <div class="media-body text-right">
                    <h3 class="mb-0">@foreach ($vfdatas as $total) {{ $total->total_vf }}<br> @endforeach</h3>
                    <span class="text-uppercase font-size-xs">total gagal validasi</span>
                </div>


            </div>
        </div>
    </div>
</div>

{{-- row 2 --}}
<div class="row">

    <div class="col-xl-4">
        <div class="card">
            <div class="card-header bg-light header-elements-inline">
                <h5 class="card-title">Grafik Jumlah Peserta</h5>
                <div class="header-elements">
                    <div class="list-icons">
                        <a class="list-icons-item" data-action="collapse"></a>
                    </div>
                </div>
            </div>

            <div class="card-body">
                <div class="chart-container">
                    <div class="chart has-fixed-height" style="width:100%" id="grafik_peserta"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-8">
        <div class="card">
            <div class="card-header bg-light header-elements-inline">
                <h5 class="card-title">Grafik Premi & Pertanggungan (satuan juta)</h5>
                <div class="header-elements">
                    <div class="list-icons">
                        <a class="list-icons-item" data-action="collapse"></a>
                    </div>
                </div>
            </div>

            <div class="card-body">
                <div class="chart-container">
                    <div class="chart has-fixed-height" style="width:100%" id="grafik_premi"></div>
                </div>
            </div>
        </div>
    </div>

</div>

{{-- row 3 --}}
<div class="row">

    <div class="col-xl-12">
        <div class="card">
            <div class="card-footer">
                <table style="width: 100%;text-align: center;">
                    <tr>
                        <td>UNV : <span style="font-weight: bold;">Unverified</span></td>
                        <td>OPN : <span style="font-weight: bold;">Open</span></td>
                        <td>CLS : <span style="font-weight: bold;">Closed</span></td>
                        <td>ONC : <span style="font-weight: bold;">On Claiming</span></td>
                        <td>CLM : <span style="font-weight: bold;">Claimed</span></td>
                        <td>VLF : <span style="font-weight: bold;">Validation Failed</span></td>
                        <td>OPR : <span style="font-weight: bold;">On Proposing Repayment</span></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

</div>



<div class="row">

        <div class="col-lg-9">
                <div class="row">

                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-header bg-light header-elements-inline">
                                    <h6 class="card-title">Grafik Jumlah Claim</h6>
                                    <div class="header-elements">
                                        <a class="list-icons-item" data-action="collapse"></a>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="chart has-fixed-height" style="width:100%" id="grafik_jumlah_claim"></div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-8">
                            <div class="card">
                                <div class="card-header bg-light header-elements-inline">
                                    <h6 class="card-title">Grafik Nominal Pengajuan (satuan juta)</h6>
                                    <div class="header-elements">
                                        <a class="list-icons-item" data-action="collapse"></a>
                                    </div>
                                </div>

                                <div class="card-body">
                                    <div class="chart has-fixed-height" style="width:100%" id="grafik_claim"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">

                            <div class="col-xl-12">
                                <div class="card">
                                    <div class="card-footer">
                                        <table style="width: 100%;text-align: center;">
                                            <tr>
                                                <td>ONR : <span style="font-weight: bold;">On Review</span></td>
                                                <td>KRD : <span style="font-weight: bold;">Kurang Dokumen</span></td>
                                                <td>DBT : <span style="font-weight: bold;">Dokumen Belum di Terima</span></td>
                                                <td>DKL : <span style="font-weight: bold;">Dokumen Lengkap</span></td>
                                                <td>CCS : <span style="font-weight: bold;">Claim ditolak / Compromise Settlement</span></td>
                                                <td>CPD : <span style="font-weight: bold;">Claim dibayar</span></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>

                        </div>
        </div>

        <div class="col-lg-3">
            <div class="card card-body bg-blue-400 has-bg-image">
                <div class="media">
                    <div class="ml-3 align-self-center">
                        <i class="icon-cash4 icon-3x opacity-75"></i>
                    </div>
                    <div class="media-body text-right">
                        <h3 class="mb-0">@foreach ($claimdatas as $total) {{ number_format($total->total_claim, 2,',','.') }} <br> @endforeach</h3>
                        <span class="text-uppercase font-size-xs">Total Claim</span>
                    </div>


                </div>
            </div>

            <div class="card">
                <div class="card-header bg-light header-elements-inline">
                    <h6 class="card-title">5 Claim Terbaru</h6>
                    <div class="header-elements">                       
                    </div>
                </div>


                <div class="table-responsive">
                    <table class="table text-nowrap">
                        <tbody>
                                @foreach ($top5claimdatas as $data)
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="mr-3">
                                            <a href="#" class="btn bg-primary-400 rounded-round btn-icon btn-sm">
                                                <span class="letter-icon"></span>
                                            </a>
                                        </div>
                                        <div>
                                            <a href="#" class="text-default font-weight-semibold letter-icon-title">{{ $data->customer_name }}</a>
                                            <div class="text-muted font-size-sm"><i class="icon-checkmark3 font-size-sm mr-1"></i>Rp. {{ $data->nominal_pengajuan }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="text-muted font-size-sm">{{ $data->branch_id }}</span>
                                </td>
                            </tr>
                            @endforeach


                        </tbody>

                    </table>
                </div>
            </div>
        </div>
    </div>


@endsection

@push('scripts')

<!-- Theme JS files -->
<script src="{{ asset('js/visualization/d3/d3.min.js') }}"></script>
<script src="{{ asset('js/visualization/d3/d3_tooltip.js') }}"></script>
<script src="{{ asset('js/forms/styling/switchery.min.js') }}"></script>
<script src="{{ asset('js/forms/selects/bootstrap_multiselect.js') }}"></script>
<script src="{{ asset('js/ui/moment/moment.min.js') }}"></script>
<script src="{{ asset('js/pickers/daterangepicker.js') }}"></script>
<script src="{{ asset('js/demo/dashboard.js') }}"></script>

<script src="{{ asset('js/visualization/echarts/echarts.min.js') }}"></script>

<script>
    var url_premi = "{{url('dashboard/chart_member')}}";
    var url_claim = "{{url('dashboard/chart_claim')}}";

    var ids = new Array();
    var jumlahs = new Array();
    var total_pertanggungans = new Array();
    var total_premis = new Array();
    var labels = new Array();
    var shortlabels = new Array();

    var claim_ids = new Array();
    var claim_labels = new Array();
    var claim_shortlabels = new Array();
    var claim_jumlahs = new Array();
    var claim_pengajuans = new Array();

    $.get(url_premi, function(response){
        response.forEach(element => {
            // alert(element.id);
            ids.push(element.id);
            jumlahs.push(element.jumlah);
            total_pertanggungans.push(element.total_pertanggungan);
            total_premis.push(element.total_premi);
            labels.push(element.label);
            shortlabels.push(element.shortlabel);
            // colors.push(dynamicColors());
        });

        var grafik_peserta_element = document.getElementById('grafik_peserta');
        var grafik_premi_element = document.getElementById('grafik_premi');
        if (grafik_peserta_element) {

            // Initialize chart
            var columns_basic = echarts.init(grafik_peserta_element);

            // Options
            columns_basic.setOption({
                // Define colors
            color: ['#2ec7c9','#b6a2de','#5ab1ef','#ffb980','#d87a80'],

            // Global text styles
            textStyle: {
                fontFamily: 'Roboto, Arial, Verdana, sans-serif',
                fontSize: 13
            },

            // Chart animation duration
            animationDuration: 750,

            // Setup grid
            grid: {
                left: 0,
                right: 40,
                top: 35,
                bottom: 0,
                containLabel: true
            },

            // Add legend
            legend: {
                data: ['Jumlah'],
                itemHeight: 8,
                itemGap: 20,
                textStyle: {
                    padding: [0, 5]
                }
            },

            // Add tooltip
            tooltip: {
                trigger: 'axis',
                backgroundColor: 'rgba(0,0,0,0.75)',
                padding: [10, 15],
                textStyle: {
                    fontSize: 13,
                    fontFamily: 'Roboto, sans-serif'
                },
            },

            // Horizontal axis
            xAxis: [{
                type: 'category',
                data: shortlabels,
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    show: true,
                    lineStyle: {
                        color: '#eee',
                        type: 'dashed'
                    }
                }
            }],

            // Vertical axis
            yAxis: [{
                type: 'value',
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    lineStyle: {
                        color: ['#eee']
                    }
                },
                splitArea: {
                    show: true,
                    areaStyle: {
                        color: ['rgba(250,250,250,0.1)', 'rgba(0,0,0,0.01)']
                    }
                }


            }],

            // Add series
            series: [
                {
                    name: 'Jumlah',
                    type: 'bar',
                    data: jumlahs,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'top',
                                textStyle: {
                                    fontWeight: 500
                                }
                            }
                        }
                    },
                }
            ]
            });
        }

        if (grafik_premi_element) {

            // Initialize chart
            var columns_basic = echarts.init(grafik_premi_element);

            // Options
            columns_basic.setOption({
                // Define colors
            // color: ['#2ec7c9','#b6a2de','#5ab1ef','#ffb980','#d87a80'],

            // Global text styles
            textStyle: {
                fontFamily: 'Roboto, Arial, Verdana, sans-serif',
                fontSize: 10
            },

            // Chart animation duration
            animationDuration: 750,

            // Setup grid
            grid: {
                left: 0,
                right: 40,
                top: 35,
                bottom: 0,
                containLabel: true
            },

            // Add legend
            legend: {
                data: ['Pertanggungan','Premi'],
                itemHeight: 8,
                itemGap: 20,
                textStyle: {
                    padding: [0, 5]
                }
            },

            // Add tooltip
            tooltip: {
                trigger: 'axis',
                backgroundColor: 'rgba(0,0,0,0.75)',
                padding: [10, 15],
                textStyle: {
                    fontSize: 13,
                    fontFamily: 'Roboto, sans-serif'
                },
            },

            // Horizontal axis
            xAxis: [{
                type: 'category',
                data: shortlabels,
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    show: true,
                    lineStyle: {
                        color: '#eee',
                        type: 'dashed'
                    }
                }
            }],

            // Vertical axis
            yAxis: [{
                type: 'value',
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    lineStyle: {
                        color: ['#eee']
                    }
                },
                splitArea: {
                    show: true,
                    areaStyle: {
                        color: ['rgba(250,250,250,0.1)', 'rgba(0,0,0,0.01)']
                    }
                }


            }],

            // Add series
            series: [
                {
                    name: 'Pertanggungan',
                    type: 'bar',
                    data: total_pertanggungans,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'top',
                                textStyle: {
                                    fontWeight: 500
                                }
                            }
                        }
                    },
                    // markLine: {
                    //     data: [{type: 'average', name: 'Average'}]
                    // }
                },
                {
                    name: 'Premi',
                    type: 'bar',
                    data: total_premis,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'top',
                                textStyle: {
                                    fontWeight: 500
                                }
                            }
                        }
                    },
                    // markLine: {
                    //     data: [{type: 'average', name: 'Average'}]
                    // }
                }
            ]
            });
        }
    });

    $.get(url_claim, function(response){
        response.forEach(element => {
            // alert(element.id);
            claim_ids.push(element.id);
            claim_labels.push(element.label);
            claim_shortlabels.push(element.shortlabel);
            claim_jumlahs.push(element.jumlah);
            claim_pengajuans.push(element.total_pengajuan);

            // jumlahs.push(element.jumlah);
            // total_pertanggungans.push(element.total_pertanggungan);
            // total_premis.push(element.total_premi);

            // shortlabels.push(element.shortlabel);
            // colors.push(dynamicColors());
        });

        var grafik_jumlah_claim_element = document.getElementById('grafik_jumlah_claim');
        var grafik_claim_element = document.getElementById('grafik_claim');

        if (grafik_jumlah_claim_element) {

            // Initialize chart
            var columns_basic = echarts.init(grafik_jumlah_claim_element);

            // Options
            columns_basic.setOption({
                // Define colors
            color: ['#d87a80'],

            // Global text styles
            textStyle: {
                fontFamily: 'Roboto, Arial, Verdana, sans-serif',
                fontSize: 13
            },

            // Chart animation duration
            animationDuration: 750,

            // Setup grid
            grid: {
                left: 0,
                right: 40,
                top: 35,
                bottom: 0,
                containLabel: true
            },

            // Add legend
            legend: {
                data: ['Jumlah'],
                itemHeight: 8,
                itemGap: 20,
                textStyle: {
                    padding: [0, 5]
                }
            },

            // Add tooltip
            tooltip: {
                trigger: 'axis',
                backgroundColor: 'rgba(0,0,0,0.75)',
                padding: [10, 15],
                textStyle: {
                    fontSize: 13,
                    fontFamily: 'Roboto, sans-serif'
                },
            },

            // Horizontal axis
            xAxis: [{
                type: 'category',
                data: claim_shortlabels,
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    show: true,
                    lineStyle: {
                        color: '#eee',
                        type: 'dashed'
                    }
                }
            }],

            // Vertical axis
            yAxis: [{
                type: 'value',
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    lineStyle: {
                        color: ['#eee']
                    }
                },
                splitArea: {
                    show: true,
                    areaStyle: {
                        color: ['rgba(250,250,250,0.1)', 'rgba(0,0,0,0.01)']
                    }
                }


            }],

            // Add series
            series: [
                {
                    name: 'Jumlah',
                    type: 'bar',
                    data: claim_jumlahs,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'top',
                                textStyle: {
                                    fontWeight: 500
                                }
                            }
                        }
                    },
                }
            ]
            });
        }

        if (grafik_claim_element) {

            // Initialize chart
            var columns_basic = echarts.init(grafik_claim_element);

            // Options
            columns_basic.setOption({
                // Define colors
            // color: ['#b6a2de','#5ab1ef','#ffb980','#d87a80'],
            color: ['#ffb980','#d87a80'],

            // Global text styles
            textStyle: {
                fontFamily: 'Roboto, Arial, Verdana, sans-serif',
                fontSize: 10
            },

            // Chart animation duration
            animationDuration: 750,

            // Setup grid
            grid: {
                left: 0,
                right: 40,
                top: 35,
                bottom: 0,
                containLabel: true
            },

            // Add legend
            legend: {
                data: ['Pengajuan'],
                itemHeight: 8,
                itemGap: 20,
                textStyle: {
                    padding: [0, 5]
                }
            },

            // Add tooltip
            tooltip: {
                trigger: 'axis',
                backgroundColor: 'rgba(0,0,0,0.75)',
                padding: [10, 15],
                textStyle: {
                    fontSize: 13,
                    fontFamily: 'Roboto, sans-serif'
                },
            },

            // Horizontal axis
            xAxis: [{
                type: 'category',
                data: claim_shortlabels,
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    show: true,
                    lineStyle: {
                        color: '#eee',
                        type: 'dashed'
                    }
                }
            }],

            // Vertical axis
            yAxis: [{
                type: 'value',
                axisLabel: {
                    color: '#333'
                },
                axisLine: {
                    lineStyle: {
                        color: '#999'
                    }
                },
                splitLine: {
                    lineStyle: {
                        color: ['#eee']
                    }
                },
                splitArea: {
                    show: true,
                    areaStyle: {
                        color: ['rgba(250,250,250,0.1)', 'rgba(0,0,0,0.01)']
                    }
                }


            }],

            // Add series
            series: [
                {
                    name: 'Pengajuan',
                    type: 'bar',
                    data: claim_pengajuans,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'top',
                                textStyle: {
                                    fontWeight: 500
                                }
                            }
                        }
                    },
                    // markLine: {
                    //     data: [{type: 'average', name: 'Average'}]
                    // }
                }
            ]
            });
        }
    });

</script>














@endpush
