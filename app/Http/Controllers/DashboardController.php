<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use DB;
use App\Models\DataMember;
use Charts;
use App\User;


class DashboardController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }



    public function index()
    {
        $auth_user = auth()->user();
        $auth_bank_id = auth()->user()->bank_id;
        $auth_bank_name = auth()->user()->bank['name'];
        $auth_branch_id = auth()->user()->branch_id;
        $auth_branch_name = auth()->user()->branch['name'];
        $auth_pic_bank_id = auth()->user()->pic_bank_id;
        $auth_branch_is_kp = auth()->user()->branch['is_kp'];

        if ($auth_bank_id == '000') {
            if ($auth_pic_bank_id == '000') { //admin ajb for AJB Pusat
                $dbdatas = DB::table('data_members')
                                ->select(DB::raw('count(id) as total_member'),DB::raw('sum(pertanggungan) as total_pertanggungan'),DB::raw('sum(total_premi) as total_premi'))
                                ->get();
                $vfdatas = DB::table('data_hold_members')
                                ->select(DB::raw('count(id) as total_vf'))
                                ->get();
                $claimdatas = DB::table('data_claims')
                                ->select(DB::raw('sum(nominal_pengajuan) as total_claim'))
                                ->get();
                $top5claimdatas = DB::table('data_claims')
                                ->join('data_members','data_claims.member_id','=','data_members.id')
                                ->join('master_banks','data_claims.bank_id','=','master_banks.id')
                                ->join('master_branches','data_claims.branch_id','=','master_branches.id')
                                ->select('data_claims.bank_id','data_claims.branch_id','data_claims.member_id','master_banks.name as nama_bank','master_branches.name as nama_cabang',
                                'data_claims.customer_name','data_claims.nominal_pengajuan')
                                ->orderBy('data_claims.created_at','desc')
                                ->take(5)
                                ->get();
            } else { //ajb user for handle client
                $dbdatas = DB::table('data_members')
                                ->select(DB::raw('count(id) as total_member'),DB::raw('sum(pertanggungan) as total_pertanggungan'),DB::raw('sum(total_premi) as total_premi'))
                                ->where('bank_id',$auth_pic_bank_id)
                                ->groupBy('bank_id')
                                ->get();
                $vfdatas = DB::table('data_hold_members')
                                ->select(DB::raw('count(id) as total_vf'))
                                ->where('bank_id',$auth_pic_bank_id)
                                ->groupBy('bank_id')
                                ->get();
                $claimdatas = DB::table('data_claims')
                                ->select(DB::raw('sum(nominal_pengajuan) as total_claim'))
                                ->where('bank_id',$auth_pic_bank_id)
                                ->groupBy('bank_id')
                                ->get();
                $top5claimdatas = DB::table('data_claims')
                                ->join('master_banks','bank_id','=','master_banks.id')
                                ->join('master_branches','branch_id','=','master_branches.id')
                                ->select('data_claims.bank_id','data_claims.branch_id','data_claims.member_id','master_banks.name as nama_bank','master_branches.name as nama_cabang',
                                'data_claims.customer_name','data_claims.nominal_pengajuan')
                                ->where('data_claims.bank_id',$auth_pic_bank_id)
                                ->orderBy('data_claims.created_at','desc')
                                ->take(5)
                                ->get();
            }
        } else {
            if ($auth_branch_is_kp == 1) { //user client = KP
                $dbdatas = DB::table('data_members')
                                ->select(DB::raw('count(id) as total_member'),DB::raw('sum(pertanggungan) as total_pertanggungan'),DB::raw('sum(total_premi) as total_premi'))
                                ->where('bank_id',$auth_bank_id)
                                ->groupBy('bank_id')
                                ->get();
                $vfdatas = DB::table('data_hold_members')
                                ->select(DB::raw('count(id) as total_vf'))
                                ->where('bank_id',$auth_bank_id)
                                ->groupBy('bank_id')
                                ->get();
                $claimdatas = DB::table('data_claims')
                                ->select(DB::raw('sum(nominal_pengajuan) as total_claim'))
                                ->where('bank_id',$auth_bank_id)
                                ->groupBy('bank_id')
                                ->get();
                $top5claimdatas = DB::table('data_claims')
                                ->join('master_banks','bank_id','=','master_banks.id')
                                ->join('master_branches','branch_id','=','master_branches.id')
                                ->select('data_claims.bank_id','data_claims.branch_id','data_claims.member_id','master_banks.name as nama_bank','master_branches.name as nama_cabang',
                                'data_claims.customer_name','data_claims.nominal_pengajuan')
                                ->where('data_claims.bank_id',$auth_bank_id)
                                ->orderBy('data_claims.created_at','desc')
                                ->take(5)
                                ->get();

            } else { // user client = Cabang
                $dbdatas = DB::table('data_members')
                                ->select(DB::raw('count(id) as total_member'),DB::raw('sum(pertanggungan) as total_pertanggungan'),DB::raw('sum(total_premi) as total_premi'))
                                ->where('bank_id',$auth_bank_id)
                                ->where('branch_id',$auth_branch_id)
                                ->groupBy('bank_id','branch_id')
                                ->get();
                $vfdatas = DB::table('data_hold_members')
                                ->select(DB::raw('count(id) as total_vf'))
                                ->where('bank_id',$auth_bank_id)
                                ->where('branch_id',$auth_branch_id)
                                ->groupBy('bank_id','branch_id')
                                ->get();
                $claimdatas = DB::table('data_claims')
                                ->select(DB::raw('sum(nominal_pengajuan) as total_claim'))
                                ->where('bank_id',$auth_bank_id)
                                ->where('branch_id',$auth_branch_id)
                                ->groupBy('bank_id','branch_id')
                                ->get();
                $top5claimdatas = DB::table('data_claims')
                                ->join('master_banks','bank_id','=','master_banks.id')
                                ->join('master_branches','branch_id','=','master_branches.id')
                                ->select('data_claims.bank_id','data_claims.branch_id','data_claims.member_id','master_banks.name as nama_bank','master_branches.name as nama_cabang',
                                'data_claims.customer_name','data_claims.nominal_pengajuan')
                                ->where('data_claims.bank_id',$auth_bank_id)
                                ->where('data_claims.branch_id',$auth_branch_id)
                                ->orderBy('data_claims.created_at','desc')
                                ->take(5)
                                ->get();
            }
        }

        return view('dashboard', compact('auth_user','dbdatas','vfdatas','claimdatas','top5claimdatas'));
    }

    public function chart_member()
    {
        $auth_user = auth()->user();
        $auth_bank_id = auth()->user()->bank_id;
        $auth_bank_name = auth()->user()->bank['name'];
        $auth_branch_id = auth()->user()->branch_id;
        $auth_branch_name = auth()->user()->branch['name'];
        $auth_pic_bank_id = auth()->user()->pic_bank_id;
        $auth_branch_is_kp = auth()->user()->branch['is_kp'];

        if ($auth_bank_id == '000') {
            if ($auth_pic_bank_id == '000') { //admin ajb for AJB Pusat
                $members =  DB::table('master_data_status')
                    ->leftJoin('data_members', function($join) {
                        $join->on('master_data_status.id', '=', 'data_members.data_status_id');
                    })
                    ->select('master_data_status.id as id','master_data_status.name as label','master_data_status.short_name as shortlabel', DB::raw('count(data_members.id) as jumlah, sum(data_members.pertanggungan)/1000000 as total_pertanggungan,sum(data_members.total_premi)/1000000 as total_premi'))
                    ->groupBy('master_data_status.id','master_data_status.name','master_data_status.short_name')
                    ->get();
            } else { //ajb user for handle client
                $members =  DB::table('master_data_status')
                    ->leftJoin('data_members', function($join) use ($auth_pic_bank_id) {
                        $join->on('master_data_status.id', '=', 'data_members.data_status_id')
                             ->where('data_members.bank_id', '=', $auth_pic_bank_id);
                    })
                    ->select('master_data_status.id as id','master_data_status.name as label','master_data_status.short_name as shortlabel', DB::raw('count(data_members.id) as jumlah, sum(data_members.pertanggungan)/1000000 as total_pertanggungan,sum(data_members.total_premi)/1000000 as total_premi'))
                    ->groupBy('master_data_status.id','master_data_status.name','master_data_status.short_name')
                    ->get();
            }
        } else {
            if ($auth_branch_is_kp == 1) { //user client = KP
                $members =  DB::table('master_data_status')
                            ->leftJoin('data_members', function($join) use ($auth_bank_id) {
                                $join->on('master_data_status.id', '=', 'data_members.data_status_id')
                                     ->where('data_members.bank_id', '=', $auth_bank_id);
                            })
                            ->select('master_data_status.id as id','master_data_status.name as label','master_data_status.short_name as shortlabel', DB::raw('count(data_members.id) as jumlah, sum(data_members.pertanggungan)/1000000 as total_pertanggungan,sum(data_members.total_premi)/1000000 as total_premi'))
                            ->groupBy('master_data_status.id','master_data_status.name','master_data_status.short_name')
                            ->get();
            } else { // user client = Cabang
                $members =  DB::table('master_data_status')
                            ->leftJoin('data_members', function($join) use ($auth_bank_id,$auth_branch_id) {
                                $join->on('master_data_status.id', '=', 'data_members.data_status_id')
                                     ->where('data_members.bank_id', '=', $auth_bank_id)
                                     ->where('data_members.branch_id','=',$auth_branch_id)
                                     ->orWhere('data_members.branch_id','=',null);
                            })
                            ->select('master_data_status.id as id','master_data_status.name as label','master_data_status.short_name as shortlabel', DB::raw('count(data_members.id) as jumlah, sum(data_members.pertanggungan)/1000000 as total_pertanggungan,sum(data_members.total_premi)/1000000 as total_premi'))
                            ->groupBy('master_data_status.id','master_data_status.name','master_data_status.short_name')
                            ->get();
            }
        }

        return response()->json($members);
    }


      public function chart_claim()
      {
        $auth_user = auth()->user();
        $auth_bank_id = auth()->user()->bank_id;
        $auth_bank_name = auth()->user()->bank['name'];
        $auth_branch_id = auth()->user()->branch_id;
        $auth_branch_name = auth()->user()->branch['name'];
        $auth_pic_bank_id = auth()->user()->pic_bank_id;
        $auth_branch_is_kp = auth()->user()->branch['is_kp'];

        if ($auth_bank_id == 'AJB') {
            if ($auth_pic_bank_id == 'AJB') { //admin ajb for AJB Pusat
                $claims =  DB::table('master_claim_status')
                            ->leftJoin('data_claims', function($join) use ($auth_pic_bank_id) {
                                $join->on('master_claim_status.id', '=', 'data_claims.claim_status_id');
                            })
                            ->select('master_claim_status.id as id','master_claim_status.name as label','master_claim_status.short_name as shortlabel', DB::raw('count(data_claims.id) as jumlah, sum(data_claims.nominal_pengajuan)/1000000 as total_pengajuan'))
                            ->groupBy('master_claim_status.id','master_claim_status.name','master_claim_status.short_name')
                            ->get();
            } else { //ajb user for handle client
                $claims =  DB::table('master_claim_status')
                            ->leftJoin('data_claims', function($join) use ($auth_pic_bank_id) {
                                $join->on('master_claim_status.id', '=', 'data_claims.claim_status_id')
                                     ->where('data_claims.bank_id', '=', $auth_pic_bank_id);
                            })
                            ->select('master_claim_status.id as id','master_claim_status.name as label','master_claim_status.short_name as shortlabel', DB::raw('count(data_claims.id) as jumlah, sum(data_claims.nominal_pengajuan)/1000000 as total_pengajuan'))
                            ->groupBy('master_claim_status.id','master_claim_status.name','master_claim_status.short_name')
                            ->get();
            }
        } else {
            if ($auth_branch_is_kp == 1) { //user client = KP
                $claims =  DB::table('master_claim_status')
                            ->leftJoin('data_claims', function($join) use ($auth_bank_id) {
                                $join->on('master_claim_status.id', '=', 'data_claims.claim_status_id')
                                     ->where('data_claims.bank_id', '=', $auth_bank_id);
                            })
                            ->select('master_claim_status.id as id','master_claim_status.name as label','master_claim_status.short_name as shortlabel', DB::raw('count(data_claims.id) as jumlah, sum(data_claims.nominal_pengajuan)/1000000 as total_pengajuan'))
                            ->groupBy('master_claim_status.id','master_claim_status.name','master_claim_status.short_name')
                            ->get();
            } else { // user client = Cabang
                $claims =  DB::table('master_claim_status')
                            ->leftJoin('data_claims', function($join) use ($auth_bank_id,$auth_branch_id) {
                                $join->on('master_claim_status.id', '=', 'data_claims.claim_status_id')
                                     ->where('data_claims.bank_id', '=', $auth_bank_id)
                                     ->where('data_claims.branch_id','=',$auth_branch_id)
                                     ->orWhere('data_claims.branch_id','=',null);
                            })
                            ->select('master_claim_status.id as id','master_claim_status.name as label','master_claim_status.short_name as shortlabel', DB::raw('count(data_claims.id) as jumlah, sum(data_claims.nominal_pengajuan)/1000000 as total_pengajuan'))
                            ->groupBy('master_claim_status.id','master_claim_status.name','master_claim_status.short_name')
                            ->get();
            }
        }

        return response()->json($claims);
      }


}
