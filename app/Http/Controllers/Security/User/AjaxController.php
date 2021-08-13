<?php

namespace App\Http\Controllers\Security\User;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\User;
use App\Models\MasterBranch;

use Response;
use Yajra\Datatables\Datatables;

class AjaxController extends Controller
{
    public function get_all_users_data(Request $request)
    {
        if ($request->has('order') && $request->has('columns')) {
            $order_col_num = $request->get('order')[0]['column'];
            $get_search_column = $request->get('columns')[$order_col_num]['name'];
            $short_by = $request->get('order')[0]['dir'];

            if ($get_search_column == 'date') {
                $get_search_column = 'updated_at';
            }

        } else {
            $get_search_column = 'updated_at';
            $short_by = 'DESC';
        }

        $users = User::select(['id', 'name', 'email', 'bank_id', 'branch_id','pic_bank_id','insurance_id','is_active','updated_at'])
                       ->with('bank')->with('branch')->with('insurance')
                       ->orderBy($get_search_column, $short_by);

        return Datatables::of($users)
            ->addColumn('action', function($data){
                    return "
                    <a href='users/" . $data->id . "' class='btn btn-info btn-sm' title='View'><i class='icon-eye2 mr-0'></i></a>
                    <a href='users/" . $data->id . "/edit' class='btn btn-warning btn-sm' title='Edit'><i class='icon-pencil5 mr-0'></i></a>
                    <a href='#' class='btn btn-danger btn-sm delete' data-id='". $data->id ."' title='Delete'><i class='icon-trash mr-0'></i></a>
                     ";
            })
            ->filter(function ($query) use ($request) {

                if ($request->has('bank_id') && $request->get('bank_id') != '0') {
                    $query->where('bank_id', $request->get('bank_id'));
                }

                if ($request->has('branch_id') && $request->get('branch_id') != '0') {
                    $query->where('branch_id', $request->get('branch_id'));
                }

                if ($request->has('insurance_id') && $request->get('insurance_id') != '0') {
                    $query->where('insurance_id', $request->get('insurance_id'));
                }

                if ($request->has('name')) {
                    $query->where('name', 'like', "%{$request->get('name')}%");
                }

            })
            ->escapeColumns([])
            ->make(true);
    }


    public function get_branches_by_bank($bankid)
    {
        $branches= MasterBranch::select('id','name')->where("bank_id",$bankid)->get();
        return json_encode($branches);
    }

    

}
