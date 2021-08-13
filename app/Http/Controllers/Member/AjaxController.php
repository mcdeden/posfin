<?php

namespace App\Http\Controllers\Member;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use Response;
use Yajra\Datatables\Datatables;

use App\Models\DataMember;

class AjaxController extends Controller
{
    public function get_all_data_members(Request $request)
    {
        $auth_bank_id = auth()->user()->bank_id;
        $auth_branch_id = auth()->user()->branch_id;
        $auth_branch_is_kp = auth()->user()->branch['is_kp'];

        if ($request->has('branch_id')) {
            if ($request->get('branch_id') != '0') {
                $p_branch_id = $request->get('branch_id');
            } else {
                if ($auth_branch_is_kp == 1) {
                    $p_branch_id = '';
                } else {
                    $p_branch_id = $auth_branch_id;
                }
            }
        } else {
            if ($auth_branch_is_kp == 1) {
                $p_branch_id = '';
            } else {
                $p_branch_id = $auth_branch_id;
            }
        }

        if ($request->has('insurance_id')) {
            if ($request->get('insurance_id') != '0') {
                $p_insurance_id = $request->get('insurance_id');
            } else {
                $p_insurance_id = '';
            }
        }

        if ($request->has('product_id')) {
            if ($request->get('product_id') != '0') {
                $p_product_id = $request->get('product_id');
            } else {
                $p_product_id = '';
            }
        }

        if ($request->has('customer_name')) {
            $p_name = $request->get('customer_name');
        } else {
            $p_name = '';
        }

        if ($request->has('data_status_id')) {
            if ($request->get('data_status_id') != '0') {
                $p_data_status_id = $request->get('data_status_id');
            } else {
                $p_data_status_id = '';
            }
        }

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

        if ($auth_branch_is_kp == 1) {
            $members= DataMember::select(['id','loan_id','polis_number','bank_id','branch_id','insurance_id','product_id','total_premi','plafond',
            'pertanggungan','currency','tenor','insurance_rate','start_date','end_date','customer_deposit_amount','cif',
            'customer_name','birth_date','born_place','job','data_status_id','record_status_id','created_at','updated_at'])
            ->with('bank')->with('branch')->with('product')->with('data_status')->with('record_status')
            ->where('bank_id',$auth_bank_id)
            ->where('insurance_id', 'like', "%".$p_insurance_id."%")
            ->where('product_id', 'like', "%".$p_product_id."%")
            ->where('customer_name', 'like', "%".$p_name."%")
            ->where('data_status_id', 'like', "%".$p_data_status_id."%")
            ->orderBy('created_at','desc');
        } else {
                $members= DataMember::select(['id','loan_id','polis_number','bank_id','branch_id','insurance_id','product_id','total_premi','plafond',
                'pertanggungan','currency','tenor','insurance_rate','start_date','end_date','customer_deposit_amount','cif',
                'customer_name','birth_date','born_place','job','data_status_id','record_status_id','created_at','updated_at'])
                ->with('bank')->with('branch')->with('product')->with('data_status')->with('record_status')
                ->where('bank_id',$auth_bank_id)
                ->where('insurance_id', 'like', "%".$p_insurance_id."%")
                ->where('product_id', 'like', "%".$p_product_id."%")
                ->where('customer_name', 'like', "%".$p_name."%")
                ->where('data_status_id', 'like', "%".$p_data_status_id."%")
                ->whereHas('branch', function($query) use ($p_branch_id) {
                    $query->where('id', 'like', "%".$p_branch_id."%");
                })
                ->orderBy('created_at','desc');
        }

        return Datatables::of($members)
            ->addColumn('action', function($member){
                    return "
                     <a href='members/" . $member->id . "' class='btn btn-info btn-sm' title='View'><i class='icon-eye2 mr-0'></i></a>
                     <!--<a href='members/" . $member->id . "/edit' class='btn btn-warning btn-sm' title='Edit'><i class='icon-pencil5 mr-0'></i></a>-->
                     ";
            })
            ->filter(function ($query) use ($request) {

                if ($request->has('branch_id') && $request->get('branch_id') != '0') {
                    $req_branch = $request->get('branch_id');
                    $query->where('branch_id', 'like', "%".$req_branch."%");
                }

                if ($request->has('insurance_id') && $request->get('insurance_id') != '0') {
                    $req_insurance = $request->get('insurance_id');
                    $query->where('insurance_id', 'like', "%".$req_insurance."%");
                }

                if ($request->has('product_id') && $request->get('product_id') != '0') {
                    $req_product = $request->get('product_id');
                    $query->where('product_id', 'like', "%".$req_product."%");
                }

                if ($request->has('customer_name')) {
                    $req_cust_name = $request->get('customer_name');
                    $query->where('customer_name', 'like', "%".$req_cust_name."%");
                }

                if ($request->has('data_status_id') && $request->get('data_status_id') != '0') {
                    $req_datastatus = $request->get('data_status_id');
                    $query->where('data_status_id', 'like', "%".$req_datastatus."%");
                }

            })
            // ->escapeColumns([])
            ->addIndexColumn()
            ->make(true);
    }
    
}
