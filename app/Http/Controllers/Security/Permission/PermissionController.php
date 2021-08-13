<?php

namespace App\Http\Controllers\Security\Permission;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

use App\Permission;
use Validator;

class PermissionController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function index()
    {
        // $banks= MasterBank::select('id','name')->where('id','<>','AJB')->get();
        // $branches= MasterBranch::select('id','name')->get();

        return view('securities.permissions.index');
    }


    public function create()
    {
        return view('securities.permissions.create');
    }


    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|max:255|alphadash|unique:permissions,name',
            'display_name' => 'required|max:255'
        ]);

        if ($validator->fails()) {
            return redirect()->route('securities.permissions.create')->withErrors($validator)->withInput();
        }

        $data = new Permission();
        $data->name = $request->name;
        $data->display_name = $request->display_name;
        $data->description = $request->description;

        if ($data->save()) {
            return redirect()->route('securities.permissions.index')->with('success','Sukses membuat permission baru.');;
        } else {
            return redirect()->route('securities.permissions.create')->with('failed','Pembuatan permission baru gagal. Silahkan hubungi tim IT.');;
        }
    }


    public function show($id)
    {
        $data = Permission::findOrfail($id);
        return view('securities.permissions.show')->withData($data);
    }


    public function edit($id)
    {
        $data = Permission::findOrfail($id);

        return view('securities.permissions.edit',compact('data'));
    }


    public function update(Request $request, $id)
    {
        $this->validate($request, [
            'id' => 'required',
            'name' => 'required',
            'display_name' => 'required'
        ]);

        $data = Permission::findOrfail($id);
        $data->id = $request->id;
        $data->name = $request->name;
        $data->display_name = $request->display_name;
        $data->description = $request->description;

        if ($data->save()) {
            return redirect()->route('securities.permissions.index')->with('success','Sukses mengupdate permission.');;
        } else {
            return redirect()->route('securities.permissions.edit',$id)->with('failed','Gagal mengupdate permission. Silahkan hubungi tim IT.');;
        }
    }


    public function destroy($id)
    {
        $data = Permission::findOrfail($id);
		$data->delete();

        return response ()->json ();
    }
}
