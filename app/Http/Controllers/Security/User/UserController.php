<?php

namespace App\Http\Controllers\Security\User;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\User;
use App\Models\MasterBranch;
use App\Models\MasterBank;
use App\Models\MasterInsurances;
use App\Role;
use Hash;
use DB;
use Validator;
use Yajra\Datatables\Datatables;
use Session;

class UserController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function dropdownbranch($id)
    {
        $branches= MasterBranch::select('id','name')->where("bank_id",$id)->get();
        return json_encode($branches);
    }

    public function getUsers()
    {
        $users = User::with('bank')->with('branch')->get();

        return Datatables::of($users)->make(true);
    }

    public function index()
    {
        $banks= MasterBank::select('id','name')->where('id','<>','AJB')->get();
        $branches= MasterBranch::select('id','name')->get();
        $insurance= MasterInsurances::select('id','name')->get();

        return view('securities.users.index',compact('banks','branches','insurance'));
    }

    public function create()
    {
        $banks= MasterBank::select('id','name')->get();
        $branches= MasterBranch::select('id','name')->get();
        $insurance= MasterInsurances::select('id','name')->get();
        // $roles = Role::pluck('name','name')->all();

        $roles = Role::all();
        // return view('ajb.roles.create',compact('permissions'));

        return view('securities.users.create',compact('roles','banks','branches','insurance'));
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|same:repeat_password',
            'bank_id' =>'nullable',
            'branch_id' =>'nullable',
            'insurance_id' =>'nullable',
        ]);

        if ($validator->fails()) {
            return redirect()->route('securities.users.create')->withErrors($validator)->withInput();
        }

        $user = new User();
        $user->name = $request->name;
        $user->email = $request->email;
        $user->password = Hash::make(trim($request->password));
        $user->bank_id = $request->bank_id_user;
        $user->branch_id = $request->branch_id_user;
        $user->pic_bank_id = $request->bank_id_user;
        $user->insurance_id = $request->insurance_id_user;
        $user->save();

        $user->syncRoles($request->input('roles'));

        return redirect()->route('securities.users.index')->with('success','Sukses membuat user.');
    }

    public function show($id)
    {
        $user = User::where('id',$id)->with('roles')->with('insurance')->first();
        return view('securities.users.show')->withUser($user);
    }

    public function edit($id)
    {
        $user = User::where('id',$id)->with('roles')->first();
        $banks= MasterBank::select('id','name')->get();
        $roles = Role::pluck('name','name')->all();
        $branches= MasterBranch::select('id','name')->where("bank_id",$user->bank_id)->get();
        $insurance= MasterInsurances::select('id','name')->get();
        // $data = Role::where('id',$id)->with('permissions')->first();
        $roles = Role::all();


        return view('securities.users.edit',compact('id','user','roles','banks','branches','roles','insurance'));
    }

    public function update(Request $request, $id)
    {
        $this->validate($request, [
            'id' => 'required',
            'name' => 'required',
            'email' => 'required|email|unique:users,email,'.$id,
            'bank_id' =>'nullable',
            'branch_id' =>'nullable',
            'insurance_id' =>'nullable',
        ]);

        $user = User::findOrfail($id);
        $user->name = $request->name;
        // $user->name = $request->username;
        // $user->email = $request->email;
        if ($request->has('password')) {
            if ($request->password <> '') {
                $user->password = Hash::make(trim($request->password));
            }

        }
        $user->bank_id = $request->bank_id_user;
        $user->branch_id = $request->branch_id_user;
        $user->pic_bank_id = $request->bank_id_user;
        $user->insurance_id = $request->insurance_id_user;
        $user->save();

        $user->syncRoles($request->input('roles'));


        return redirect()->route('securities.users.index')->with('success','Role updated successfully');
    }

    public function destroy($id)
    {
        $user = User::findOrfail($id);
		$user->delete();

        return response ()->json ();
    }

    public function reset($id)
    {
        $user = User::findOrfail($id);

        return view('securities.users.reset',compact('id','user'));
    }


    public function resetpassword(Request $request, $id)
    {
        $this->validate($request, [
            'password' => 'required|same:repeat_password',
        ]);

        $user = User::findOrfail($id);
        $user->password = Hash::make(trim($request->password));

        if ($user->save()) {
            return redirect()->route('securities.users.index')->with('success','Sukses mereset password pengguna.');;
        } else {
            return redirect()->route('securities.users.reset',$id)->with('failed','Gagal mereset password pengguna. Silahkan hubungi tim IT.');;
        }

    }


}
