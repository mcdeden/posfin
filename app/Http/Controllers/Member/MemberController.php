<?php

namespace App\Http\Controllers\Member;

use App\Http\Controllers\Controller;

use App\Models\DataMember;
use App\Models\MasterBranch;
use App\Models\MasterProduct;
use App\Models\MasterDataStatus;
use App\Models\MasterInsurances;

class MemberController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        $auth_branch_id = auth()->user()->branch_id;
        $auth_bank_id = auth()->user()->bank_id;
        $auth_branch_is_kp = auth()->user()->branch['is_kp'];

        if ($auth_branch_is_kp == 1) {
            $branches= MasterBranch::select('id','name')
            ->where('bank_id',$auth_bank_id)
            ->where('id','<>',$auth_branch_id)
            ->orderBy('id','asc')->get();
        } else {
                $branches= MasterBranch::select('id','name')
                ->where('bank_id',$auth_bank_id)
                ->Where('id',$auth_branch_id)
                ->orderBy('id','asc')
                ->get();
        }

        $datastatus= MasterDataStatus::select('id','name')
            ->where('id','<>',6)
            ->orderBy('id','asc')->get();

        $products= MasterProduct::select('id','name')
            ->where('bank_id',$auth_bank_id)
            ->orderBy('id','asc')->get();

        $insurance=  $insurance= MasterInsurances::select('id','name')
        ->whereHas('map_insurance', function ($query)use($auth_bank_id) {
            return $query->where('bank_id', '=', $auth_bank_id);
        })->get();;

        return view('members.index',compact('branches','products','datastatus','insurance'));
    }    

    public function show($id)
    {
        $member = DataMember::findOrfail($id);
        return view('members.show')->withMember($member);
    }

}
