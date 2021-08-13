<?php

namespace App\Http\Controllers\Master\Branch;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\Models\MasterBranch;

use Response;
use Yajra\Datatables\Datatables;

class AjaxController extends Controller
{
    public function get_branches_by_bank($bankid)
    {
        $branches= MasterBranch::select('id','name')->where("bank_id",$bankid)->get();
        return json_encode($branches);
    }

    public function get_all_branches_data()
    {
        $datas = MasterBranch::select(['id', 'name','bank_id','is_kp','created_at', 'updated_at'])
                ->where('id','<>','AJB')
                ->with('bank')
                ->orderBy('created_at','desc');

        return Datatables::of($datas)
            ->addColumn('action', function($data){
                    return "
                    <a href='branches/" . $data->id . "' class='btn btn-info btn-sm' title='View'><i class='icon-eye2 mr-2'></i></a>
                     <a href='branches/" . $data->id . "/edit' class='btn btn-warning btn-sm' title='Edit'><i class='icon-pencil5 mr-2'></i></a>
                     <a href='#' class='btn btn-danger btn-sm delete' data-id='". $data->id ."' title='Delete'><i class='icon-trash mr-2'></i></a>
                     ";
            })
            ->escapeColumns([])
            ->make(true);
    }

    // public function get_branches_by_bank($bankid)
    // {
    //     $branches= MasterBranch::select('id','name')->where("bank_id",$bankid)->get();
    //     return json_encode($branches);
    // }

}
