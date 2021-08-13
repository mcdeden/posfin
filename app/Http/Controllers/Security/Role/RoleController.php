<?php

namespace App\Http\Controllers\Security\Role;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\Role;
use App\Permission;
use Validator;

class RoleController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        // return view('ajb.roles.index');
        return view('securities.roles.index');
    }


    public function create()
    {
        $permissions = Permission::all();
        return view('securities.roles.create',compact('permissions'));
    }


    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|alphadash|unique:roles,name',
            'display_name' => 'required'
        ]);

        if ($validator->fails()) {
            return redirect()->route('securities.roles.create')->withErrors($validator)->withInput();
        }

        $data = new Role();
        $data->name = $request->name;
        $data->display_name = $request->display_name;
        $data->description = $request->description;
        $data->save();

        $data->syncPermissions($request->input('permissions'));

        return redirect()->route('securities.roles.index')->with('success','Sukses membuat role.');
    }


    public function show($id)
    {
        $data = Role::findOrfail($id);
        return view('securities.roles.show')->withData($data);
    }


    public function edit($id)
    {
        $data = Role::where('id',$id)->with('permissions')->first();
        $permissions = Permission::all();

        return view('securities.roles.edit',compact('data','permissions'));
    }


    public function update(Request $request, $id)
    {
        $this->validate($request, [
            'id' => 'required',
            'name' => 'required',
            'display_name' => 'required'
        ]);

        $data = Role::findOrfail($id);
        $data->id = $request->id;
        $data->name = $request->name;
        $data->display_name = $request->display_name;
        $data->description = $request->description;
        $data->save();

        $data->syncPermissions($request->input('permissions'));


        return redirect()->route('securities.roles.index')->with('success','Role updated successfully');
    }


    public function destroy($id)
    {
        $data = Role::findOrfail($id);
		$data->delete();

        return response ()->json ();
    }
}
