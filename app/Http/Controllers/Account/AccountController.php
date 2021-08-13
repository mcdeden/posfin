<?php

namespace App\Http\Controllers\Account;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\Models\MasterBank;
use App\Models\MasterBranch;
use App\User;
use Hash;

class AccountController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function profile()
    {
        $auth_user_id = auth()->user()->id;
        $auth_bank_id = auth()->user()->bank_id;

        $banks= MasterBank::select('id','name')
        ->orderBy('id','asc')->get();

        $branches= MasterBranch::select('id','name')
        ->where('bank_id',$auth_bank_id)
        ->orderBy('id','asc')->get();

        $user = User::findOrfail($auth_user_id);
        return view('accounts.myprofile',compact('auth_user_id','banks','branches','user'));
    }

    public function update_profile(Request $request, $id)
    {
        $this->validate($request, [
            'id' => 'required',
            'name' => 'required',
            'email' => 'required|email|unique:users,email,'.$id,
            'bank_id' =>'required',
            'branch_id' =>'required',
            'pic_bank_id' =>'required'
        ]);

        $user = User::findOrfail($id);
        $user->name = $request->name;
        $user->bank_id = $request->bank_id;
        $user->branch_id = $request->branch_id;
        $user->pic_bank_id = $request->pic_bank_id;
        $user->save();

        return redirect()->route('accounts.profile')->with('success','Profil updated successfully');

    }

    public function update_password(Request $request, $id)
    {        

        $this->validate($request, [
            'new_password' => 'required|same:conf_password',
        ]);

        $user = User::findOrfail($id);
        $user->password = Hash::make(trim($request->new_password));

        $user->save();

        return redirect()->route('accounts.profile')->with('success','Password updated successfully');
    }

}
