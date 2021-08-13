<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('/',function () {
    return view('auth.login');
});

Route::group(['middleware' => 'prevent-back-history'],function(){

    Auth::routes();

    // Route::prefix('clients')->group(function () {
    //     Route::prefix('members')->group(function () {
    //         Route::get('/', 'Member\MemberController@index')->name('clients.members.index');
    //         Route::get('/{id}', 'Member\MemberController@show')->name('clients.members.show');
    //         Route::get('/ajax/get_all_data_members', 'Member\AjaxController@get_all_data_members')->name('clients.members.ajax.get_all_data_members');
    //     });        
    // });

    Route::prefix('members')->group(function () {
        Route::get('/', 'Member\MemberController@index')->name('members.index');
        Route::get('/{id}', 'Member\MemberController@show')->name('members.show');
        Route::get('/ajax/get_all_data_members', 'Member\AjaxController@get_all_data_members')->name('members.ajax.get_all_data_members');
    });

    Route::group(['middleware' => 'auth'],function(){
        Route::prefix('accounts')->group(function () {
            Route::get('profile', 'Account\AccountController@profile')->name('accounts.profile');
            Route::put('update_profile/{user}', 'Account\AccountController@update_profile')->name('accounts.update_profile');
            Route::patch('update_password/{user}', 'Account\AccountController@update_password')->name('accounts.update_password');
        });
    });

    Route::prefix('securities')->group(function() {
        Route::resource('users','Security\User\UserController',['as' => 'securities']);
        Route::resource('roles','Security\Role\RoleController',['as' => 'securities']);
        Route::resource('permissions','Security\Permission\PermissionController',['as' => 'securities']);
    });

    Route::prefix('ajax')->group(function() {
        Route::get('get_all_users_data', 'Security\User\AjaxController@get_all_users_data')->name('ajax.securities.users');
        Route::get('get_all_roles_data', 'Security\Role\AjaxController@get_all_roles_data')->name('ajax.securities.roles');
        Route::get('get_all_permissions_data', 'Security\Permission\AjaxController@get_all_permissions_data')->name('ajax.securities.permissions');
        Route::get('getbranchesbybank/{id}','Master\Branch\AjaxController@get_branches_by_bank')->name('ajax.getbranchesbybank');
    });

    Route::get('/dashboard', 'DashboardController@index')->name('dashboard');
    Route::get('dashboard/chart_member','DashboardController@chart_member')->name('dashboard.chart_member');
    Route::get('dashboard/chart_claim','DashboardController@chart_claim')->name('dashboard.chart_claim');
});


