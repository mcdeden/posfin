<?php

namespace App\Http\Controllers\Security\Permission;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\Permission;


use Response;
use Yajra\Datatables\Datatables;

class AjaxController extends Controller
{
    public function get_all_permissions_data(Request $request)
    {
        $datas = Permission::select(['id', 'name', 'display_name', 'description', 'created_at','updated_at'])
                ->orderBy('id','asc');

                return Datatables::of($datas)
                ->addColumn('action', function($data){
                        return "
                        <a href='permissions/" . $data->id . "' class='btn btn-info btn-sm' title='View'><i class='icon-eye2 mr-0'></i></a>
                         <a href='permissions/" . $data->id . "/edit' class='btn btn-warning btn-sm' title='Edit'><i class='icon-pencil5 mr-0'></i></a>

                         ";
                })
                ->escapeColumns([])
                ->make(true);
    }
}
